function varargout = trunk_robot_model_generator(varargin)
% FIGURE_TRUNK_ROBOT_MODEL_GENERATOR MATLAB code for figure_trunk_robot_model_generator.fig
%      FIGURE_TRUNK_ROBOT_MODEL_GENERATOR, by itself, creates a new FIGURE_TRUNK_ROBOT_MODEL_GENERATOR or raises the existing
%      singleton*.
%
%      H = FIGURE_TRUNK_ROBOT_MODEL_GENERATOR returns the handle to a new FIGURE_TRUNK_ROBOT_MODEL_GENERATOR or the handle to
%      the existing singleton*.
%
%      FIGURE_TRUNK_ROBOT_MODEL_GENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE_TRUNK_ROBOT_MODEL_GENERATOR.M with the given input arguments.
%
%      FIGURE_TRUNK_ROBOT_MODEL_GENERATOR('Property','Value',...) creates a new FIGURE_TRUNK_ROBOT_MODEL_GENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trunk_robot_model_generator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trunk_robot_model_generator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figure_trunk_robot_model_generator

% Last Modified by GUIDE v2.5 19-May-2017 17:25:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trunk_robot_model_generator_OpeningFcn, ...
                   'gui_OutputFcn',  @trunk_robot_model_generator_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before figure_trunk_robot_model_generator is made visible.
function trunk_robot_model_generator_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trunk_creator_gui (see VARARGIN)

% Choose default command line output for trunk_creator_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trunk_creator_gui wait for user response (see UIRESUME)
% uiwait(handles.figure_trunk_robot_model_generator);

global number_of_columns
global column_error
global column_mechanism_type
global column_mechanism_mass
global column_mechanism_height
global column_platform_mass
global column_platform_width
global column_platform_thickness
global column_segment_angle
global column_mechanism_parameters

number_of_columns = 9;
column_error                = 1;
column_mechanism_type       = 2;
column_mechanism_mass       = 3;
column_mechanism_height     = 4;
column_platform_mass        = 5;
column_platform_width       = 6;
column_platform_thickness   = 7;
column_segment_angle        = 8;
column_mechanism_parameters = 9;

update_preview(handles)



% --- Outputs from this function are returned to the command line.
function varargout = trunk_robot_model_generator_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%% #######################################################################
%%% ################### uipanel_configuration_editor ######################

function edit_segment_number_Callback(hObject, ~, handles)
% hObject    handle to edit_segment_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

input_str = hObject.String;
N = str2double(input_str);
if isscalar(N) && isreal(N) && (mod(N, 1) == 0) && (N >= 0)
    handles.pushbutton_set_segment_number.Enable = 'on';
else 
    handles.pushbutton_set_segment_number.Enable = 'off';
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
end



% --- Executes during object creation, after setting all properties.
function edit_segment_number_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_segment_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

hObject.String = num2str(0);



% --- Executes on button press in pushbutton_set_segment_number.
function pushbutton_set_segment_number_Callback(~, ~, handles)
% hObject    handle to pushbutton_set_segment_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global current_row_index

N_new = str2double(handles.edit_segment_number.String);
N_old = length(config_data);

if N_new ~= N_old
    
    if N_new < N_old
        config_data = config_data(1:N_new);
        handles.uitable_segments.Data = handles.uitable_segments.Data(1:N_new, :);
        
        if current_row_index > 1 + N_new
            current_row_index = 1 + N_new;
            
        end
    else
        for i = N_new:-1:(N_old+1)
            config_data(i) = make_segment_config_data(0);
            handles.uitable_segments.Data(i, :) = make_row_from_segment_config_data(config_data(i));
            uitable_segments_update_error_column(config_data(i), i, handles);
        end
    end

    pushbutton_generate_update_state(handles.edit_segment_number, handles);
    update_preview(handles);
end


function edit_current_row_Callback(hObject, ~, ~)
% hObject    handle to edit_current_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global current_row_index

N = length(config_data);

input_str = hObject.String;
index = str2double(input_str);
if isscalar(index) && isreal(index) && (mod(index, 1) == 0)
    if (index <= 0)
        current_row_index = 1;
        hObject.String = num2str(current_row_index);
    elseif (index > 1 + N)
        current_row_index = 1 + N;
        hObject.String = num2str(current_row_index);
    else
        current_row_index = index;
    end
