clear config_data

N = 10;
mech_type = '3SPS';
mech0_mass = 0.3;
mech_mass_decfactor = 0.9^3;
mech0_height = 0.25;
mech_height_decfactor = 0.9;
plat0_mass = 0.1;
plat0_width = 0.15;
plat0_thickness = 0.05;
plat_size_decfactor = 0.9;
seg_angle = 30;

for i = N:-1:1
    config_data(i) = make_segment_config_data(...
        mech_type, ...
        mech0_mass * mech_mass_decfactor ^ (i-1), ...
        mech0_height * mech_height_decfactor ^ (i-1), ...
        plat0_mass * (plat_size_decfactor ^ 3) ^ (i-1), ...
        plat0_width * plat_size_decfactor ^ (i-1), ...
        plat0_thickness * plat_size_decfactor ^ (i-1), ...
        seg_angle * (i-1), ...
        ['''piston_mass'', ' num2str(mech0_mass/9 * mech_mass_decfactor ^ (i-1)) ', ' ...
        '''p_radius'', ' num2str(plat0_width/20 * plat_size_decfactor ^ (i-1))]);
end

config_data(N-1).mechanism_type = 'RRRP';
config_data(N-1).mechanism_parameters = ...
    ['''piston_mass'', ' num2str(mech0_mass/3 * mech_mass_decfactor ^ (N-2)) ', ' ...
        '''p_radius'', ' num2str(plat0_width/20 * plat_size_decfactor ^ (N-2))];

config_data(N).mechanism_type = 'W';
config_data(N).mechanism_parameters = ...
    ['''bar_radius'', ' num2str(plat0_width/20 * plat_size_decfactor ^ (N-1))];

save('test.mat', 'config_data');

clear config_data N mech_type mech0_mass mech_mass_decfactor mech0_height ...
    mech_height_decfactor plat0_mass plat0_width plat0_thickness plat_size_decfactor ...
    seg_angle