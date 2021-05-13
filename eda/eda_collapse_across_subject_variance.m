function eda_collapse_across_subject_variance
% Removes ID

% Housekeeping
eda_name_in       = 'all_eda_clean_downsampled10_collapsed.csv';
eda_name_out      = 'all_eda_clean_downsampled10_collapsed_collapsed.csv';
[~,~,~,eda_dir] = wave_ghost;
eda_file_in       = fullfile(eda_dir, eda_name_in);
eda_file_out      = fullfile(eda_dir, eda_name_out);

if exist(eda_file_out, 'file')    
    fprintf('To run this %s needs to be deleted.\n', eda_file_out);
    order = input('delete file? [y]es, [n]o \n', 's');
    if ~strcmp(order, 'y')
        return
    else
        delete(eda_file_out);
        fprintf('%s has been deleted. proceeding...\n', eda_file_out);
    end
end

data = readtable(eda_file_in);

% Drop firstlevel errors and groupcount
sem_cols            = contains(data.Properties.VariableNames,'sem');
data(:,sem_cols)    = [];
data.GroupCount     = [];

% Collapse everything but ID, condition and index within trial
if contains(eda_name_in, 'segmented')
    grouping_variables = {'condition', 'segment'};
else
    grouping_variables = {'condition', 'index_within_trial'};
end
mean_data = varfun(@nanmean, data, 'GroupingVariables', grouping_variables);
sem_data = varfun(@sem, data, 'GroupingVariables', grouping_variables);

% Get rid of mean_ prefix
for i = 1:width(mean_data)
    mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'nanmean_','');
end

% Transfer interesting sem columns to mean data aka columns that contain
% scl or eda
sem_cols = sem_data.Properties.VariableNames;
idx = contains(sem_cols, {'scl','eda'}); 
cols_to_transfer = sem_cols(idx);
for i = 1:numel(cols_to_transfer)
    mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});   
end

% Writeoutput
writetable(mean_data, eda_file_out);
fprintf('Wrote %s\n', eda_file_out);

% Sem function
function out = sem(in)
out = nanstd(in)./sqrt(sum(~isnan(in)));