function overall_collapse_within_subject_variance

% Housekeeping
NAME_IN     = 'all_overall_fmri.csv';
[~,~,~,~,~,BASE_DIR]    = wave_ghost();

DIR         = fullfile(BASE_DIR, 'overall_ratings');
FILE_IN     = fullfile(DIR, NAME_IN);
[~,NAME, SUFFIX]= fileparts(FILE_IN);

COLLAPSE_STR = '_collapsed';
NAME_OUT    = [NAME, COLLAPSE_STR, SUFFIX];
FILE_OUT    = fullfile(DIR, NAME_OUT);

if exist(FILE_OUT, 'file')
    fprintf('\n To run this function again\n delete %s\n', FILE_OUT);
    return
end

% Read data
DATA = readtable(FILE_IN);
DATA.attention = []; % this is categorical so we throw it out here

% Collapse everything but ID and  condition 
grouping_variables = {'ID', 'condition'};
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
idx = find(contains(sem_data.Properties.VariableNames, {'rating'}));
cols_to_transfer = sem_data.Properties.VariableNames(idx);
for i = 1:numel(cols_to_transfer)
    mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});   
end

% Writeoutput
writetable(mean_data, FILE_OUT);
fprintf('\nWrote %s\n', FILE_OUT);

% Sem function
function out = sem(in)
out = nanstd(in)./sqrt(sum(~isnan(in)));