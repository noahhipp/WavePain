function eda_03_collapse_within_subject_variance
% Use varfun collapse firstlevel variance and collect sem's. After this we
% have 6xtimeseries/participant, one for each conditin.

EDA_NAME_IN     = 'all_eda_behav_downsampled01.csv';
[~,~,~,EDA_DIR] = wave_ghost('behav');
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);
[~,NAME, SUFFIX]= fileparts(EDA_FILE_IN);

COLLAPSE_STR = '_collapsed';
EDA_NAME_OUT    = [NAME, COLLAPSE_STR, SUFFIX];
EDA_FILE_OUT    = fullfile(EDA_DIR, EDA_NAME_OUT);

if exist(EDA_FILE_OUT, 'file')
    fprintf('\n To run this function again\n delete %s\n', EDA_FILE_OUT);
    return
end

DATA = readtable(EDA_FILE_IN);

% Collapse everything but ID, condition and index within trial
grouping_variables = {'ID', 'condition', 'index_within_trial'};
mean_data = varfun(@nanmean, DATA, 'GroupingVariables', grouping_variables);
sem_data = varfun(@sem, DATA, 'GroupingVariables', grouping_variables);
fprintf('Height of original DATA: %10d\n', height(DATA));
fprintf('Height of mean DATA: %10d\n', height(mean_data));
fprintf('Reduction factor: %f\n', height(DATA) / height(mean_data));

% Get rid of mean_ prefix
for i = 1:width(mean_data)
    mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'nanmean_','');
end

% Transfer interesting sem columns to mean DATA
idx = find(contains(sem_data.Properties.VariableNames, {'scl','eda'}));
cols_to_transfer = sem_data.Properties.VariableNames(idx);
for i = 1:numel(cols_to_transfer)
    mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});   
end

% Make sure that binary regressors are still binary
mean_data.wm            = round(mean_data.wm);
mean_data.slope         = round(mean_data.slope);
mean_data.wm_X_slope    = mean_data.wm .* mean_data.slope;

% Take care of sampling artefact that makes slope 0 at some task switches
artifacts = mean_data(mean_data.wm ~= 0 & mean_data.slope == 0,:);
artifacts.slope(artifacts.diffheat < 0) = -1;
artifacts.slope(artifacts.diffheat > 0) = 1;
mean_data(mean_data.wm ~= 0 & mean_data.slope == 0,:) = artifacts;

% Verify it worked
n_artifacts = sum(mean_data.wm ~= 0 & mean_data.slope == 0);
fprintf('There are %d artifacts left\n', n_artifacts);

% Writeoutput
writetable(mean_data, EDA_FILE_OUT);
fprintf('\nWrote %s\n', EDA_FILE_OUT);

% Sem function
function out = sem(in)
out = nanstd(in)./sum(~isnan(in));






