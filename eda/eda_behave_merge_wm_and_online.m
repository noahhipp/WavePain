function eda_behave_merge_wm_and_online
% Merge behave eda from wm trials (ALL_FILE-->WM_FILE) and online (ONLINE_FILE
% --> ONLINE_FILE) into one file (-->ALL_FILE)

% CONSTANTS
ALL_NAME    = 'all_eda_behav.csv'; 
ONLINE_NAME = 'all_online_scl_behav.csv'; % contains online only
WM_NAME     = 'wm_eda_behav.csv'; 

[~,~,~, EDA_DIR] = wave_ghost('behav');

ALL_FILE    = fullfile(EDA_DIR, ALL_NAME);
ONLINE_FILE = fullfile(EDA_DIR, ONLINE_NAME);
WM_FILE     = fullfile(EDA_DIR, WM_NAME);

if exist(ALL_FILE, 'file')    
    fprintf('To run it again\ndelete %s\n', ALL_FILE);
    return
end

wm_data     = readtable(WM_FILE);
fprintf('Read in %60s with %06d lines\n',WM_FILE,height(wm_data));
online_data = readtable(ONLINE_FILE);
fprintf('Read in %60s with %06d lines\n',ONLINE_FILE,height(online_data));

% Check if tables are compatible
if ~isequal(wm_data.Properties.VariableNames, online_data.Properties.VariableNames)
    error('Variable names are not compatible');
end

% Concatenate them
data = vertcat(wm_data, online_data);
data = sortrows(data, {'ID', 'trial', 'index_within_trial',}, 'ascend');

% Write output
writetable(data,ALL_FILE);
fprintf('Wrote   %60s with %06d lines\n',ALL_FILE,height(data));





