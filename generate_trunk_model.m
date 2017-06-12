function generate_trunk_model(modelName, model_path, config_data, connection_info, model_parameters)

N = length(config_data);
used_mechanism_types = unique({config_data(:).mechanism_type});
used_mechanism_types_with_prefix = ...
    cellfun(@(mech_type) ['m_', mech_type], used_mechanism_types, ...
    'UniformOutput', false);

% Create model and set basic model parameters
create_model(modelName, model_path);

set_param(modelName, 'SimulationMode', 'accelerator');
set_param(modelName, 'SolverType', 'Fixed-step');

set_param(modelName, 'FixedStep', num2str(model_parameters.step));
set_param(modelName, 'StopTime', num2str(model_parameters.stop_time));

% Load used libraries
load_system('simulink');
load_system('instrumentlib');

load_system('model_environment');

cellfun(@(mech_type) load_system(['mechanisms/' mech_type]), used_mechanism_types_with_prefix, ...
    'UniformOutput', false);

% Standard block size and offset
global x
global y
global w
global h
global offset_x
global offset_y

x = 0;
y = 0;
w = 100;
h = 50;
offset_x = 100;
offset_y = 100;

% Place 'environment' block
place_environment_block(modelName, model_parameters.gravity);

% Place environment orientation constant block and connect it to 'environment' block
place_environment_orientation_block_and_connect(modelName, model_parameters.surface_normal);

% Place state vectors concatenator block
place_state_vectors_concatenator_block(modelName, N);

% Place 'clock' block and connect it
place_clock_block_and_connect(modelName);

% Read actuator and sensor vectors sizes and calculate totals
data_vector_sizes_array = ...
    cellfun(@(mech_type) csvread(['mechanisms\m_', mech_type, '_data_size.csv']), used_mechanism_types, ...
    'UniformOutput', false);

actuator_vector_sizes = cellfun(@(sz) sz(1), data_vector_sizes_array, ...
    'UniformOutput', false);
actuator_vector_sizes = cell2struct(actuator_vector_sizes, used_mechanism_types_with_prefix, 2);

sensor_vector_sizes = cellfun(@(sz) sz(2), data_vector_sizes_array, ...
    'UniformOutput', false);
sensor_vector_sizes = cell2struct(sensor_vector_sizes, used_mechanism_types_with_prefix, 2);

total_actuator_vector_size = ...
    cellfun(@(mech_type) actuator_vector_sizes.(['m_' mech_type]), {config_data(:).mechanism_type}, ...
    'UniformOutput', false);
total_actuator_vector_size = sum([total_actuator_vector_size{:}]);

total_sensor_vector_size = ...
    cellfun(@(mech_type) sensor_vector_sizes.(['m_' mech_type]), {config_data(:).mechanism_type}, ...
    'UniformOutput', false);
total_sensor_vector_size = sum([total_sensor_vector_size{:}]);

% Place 'TCP/IP Receive' block
place_receiver_block(modelName, connection_info.host, connection_info.port_in, ...
    connection_info.timeout, model_parameters.step, total_actuator_vector_size);

% Place 'TCP/IP Send' block
place_sender_block(modelName, connection_info.host, connection_info.port_out, ...
    connection_info.timeout, model_parameters.step, total_sensor_vector_size);

% Place continuous-to-digital converter block and connect
place_hold_block_and_connect(modelName);

% Prepare mechanism additional parameters setup functions
cd('mechanisms');
custom_setup = cell2struct(...
    cellfun(@(mech_type) str2func(['m_' mech_type '_block_setup']), used_mechanism_types, ...
    'UniformOutput', false), ...
    cellfun(@(mech_type) ['m_', mech_type, '_block_setup'], used_mechanism_types, 'UniformOutput', false), 2);
cd('..');

% Place segments and connect everything
pos_segment = [x, y-h/2, x+w, y+h/2];
pos_selector = [x-h, y-h/2-offset_y, x, y+h/2-offset_y];
prev_name_segment = 'environment';

selector_index = 1;

for i = 1:N
    % Place segment mechanism block and set its parameters
    name_segment = ['segment_', config_data(i).mechanism_type, '_', int2str(i)];
    place_segment_mechanism_block(modelName, i, name_segment, config_data, pos_segment);
    
    % Set additional segment mechanism block parameters
    parameters = eval(['struct(' config_data(i).mechanism_parameters ')']);
    custom_setup_func = custom_setup.(['m_' config_data(i).mechanism_type '_block_setup']);
    custom_setup_func([modelName, '/', name_segment], parameters, config_data(i));
    
    % Connect segments with each other and environment
    add_line(modelName, [prev_name_segment, '/RConn1'], [name_segment, '/LConn1']);
    prev_name_segment = name_segment;
    
    % Place reaction vector selector block
    name_selector = ['selector_', config_data(i).mechanism_type, '_', int2str(i)];
    selector_width = actuator_vector_sizes.(['m_', config_data(i).mechanism_type]);
    place_actuator_vector_selector_block(modelName, name_selector, ...
        selector_index, selector_width, total_actuator_vector_size, pos_selector);
    selector_index = selector_index + selector_width;
    
    % Connect segment to selector, concatenator and receiver blocks
    add_line(modelName, 'receiver/1', [name_selector, '/1'], 'autorouting', 'on');
    add_line(modelName, [name_selector, '/1'], [name_segment, '/1'], 'autorouting', 'on');
    add_line(modelName, [name_segment, '/1'], ['concatenate/' num2str(i+1)], 'autorouting', 'on');
    
    % Increment block coordinates
    pos_segment = pos_segment + [w+offset_x, 0, w+offset_x, 0];
    pos_selector = pos_selector + [w+offset_x, 0, w+offset_x, 0];
