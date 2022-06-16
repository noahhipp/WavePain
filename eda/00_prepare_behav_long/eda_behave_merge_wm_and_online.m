function eda_behave_merge_wm_and_online
% Merge behave eda from wm trials (ALL_FILE-->WM_FILE) and online (ONLINE_FILE
% --> ONLINE_FILE) into one file (-->ALL_FILE)

% CONSTANTS
ALL_NAME    = 'all_eda_behav.csv'; % before we run this script this contains wm only, afterwards it contains both wm and online
ONLINE_NAME = 'all_online_scl_behav.csv'; % contains online only
WM_NAME     = 'all_eda_behav_wm.csv'; % created by this script, contains wm

[~,~,~, EDA_DIR] = wave_ghost('behav');

ALL_FILE    = fullfile(EDA_DIR, ALL_NAME);
ONLINE_FILE = fullfile(EDA_DIR, ONLINE_NAME);
WM_FILE     = fullfile(EDA_DIR, WM_NAME);

if exist(WM_FILE, 'file')
    fprintf('Make sure you REALLY understand what this function does\n');
    fprintf('To run it again rename files accordingly and delete %s\n', WM_FILE);
    return
end

% before the first run this file contains eda from wm trials only
wm_data     = readtable(ALL_FILE);

% this contains online eda only before and after run
online_data = readtable(ONLINE_FILE);

% Check if tables are compatible
if ~isequal(wm_data.Properties.VariableNames, online_data.Properties.VariableNames)
    error('Variable names are not compatible');
end

% Concatenate them
data = vertcat(wm_data, online_data);
data = sortrows(data, {'ID', 'trial', 'index_within_trial',}, 'ascend');

% Write output
writetable(data,ALL_FILE);
writetable(wm_data, WM_FILE);
writetable(online_data, ONLINE_FILE);