else 
    hObject.String = num2str(current_row_index);
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
end



% --- Executes during object creation, after setting all properties.
function edit_current_row_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_current_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global current_row_index

current_row_index = 1;
hObject.String = num2str(current_row_index);



% --- Executes on button press in pushbutton_row_move_up.
function pushbutton_row_move_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_row_move_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global current_row_index

if current_row_index > 1
    segment_config_data = config_data(current_row_index);
    row = handles.uitable_segments.Data(current_row_index, :);
    
    config_data(current_row_index) = config_data(current_row_index - 1);
    config_data(current_row_index - 1) = segment_config_data;
    
    handles.uitable_segments.Data(current_row_index, :) = handles.uitable_segments.Data(current_row_index - 1, :);
    handles.uitable_segments.Data(current_row_index - 1, :) = row;
    
    current_row_index = current_row_index - 1;
    handles.edit_current_row.String = num2str(current_row_index);
    
    update_preview(handles);
end



% --- Executes on button press in pushbutton_row_move_down.
function pushbutton_row_move_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_row_move_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global current_row_index

N = length(config_data);

if current_row_index < N
    segment_config_data = config_data(current_row_index);
    row = handles.uitable_segments.Data(current_row_index, :);
    
    config_data(current_row_index) = config_data(current_row_index + 1);
    config_data(current_row_index + 1) = segment_config_data;
    
    handles.uitable_segments.Data(current_row_index, :) = handles.uitable_segments.Data(current_row_index + 1, :);
    handles.uitable_segments.Data(current_row_index + 1, :) = row;
    
    current_row_index = current_row_index + 1;
    handles.edit_current_row.String = num2str(current_row_index);
    
    update_preview(handles);
end



% --- Executes on button press in pushbutton_row_insert.
function pushbutton_row_insert_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_row_insert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global column_error
global config_data
global current_row_index

N = length(config_data);

sz = size(config_data);
if sz(1) > 1
    config_data = [config_data(1:current_row_index-1); ...
                   make_segment_config_data(0); ...
                   config_data(current_row_index:end)];
else
    config_data = [config_data(1:current_row_index-1), ...
                   make_segment_config_data(0), ...
                   config_data(current_row_index:end)];
end

handles.uitable_segments.Data = ...
    [handles.uitable_segments.Data(1:current_row_index-1, :); ...
     make_row_from_segment_config_data(config_data(current_row_index)); ...
     handles.uitable_segments.Data(current_row_index:end, :)];

handles.uitable_segments.Data{current_row_index, column_error} = ' X ';

current_row_index = current_row_index + 1;
handles.edit_current_row.String = num2str(current_row_index);

pushbutton_generate_update_state(handles.uitable_segments, handles);
update_preview(handles);



% --- Executes on button press in pushbutton_row_delete.
function pushbutton_row_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_row_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global current_row_index

N = length(config_data);

if current_row_index <= N
    config_data(current_row_index) = [];
    handles.uitable_segments.Data(current_row_index, :) = [];
    
    if (current_row_index == N) && (N > 1)
        current_row_index = current_row_index - 1;
        handles.edit_current_row.String = num2str(current_row_index);
    end
    
    pushbutton_generate_update_state(handles.uitable_segments, handles);
    update_preview(handles);
end



% --- Executes on button press in pushbutton_select_config.
function pushbutton_select_config_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.mat');
if filename ~= 0
    handles.edit_load_config_file.String = [pathname filename];
    handles.pushbutton_load_config.Enable = 'on';
    handles.pushbutton_save_config.Enable = 'on';
end



function edit_load_config_file_Callback(hObject, ~, handles)
% hObject    handle to edit_load_config_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file_name = hObject.String;
if ~isempty(file_name)
    handles.pushbutton_load_config.Enable = 'on';
    handles.pushbutton_save_config.Enable = 'on';
else 
    handles.pushbutton_load_config.Enable = 'off';
    handles.pushbutton_save_config.Enable = 'off';
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
end



% --- Executes during object creation, after setting all properties.
function edit_load_config_file_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_load_config_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

hObject.String = '';



% --- Executes on button press in pushbutton_load_config.
function pushbutton_load_config_Callback(~, ~, handles)
% hObject    handle to pushbutton_load_config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data

