function setup_3SPS(block_name, parameters, segment_config_data)

if isfield(parameters, 'piston_mass')
    piston_mass = parameters.piston_mass;
else
    piston_mass = segment_config_data.mechanism_mass/6;
end

if isfield(parameters, 'p_radius')
    p_radius = parameters.p_radius;
else
    p_radius = 0;
end

piston_inertia = piston_mass * ...
    (segment_config_data.mechanism_height^2 * [1/12 0 0; 0 1/12 0; 0 0 0] + ...
    p_radius^2 * [1/4 0 0; 0 1/4 0; 0 0 1/2]);

cylinder_inertia = (segment_config_data.mechanism_mass/3 - piston_mass) * ...
    (segment_config_data.mechanism_height^2 * [1/12 0 0; 0 1/12 0; 0 0 0] + ...
    p_radius^2 * [1/2 0 0; 0 1/2 0; 0 0 1]);

set_param(block_name, 'piston_mass', num2str(piston_mass));
set_param(block_name, 'piston_inertia', mat2str(piston_inertia));
set_param(block_name, 'cylinder_inertia', mat2str(cylinder_inertia));

end
