function setup_W(block_name, parameters, segment_config_data)

if isfield(parameters, 'bar_radius')
    bar_radius = parameters.bar_radius;
else
    bar_radius = 0;
end

bar_inertia = segment_config_data.mechanism_mass * ...
    (segment_config_data.mechanism_height^2 * [1/12 0 0; 0 1/12 0; 0 0 0] + ...
    bar_radius^2 * [1/4 0 0; 0 1/4 0; 0 0 1/2]);

set_param(block_name, 'bar_inertia', mat2str(bar_inertia));

end