load(handles.edit_load_config_file.String, 'config_data');
handles.edit_segment_number.String = num2str(length(config_data));

uitable_segments_fill(handles);
uitable_segments_refresh(handles);



% --- Executes on button press in pushbutton_save_config.
function pushbutton_save_config_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data % needed for save()

button = questdlg('Do you want to save configuration data? Existing file will be overwritten.', '', 'Yes', 'No', 'No');
if strcmp(button, 'Yes')
    save(handles.edit_load_config_file.String, 'config_data');
    msgbox(['Robot configuration has been written to file "' handles.edit_load_config_file.String '"']);
end



function uitable_segments_update_error_column(segment_config_data, i, handles)

global column_error

result = ((sum(ismember(get_mechanism_types_array(), ...
    strtrim(segment_config_data.mechanism_type))) == 1) && ...
    all([segment_config_data.mechanism_mass
    segment_config_data.mechanism_height
    segment_config_data.platform_mass
    segment_config_data.platform_width
    segment_config_data.platform_thickness] > 0));

if result
    handles.uitable_segments.Data{i, column_error} = '';
else
    handles.uitable_segments.Data{i, column_error} = ' X ';
end



function result = is_uitable_segments_content_correct(handles)

global column_error

no_error = cellfun(@isempty, handles.uitable_segments.Data(:, column_error), 'UniformOutput', false);
result = all([no_error{:}]);



function uitable_segments_fill(handles)

global number_of_columns
global config_data

handles.uitable_segments.Data = cell(length(config_data), number_of_columns);
for i = 1:length(config_data)
    handles.uitable_segments.Data(i, :) = make_row_from_segment_config_data(config_data(i));
end



function uitable_segments_refresh(handles)

global config_data

for i = 1:length(config_data)
    uitable_segments_update_error_column(config_data(i), i, handles);
end

pushbutton_generate_update_state(handles.uitable_segments, handles);
update_preview(handles);



function row = make_row_from_segment_config_data(segment_config_data)

