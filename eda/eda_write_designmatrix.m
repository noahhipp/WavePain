function eda_write_designmatrix
% writes struct called 'A' that contains fields 'wm' and 'online'
% containing the respective designmatrices used to plot fitted responses
% for analyses

% Get paths (both wm and online)
[~,~,~,EDA_DIR{1}] = wave_ghost;
[~,~,~,EDA_DIR{2}] = wave_ghost('behav');

% Constants
CONS =  {'M21', 'M12', 'W21', 'W12', 'M_Online', 'W_Online'};
F = 10; % frequency to sample desingmatrix

% Loop through conditions thereby creating designmatrix
wm_matrix = [];
online_matrix = [];
for i = 1:numel(CONS)
    con = CONS{i};
    [~, con_matrix] = wave_getpmods(0, con, F);
    if i < 5
        wm_matrix = vertcat(wm_matrix, con_matrix);
    else
        online_matrix = vertcat(online_matrix, con_matrix);
    end
end

% Discard boring online conditions
online_matrix = online_matrix(:,[1,3,5 ]);

% Save
A = struct;
A.wm = wm_matrix;
A.online = online_matrix;

for i = 1:numel(EDA_DIR)
    FNAME = fullfile(EDA_DIR{i}, 'xX.mat');
    save(FNAME, 'A');
end


    