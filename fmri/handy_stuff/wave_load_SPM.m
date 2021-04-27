function data = wave_load_SPM(ananame, cons_to_extract)
% loads second level wavepain analysis to base workspace and extracts some
% data 

% Collect path
[base_dir] = wave_ghost;

% load coordinates
xyz = wave_load_coordinates;

% the path to desired SPM.mat on crunchie
ana_crunchie  = fullfile(base_dir, 'second_Level', ananame,'SPM.mat');

% the name of the desired SPM.mat in workspace
ana_ws = sprintf('%s_SPM', ananame);

% check whether desired SPM.mat is already in memory and act accordingly
try
    SPM = evalin('base',ana_ws);
    fprintf('Found %40s in base workspace.\n', ana_ws);
catch
    load(ana_crunchie, 'SPM');
    assignin('base', ana_ws, SPM);
    fprintf('Successfully assigned %40s to base workspace.\n', ana_ws);
end

% extract desired values want from spm mat
data                = {};
xG.def              = 'Contrast estimates and 90% C.I.';
go_back             = pwd;
cd(fullfile(base_dir, 'second_Level', ananame));
for i = 1:numel(cons_to_extract)
    xG.spec.Ic                  = cons_to_extract(i);
    [~, ~, ~, ~, data{i}]       = spm_graph(SPM, xyz, xG);        
end
cd(go_back);



    