row = horzcat({' X '}, struct2cell(segment_config_data)');



function segment_config_data = make_segment_config_data_from_row(row)

global number_of_columns
global column_error

segment_config_data = make_segment_config_data(row{(column_error+1):number_of_columns});



% --- Executes when entered data in editable cell(s) in uitable_segments.
function uitable_segments_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable_segments (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

global config_data
global column_error

i = eventdata.Indices(1);

if isempty(eventdata.Error)
    row = hObject.Data(i, :);
    config_data(i) = make_segment_config_data_from_row(row);
    
    uitable_segments_update_error_column(config_data(i), i, handles);
    pushbutton_generate_update_state(handles.uitable_segments, handles);
    update_preview(handles);
else
    hObject.Data{i, column_error} = ' X ';
end


% --- Executes when selected cell(s) is changed in uitable_segments.
function uitable_segments_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable_segments (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

global current_row_index

if ~isempty(eventdata.Indices)
    current_row_index = eventdata.Indices(1);
    handles.edit_current_row.String = num2str(current_row_index);
end



% --- Executes during object creation, after setting all properties.
function uitable_segments_CreateFcn(hObject, ~, ~)
% hObject    handle to uitable_segments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global number_of_columns
global config_data

config_data = make_segment_config_data();
hObject.Data = cell(0, number_of_columns);

%%% #######################################################################
%%% #################### uipanel_mechanism_types ##########################

% --- Executes on selection change in listbox_mechanism_types.
function listbox_mechanism_types_Callback(~, ~, ~)
% hObject    handle to listbox_mechanism_types (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3



% --- Executes during object creation, after setting all properties.
function listbox_mechanism_types_CreateFcn(hObject, ~, ~)
% hObject    handle to listbox_mechanism_types (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

hObject.String = strjoin(get_mechanism_types_array(), '\n');



%%% #######################################################################
%%% ############## uipanel_quick_mechanism_type_setup #####################

% --- Executes on button press in pushbutton_quick_set_mechanism_types.
function pushbutton_quick_set_mechanism_types_Callback(~, ~, handles)
% hObject    handle to pushbutton_quick_set_mechanism_types (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global column_mechanism_type

mech_types = cellstr(handles.listbox_mechanism_types.String);

handles.edit_quick_mechanism_type.String = mech_types{handles.listbox_mechanism_types.Value};

[config_data(:).mechanism_type] = deal(handles.edit_quick_mechanism_type.String);
[handles.uitable_segments.Data{:, column_mechanism_type}] = deal(handles.edit_quick_mechanism_type.String);
uitable_segments_refresh(handles);



% --- Executes during object creation, after setting all properties.
function pushbutton_quick_set_mechanism_types_CreateFcn(hObject, ~, ~)
% hObject    handle to pushbutton_quick_set_mechanism_types (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ~isempty(get_mechanism_types_array())
    hObject.Enable = 'on';
end



%%% #######################################################################
%%% ###################### uipanel_quick_setup ############################

function edit_quick_mechanism_mass_Callback(hObject, ~, handles)
% hObject    handle to edit_quick_mechanism_mass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_quick_set_parameters_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_quick_mechanism_mass_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_quick_mechanism_mass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_quick_mechanism_mass_decfactor_Callback(hObject, ~, handles)
% hObject    handle to edit_quick_mechanism_mass_decfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_quick_set_parameters_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_quick_mechanism_mass_decfactor_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_quick_mechanism_mass_decfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_quick_mechanism_height_Callback(hObject, ~, handles)
% hObject    handle to edit_quick_mechanism_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_quick_set_parameters_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_quick_mechanism_height_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_quick_mechanism_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_quick_mechanism_height_decfactor_Callback(hObject, ~, handles)
% hObject    handle to edit_quick_mechanism_height_decfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_quick_set_parameters_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_quick_mechanism_height_decfactor_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_quick_mechanism_height_decfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_quick_platform_mass_Callback(hObject, ~, handles)
% hObject    handle to edit_quick_platform_mass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_quick_set_parameters_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_quick_platform_mass_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_quick_platform_mass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_quick_platform_width_Callback(hObject, ~, handles)
% hObject    handle to edit_quick_platform_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_quick_set_parameters_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_quick_platform_width_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_quick_platform_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_quick_platform_thickness_Callback(hObject, ~, handles)
% hObject    handle to edit_quick_platform_thickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_quick_set_parameters_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_quick_platform_thickness_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_quick_platform_thickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_quick_platform_size_decfactor_Callback(hObject, ~, handles)
% hObject    handle to edit_quick_platform_size_decfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_quick_set_parameters_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_quick_platform_size_decfactor_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_quick_platform_size_decfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pushbutton_quick_set_parameters_update_state(~, handles)

result = {
    handles.edit_quick_mechanism_mass.String
    handles.edit_quick_mechanism_mass_decfactor.String
    handles.edit_quick_mechanism_height.String
    handles.edit_quick_mechanism_height_decfactor.String
    handles.edit_quick_platform_mass.String
    handles.edit_quick_platform_width.String
    handles.edit_quick_platform_thickness.String
    handles.edit_quick_platform_size_decfactor.String
    };

result = cellfun(@str2double, result, 'UniformOutput', false);
result = cellfun(@(value) (isscalar(value) && isreal(value) && (value > 0)), ...
    result, 'UniformOutput', false);

if all([result{:}])
    handles.pushbutton_quick_set_parameters.Enable = 'on';
else 
    handles.pushbutton_quick_set_parameters.Enable = 'off';
    % Give the edit text box focus so user can correct the error
    %uicontrol(hObject)
end



% --- Executes on button press in pushbutton_quick_set_parameters.
function pushbutton_quick_set_parameters_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_quick_set_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global column_mechanism_mass
global column_mechanism_height
global column_platform_mass
global column_platform_width
global column_platform_thickness

mech0_mass = str2double(handles.edit_quick_mechanism_mass.String);
mech_mass_decfactor = str2double(handles.edit_quick_mechanism_mass_decfactor.String);
mech0_height = str2double(handles.edit_quick_mechanism_height.String);
mech_height_decfactor = str2double(handles.edit_quick_mechanism_height_decfactor.String);
plat0_mass = str2double(handles.edit_quick_platform_mass.String);
plat0_width = str2double(handles.edit_quick_platform_width.String);
plat0_thickness = str2double(handles.edit_quick_platform_thickness.String);
plat_size_decfactor = str2double(handles.edit_quick_platform_size_decfactor.String);

i = 0:length(config_data)-1;

v = num2cell(mech0_mass * mech_mass_decfactor .^ i);
[config_data(:).mechanism_mass] = deal(v{:});
[handles.uitable_segments.Data{:, column_mechanism_mass}] = deal(v{:});

v = num2cell(mech0_height * mech_height_decfactor .^ i);
[config_data(:).mechanism_height] = deal(v{:});
[handles.uitable_segments.Data{:, column_mechanism_height}] = deal(v{:});

v = num2cell(plat0_mass * (plat_size_decfactor^3) .^ i);
[config_data(:).platform_mass] = deal(v{:});
[handles.uitable_segments.Data{:, column_platform_mass}] = deal(v{:});

v = num2cell(plat0_width * plat_size_decfactor .^ i);
[config_data(:).platform_width] = deal(v{:});
[handles.uitable_segments.Data{:, column_platform_width}] = deal(v{:});

v = num2cell(plat0_thickness * plat_size_decfactor .^ i);
[config_data(:).platform_thickness] = deal(v{:});
[handles.uitable_segments.Data{:, column_platform_thickness}] = deal(v{:});

uitable_segments_refresh(handles);



% --- Executes on button press in pushbutton_quick_set_segment_angles.
function pushbutton_quick_set_segment_angles_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_quick_set_segment_angles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global column_segment_angle

v = num2cell(zeros(1, length(config_data)));
[config_data(:).segment_angle] = deal(v{:});
[handles.uitable_segments.Data{:, column_segment_angle}] = deal(v{:});



% --- Executes on button press in pushbutton_quick_reset_mechanism_parameters.
function pushbutton_quick_reset_mechanism_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_quick_reset_mechanism_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data
global column_mechanism_parameters

v = '';
[config_data(:).segment_angle] = deal(v);
[handles.uitable_segments.Data{:, column_mechanism_parameters}] = deal(v);



%%% #######################################################################
%%% ######################## uipanel_preview ##############################

% --- Executes on button press in pushbutton_preview_lean_left_slow.
function pushbutton_preview_lean_left_slow_Callback(~, ~, handles)
% hObject    handle to pushbutton_preview_lean_left_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global preview_effector_angle

preview_effector_angle = preview_effector_angle - 5;
handles.edit_preview_effector_angle.String = num2str(preview_effector_angle);
handles.slider_preview_effector_angle.Value = max(-180, min(180, preview_effector_angle));
update_preview(handles);



% --- Executes on button press in pushbutton_preview_lean_right_slow.
function pushbutton_preview_lean_right_slow_Callback(~, ~, handles)
% hObject    handle to pushbutton_preview_lean_right_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global preview_effector_angle

preview_effector_angle = preview_effector_angle + 5;
handles.edit_preview_effector_angle.String = num2str(preview_effector_angle);
handles.slider_preview_effector_angle.Value = max(-180, min(180, preview_effector_angle));
update_preview(handles);



% --- Executes on button press in pushbutton_preview_lean_left_fast.
function pushbutton_preview_lean_left_fast_Callback(~, ~, handles)
% hObject    handle to pushbutton_preview_lean_left_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global preview_effector_angle

preview_effector_angle = preview_effector_angle - 30;
handles.edit_preview_effector_angle.String = num2str(preview_effector_angle);
handles.slider_preview_effector_angle.Value = max(-180, min(180, preview_effector_angle));
update_preview(handles);



% --- Executes on button press in pushbutton_preview_lean_right_fast.
function pushbutton_preview_lean_right_fast_Callback(~, ~, handles)
% hObject    handle to pushbutton_preview_lean_right_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global preview_effector_angle

preview_effector_angle = preview_effector_angle + 30;
handles.edit_preview_effector_angle.String = num2str(preview_effector_angle);
handles.slider_preview_effector_angle.Value = max(-180, min(180, preview_effector_angle));
update_preview(handles);



function edit_preview_effector_angle_Callback(hObject, ~, handles)
% hObject    handle to edit_preview_effector_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global preview_effector_angle

input_str = hObject.String;
angle = str2num(input_str);
if isscalar(angle) && isreal(angle)
    preview_effector_angle = angle;
    handles.slider_preview_effector_angle.Value = max(-180, min(180, preview_effector_angle));
    update_preview(handles);
else 
    hObject.String = num2str(preview_effector_angle);
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
end



% --- Executes during object creation, after setting all properties.
function edit_preview_effector_angle_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_preview_effector_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global preview_effector_angle

preview_effector_angle = 0;
hObject.String = num2str(preview_effector_angle);


% --- Executes on slider movement.
function slider_preview_effector_angle_Callback(hObject, eventdata, handles)
% hObject    handle to slider_preview_effector_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global preview_effector_angle

preview_effector_angle = hObject.Value;
handles.edit_preview_effector_angle.String = num2str(preview_effector_angle);
update_preview(handles);



% --- Executes during object creation, after setting all properties.
function slider_preview_effector_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_preview_effector_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

hObject.Value = 0;



function result = rot2d(vector, degrees)
result = vector * [cosd(degrees) -sind(degrees); sind(degrees) cosd(degrees)];



function update_preview(handles)

axes(handles.axes_preview)
delete(get(handles.axes_preview, 'children'));

global config_data
global preview_effector_angle

N = length(config_data);

if (N == 0) || ~is_uitable_segments_content_correct(handles)
    return
end

% Ground
line([-1, 1],[0,0],'Color','k','LineWidth',2);

platform_width = [config_data(1).platform_width 0];
pos = [0 0];
angle = 0;

for i = 1:N
    % 1) right-top 2) left-top 3) left-bottom 4) right-bottom
    mechanism_height = [0 config_data(i).mechanism_height];
    platform_width_prev = platform_width;
    platform_width = [config_data(i).platform_width 0];
    platform_thickness = [0 config_data(i).platform_thickness];
    
    % rotate segment
    angle = angle + preview_effector_angle/N;
    mechanism_height = rot2d(mechanism_height, angle);
    platform_width = rot2d(platform_width, angle);
    platform_thickness = rot2d(platform_thickness, angle);
    
    % draw mechanism
    line([pos(1), pos(1)+mechanism_height(1)], [pos(2), pos(2)+mechanism_height(2)], ...
        'Color', 'b', 'LineWidth', 2);
    line([pos(1)+platform_width_prev(1)/2, pos(1)+mechanism_height(1)+platform_width(1)/2], ...
        [pos(2)+platform_width_prev(2)/2, pos(2)+mechanism_height(2)+platform_width(2)/2], ...
        'Color', 'b', 'LineWidth', 2);
    line([pos(1)-platform_width_prev(1)/2, pos(1)+mechanism_height(1)-platform_width(1)/2], ...
        [pos(2)-platform_width_prev(2)/2, pos(2)+mechanism_height(2)-platform_width(2)/2], ...
        'Color', 'b', 'LineWidth', 2);
    
    % draw platform
    pos = pos + mechanism_height;
    line([pos(1)-platform_width(1)/2, pos(1)+platform_width(1)/2], ...
        [pos(2)-platform_width(2)/2, pos(2)+platform_width(2)/2], ...
        'Color', 'r', 'LineWidth', 2);
    line([pos(1)-platform_width(1)/2, pos(1)-platform_width(1)/2+platform_thickness(1)], ...
        [pos(2)-platform_width(2)/2, pos(2)-platform_width(2)/2+platform_thickness(2)], ...
        'Color', 'r', 'LineWidth', 2);
    line([pos(1)+platform_width(1)/2, pos(1)+platform_width(1)/2+platform_thickness(1)], ...
        [pos(2)+platform_width(2)/2, pos(2)+platform_width(2)/2+platform_thickness(2)], ...
        'Color', 'r', 'LineWidth', 2);
    pos = pos + platform_thickness;
    line([pos(1)-platform_width(1)/2, pos(1)+platform_width(1)/2], ...
        [pos(2)-platform_width(2)/2, pos(2)+platform_width(2)/2], ...
        'Color', 'r', 'LineWidth', 2);
end


%%% #######################################################################
%%% ######################## uipanel_network ##############################

function edit_host_Callback(~, ~, handles)
% hObject    handle to edit_host (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_host_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_host (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_receiver_port_Callback(hObject, ~, handles)
% hObject    handle to edit_receiver_port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_receiver_port_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_receiver_port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_sender_port_Callback(hObject, ~, handles)
% hObject    handle to edit_sender_port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_sender_port_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_sender_port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_connection_timeout_Callback(hObject, ~, handles)
% hObject    handle to edit_connection_timeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_connection_timeout_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_connection_timeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%% #######################################################################
%%% #################### uipanel_model_parameters #########################

function edit_model_gravity_Callback(hObject, ~, handles)
% hObject    handle to edit_model_gravity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_model_gravity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_model_gravity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_model_surface_normal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_model_surface_normal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_model_surface_normal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_model_surface_normal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_model_step_Callback(hObject, ~, handles)
% hObject    handle to edit_model_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_model_step_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_model_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_model_stoptime_Callback(hObject, ~, handles)
% hObject    handle to edit_model_stoptime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_model_stoptime_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_model_stoptime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_enable_visualization.
function checkbox_enable_visualization_Callback(~, ~, ~)
% hObject    handle to checkbox_enable_visualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_enable_visualization



% --- Executes on button press in checkbox_close_window.
function checkbox_close_window_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_close_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_close_window



%%% #######################################################################
%%% #################### uipanel_model_generation #########################

function edit_model_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_model_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_generate_update_state(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_model_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_model_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_select_model_file.
function pushbutton_select_model_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_model_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uiputfile({'*.slx'; '*.mdl'});
if filename ~= 0
    handles.edit_model_path.String = [pathname filename];
    pushbutton_generate_update_state(hObject, handles);
end



function pushbutton_generate_update_state(~, handles)

global config_data

port_in = str2double(handles.edit_receiver_port.String);
port_out = str2double(handles.edit_sender_port.String);
timeout = str2double(handles.edit_connection_timeout.String);

gravity = str2num(handles.edit_model_gravity.String);
surface_normal = str2num(handles.edit_model_surface_normal.String);

step = str2double(handles.edit_model_step.String);
stop_time = str2double(handles.edit_model_stoptime.String);

[~, name, ~] = fileparts(handles.edit_model_path.String);

result = ...
    (~isempty(config_data)) && is_uitable_segments_content_correct(handles) && ...
    ~isempty(handles.edit_host.String) && ...
    isscalar(port_in) && isreal(port_in) && (mod(port_in, 1) == 0) && (port_in > 0) && (port_in < 65536) && ...
    isscalar(port_out) && isreal(port_out) && (mod(port_out, 1) == 0) && (port_out > 0) && (port_out < 65536) && ...
    (port_in ~= port_out) && ...
    isscalar(timeout) && isreal(timeout) && (timeout > 0) && ...
    isvector(gravity) && isreal(gravity) && (length(gravity) == 3) && ...
    isvector(surface_normal) && isreal(surface_normal) && (length(surface_normal) == 3) && (sum(surface_normal.^2) > 0) && ...
    isscalar(step) && isreal(step) && (step > 0) && ...
    isscalar(stop_time) && isreal(stop_time) && (stop_time > 0) && ...
    stop_time >= step && ...
    isvarname(name);

if result
    handles.pushbutton_generate.Enable = 'on';
else 
    handles.pushbutton_generate.Enable = 'off';
    % Give the edit text box focus so user can correct the error
    %uicontrol(hObject)
end



% --- Executes on button press in pushbutton_generate.
function pushbutton_generate_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global config_data

[model_path, modelName, ~] = fileparts(handles.edit_model_path.String);

server_host = handles.edit_host.String;
server_port_in = handles.edit_receiver_port.String;
server_port_out = handles.edit_sender_port.String;
timeout = handles.edit_connection_timeout.String;

model_gravity = str2num(handles.edit_model_gravity.String);
model_surface_normal = str2num(handles.edit_model_surface_normal.String);
model_step = str2double(handles.edit_model_step.String);
model_stop_time = str2double(handles.edit_model_stoptime.String);
model_visualization = handles.checkbox_enable_visualization.Value;

hObject.Enable = 'off';

msgbox(['Generator is now working on the model "' modelName '". Please wait for completion!'], 'modal');

%close(trunk_creator_gui);
generate_trunk_model(modelName, model_path, config_data, ...
    struct('host', server_host, 'port_in', server_port_in, 'port_out', server_port_out, 'timeout', timeout), ...
    struct('gravity', model_gravity, 'surface_normal', model_surface_normal, ...
    'step', model_step, 'stop_time', model_stop_time, ...
    'visualization', model_visualization));
open_system(modelName);

if handles.checkbox_close_window.Value ~= 0
    close(trunk_robot_model_generator);
else
    hObject.Enable = 'on';
end
