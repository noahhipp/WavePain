function eda_04_collapse_across_subject_variance
% Takes in table with 6 timeseries for each participant. returns table with
% 6 timeseries total.

EDA_NAME_IN     = 'all_eda_behav_downsampled01_collapsed.csv';
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
fprintf('Read in %s\ncontaining %d lines\n', EDA_FILE_IN, height(DATA));

% Drop firstlevel errors and group count
sem_cols            = contains(DATA.Properties.VariableNames,'sem');
DATA(:,sem_cols)    = [];
DATA.GroupCount     = [];

% Collapse everything but condtion and index_within_trial/segment depending
% on what our input looks like
if contains(EDA_NAME_IN, 'segmented')
    grouping_variables = {'condition', 'segment'};
else
    grouping_variables = {'condition', 'index_within_trial'};
end
mean_data = varfun(@nanmean, DATA, 'GroupingVariables', grouping_variables);
sem_data = varfun(@sem, DATA, 'GroupingVariables', grouping_variables);

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
writetable(mean_data, EDA_FILE_OUT);
fprintf('Wrote %s\ncontaining %d lines\n', EDA_FILE_OUT, height(mean_data));

% Sem function
function out = sem(in)
out = nanstd(in)./sqrt(sum(~isnan(in)));
    