end

% Save system
save_system(modelName);

% Set model visualization
if model_parameters.visualization
    set_param(modelName, 'VisDuringSimulation', 'on');
else
    set_param(modelName, 'VisDuringSimulation', 'off');
end

% Save system
save_system(modelName);

%{
% Close used libraries
close_system('simulink');
close_system('instrumentlib');

close_system('model_environment');

cellfun(@(mech_type) close_system(['mechanisms/' mech_type]), used_mechanism_types_with_prefix, ...
    'UniformOutput', false);
%}

% Close and open system properly
close_system(modelName);
open_system([model_path '\' modelName]);

end

%%% #######################################################################

function create_model(modelName, model_path)

% Check if the file already exists and delete it if it does
current_path = pwd();

warnStruct = warning;
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(model_path);
warning(warnStruct);

cd(model_path);

if exist(modelName, 'file') == 4
    % If it does then check whether it's open
    if bdIsLoaded(modelName)
        % If it is then close it (without saving!)
        close_system(modelName, 0);
    end
    % delete the file
    delete([modelName, '.slx']);
end

% Create system in the specified directory
new_system(modelName);
save_system(modelName);
cd(current_path);

end

function place_environment_block(modelName, gravity_vector)

global x
global y
global w
global h
global offset_x

block_name = [modelName, '/environment'];
add_block('model_environment/environment', block_name, ...
    'Position', [x-offset_x-1.5*w y-h/2+h/4 x-offset_x y+h/2+h/4]);
set_param(block_name, 'LinkStatus', 'none');

set_param(block_name, 'gravity_vector', mat2str(gravity_vector));

end

function place_environment_orientation_block_and_connect(modelName, surface_normal)

global x
global y
global w
global h
global offset_x

block_name = [modelName, '/surface_orientation'];
add_block('built-in/Constant', block_name, ...
    'Position', [x-2*offset_x-2.5*w y-h/4 x-2*offset_x-1.5*w y+h/4]);
set_param(block_name, 'LinkStatus', 'none');
set_param(block_name, 'NamePlacement', 'alternate');

surface_rotation_matrix = vrrotvec2mat(vrrotvec([0 0 1], surface_normal));
surface_euler_angles = rotm2eul(surface_rotation_matrix, 'ZYX');
surface_angle_X = surface_euler_angles(3);
surface_angle_Y = surface_euler_angles(2);
surface_angle_Z = surface_euler_angles(1);
set_param(block_name, 'Value', mat2str([surface_angle_X 0 0 surface_angle_Y 0 0 surface_angle_Z 0 0]));

add_line(modelName, 'surface_orientation/1', 'environment/1');

end

function place_state_vectors_concatenator_block(modelName, N)

global x
global y
global w
global h
global offset_x
global offset_y

block_name = [modelName, '/concatenate'];
add_block('simulink/Signal Routing/Vector Concatenate', block_name, ...
    'Position', [x-10*offset_x y x-10*offset_x+w y+h]);
set_param(block_name, 'LinkStatus', 'none');
set_param(block_name, 'Orientation', 'down');
set_param(block_name, 'Position', ...
    [x-offset_x/2-w y+1.25*offset_y x-offset_x/2-w y+1.25*offset_y+h/2] + ...
    (1+N) * [0 0 w+offset_x 0]);
set_param(block_name, 'NamePlacement', 'alternate');
set_param(block_name, 'NumInputs', num2str(N+1));

end

function place_clock_block_and_connect(modelName)

global x
global y
global w
global h
global offset_x
global offset_y

px = (x-offset_x/2-w) + (w+offset_x)/2;

block_name = [modelName, '/clock'];
add_block('simulink/Sources/Clock', block_name, ...
    'Position', [px-h/2 y+1.25*offset_y-h/2-h px+h/2 y+1.25*offset_y-h/2]);
set_param(block_name, 'LinkStatus', 'none');
set_param(block_name, 'Orientation', 'down');
set_param(block_name, 'NamePlacement', 'alternate');
set_param(block_name, 'Decimation', '1000');

add_line(modelName, 'clock/1', 'concatenate/1', 'autorouting', 'on');

end

function place_receiver_block(modelName, serverHost, serverPort, timeout, step, total_actuator_vector_size)

global x
global y
global w
global h
global offset_x
global offset_y

block_name = [modelName, '/receiver'];
add_block('instrumentlib/TCP//IP Receive', block_name, ...
    'Position', [x-offset_x-1.5*w y-h/2-2*offset_y x-offset_x y+h/2-2*offset_y]);
set_param(block_name, 'LinkStatus', 'none');
set_param(block_name, 'Orientation', 'right');
set_param(block_name, 'Priority', '1');

set_param(block_name, 'Host', serverHost);
set_param(block_name, 'Port', num2str(serverPort));
set_param(block_name, 'DataSize', ['[1 ' num2str(total_actuator_vector_size) ']']);
set_param(block_name, 'DataType', 'double');
set_param(block_name, 'ByteOrder', 'LittleEndian');
set_param(block_name, 'EnableBlockingMode', 'on');
set_param(block_name, 'Timeout', timeout);
set_param(block_name, 'SampleTime', num2str(step));

end

function place_sender_block(modelName, serverHost, serverPort, timeout, ~, ~)

global x
global y
global w
global h
global offset_x
global offset_y

block_name = [modelName, '/sender'];
add_block('instrumentlib/TCP//IP Send', block_name, ...
    'Position', [x-offset_x-1.5*w y-h/2+2*offset_y x-offset_x y+h/2+2*offset_y]);
set_param(block_name, 'LinkStatus', 'none');
set_param(block_name, 'Orientation', 'left');
set_param(block_name, 'Priority', '2');

set_param(block_name, 'Host', serverHost);
set_param(block_name, 'Port', num2str(serverPort));
set_param(block_name, 'ByteOrder', 'LittleEndian');
set_param(block_name, 'EnableBlockingMode', 'on');
set_param(block_name, 'Timeout', timeout);

end

function place_hold_block_and_connect(modelName)

global x
global y
global h
global offset_x
global offset_y

block_name = [modelName, '/hold'];
add_block('simulink/Discrete/Zero-Order Hold', block_name, ...
    'Position', [x-offset_x+offset_x/2 y-h/2+2*offset_y x-offset_x+offset_x/2+h y+h/2+2*offset_y]);
set_param(block_name, 'LinkStatus', 'none');
set_param(block_name, 'Orientation', 'left');

add_line(modelName, 'hold/1', 'sender/1');

% Connect state vectors concatenator block to 'hold' block
add_line(modelName, 'concatenate/1', 'hold/1', 'autorouting', 'on');

end

function place_segment_mechanism_block(modelName, i, name, config_data, pos_segment)

% Add segment mechanism block
block_name = [modelName, '/', name];
add_block(['m_', config_data(i).mechanism_type, ...
    '/segment_', config_data(i).mechanism_type], ...
    block_name, 'Position', pos_segment);
set_param(block_name, 'LinkStatus', 'none');

% Set segment mechanism block parameters
set_param(block_name, 'platform_mass', num2str(config_data(i).platform_mass));
set_param(block_name, 'platform_width', num2str(config_data(i).platform_width));
set_param(block_name, 'platform_thickness', num2str(config_data(i).platform_thickness));
set_param(block_name, 'platform_inertia', mat2str(...
    config_data(i).platform_mass * ...
    ((config_data(i).platform_width/2)^2 * [1/4 0 0; 0 1/4 0; 0 0 1/2] + ...
    config_data(i).platform_thickness^2 * [1/12 0 0; 0 1/12 0; 0 0 0])));

set_param(block_name, 'mechanism_mass', num2str(config_data(i).mechanism_mass));
set_param(block_name, 'mechanism_height', num2str(config_data(i).mechanism_height));
if i > 1
    set_param(block_name, 'base_width', num2str(config_data(i-1).platform_width));
else
    set_param(block_name, 'base_width', num2str(config_data(1).platform_width));
end

if i > 1
    set_param(block_name, 'segment_turn', num2str(config_data(i).segment_angle - config_data(i-1).segment_angle));
else
    set_param(block_name, 'segment_turn', num2str(config_data(1).segment_angle));
end

end

function place_actuator_vector_selector_block(modelName, name_selector, ...
    selector_index, selector_width, total_actuator_vector_size, pos_selector)

block_name_selector = [modelName, '/', name_selector];
add_block('simulink/Signal Routing/Selector', block_name_selector, ...
    'Position', pos_selector);
set_param(block_name_selector, 'LinkStatus', 'none');
set_param(block_name_selector, 'Orientation', 'down');
set_param(block_name_selector, 'NamePlacement', 'alternate');

set_param(block_name_selector, 'InputPortWidth', '-1'); % num2str(total_actuator_vector_size)
set_param(block_name_selector, 'Indices', num2str(selector_index));
set_param(block_name_selector, 'IndexOptions', 'Starting index (dialog)');
set_param(block_name_selector, 'OutputSizeArray', {num2str(selector_width)});

end
