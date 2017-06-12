function mechanism_types = get_mechanism_types_array()

files = dir('mechanisms/m_*.slx');
files = {files(:).name};
mechanism_types = cellfun(@(filename) filename(3:(end-4)), files, 'UniformOutput', false)';

end
