function eda_collapse_across_subject_variance
% Removes ID

% Housekeeping
eda_name_in       = 'all_eda_clean_downsampled_collapsed.csv';
eda_name_out      = 'all_eda_clean_downsampled_collapsed_collapsed.csv';
[~,~,~,eda_dir] = wave_ghost;
eda_file_in       = fullfile(eda_dir, eda_name_in);
eda_file_out      = fullfile(eda_dir, eda_name_out);

if exist(eda_file_out, 'file')
    fprintf('To run this delete %s\n', eda_file_out);
    return
end

data = readtable(eda_file_in);

% Drop firstlevel errors and groupcount
sem_cols = find(contains(data.Properties.VariableNames,'sem'));
data(:,sem_cols) = [];
data.GroupCount = [];

% Collapse everything but ID, condition and index within trial
grouping_variables = {'condition', 'index_within_trial'};
mean_data = varfun(@mean, data, 'GroupingVariables', grouping_variables);
sem_data = varfun(@sem, data, 'GroupingVariables', grouping_variables);

% Get rid of mean_ prefix
for i = 1:width(mean_data)
    mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'mean_','');
end


% Transfer interesting sem columns to mean data
cols_to_transfer = sem_data.Properties.VariableNames(17:end);
for i = 1:numel(cols_to_transfer)
    mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});   
end

% Writeoutput
writetable(mean_data, eda_file_out);


% Sem function
function out = sem(in)
out = std(in)./sqrt(numel(in));