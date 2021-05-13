function eda_collapse_within_subject_variance
% collapses trial, microblock and session so we end up with 6 timeseries
% per subject (one for each condition)

% Housekeeping
eda_name_in        = 'all_eda_clean_downsampled10_shifted.csv';
eda_name_out       = 'all_eda_clean_downsampled10_shifted_collapsed.csv';
[~,~,~,eda_dir] = wave_ghost;
eda_file_in       = fullfile(eda_dir, eda_name_in);
eda_file_out      = fullfile(eda_dir, eda_name_out);

% Avoid double work
if exist(eda_file_out, 'file')
    fprintf('\nTo run this function again\n delete %s\n',eda_file_out);
    return;
end

% Read in data
data = readtable(eda_file_in);

% Collapse everything but ID, condition and index within trial
grouping_variables = {'ID', 'condition', 'index_within_trial'};
mean_data = varfun(@nanmean, data, 'GroupingVariables', grouping_variables);
sem_data = varfun(@sem, data, 'GroupingVariables', grouping_variables);

% Get rid of mean_ prefix
for i = 1:width(mean_data)
    mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'nanmean_','');
end

% Transfer interesting sem columns to mean data
idx = find(contains(sem_data.Properties.VariableNames, {'scl','eda'}));
cols_to_transfer = sem_data.Properties.VariableNames(idx);
for i = 1:numel(cols_to_transfer)
    mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});   
end

% Make sure that binary regressors are still binary
mean_data.wm            = round(mean_data.wm);
mean_data.slope         = round(mean_data.slope);
mean_data.wm_X_slope    = mean_data.wm .* mean_data.slope;

% Writeoutput
writetable(mean_data, eda_file_out);

% Sem function
function out = sem(in)
out = nanstd(in)./sum(~isnan(in));






