function overall_analysis

% Settings
SAMPLE   = 'fmri'; % can be behav or fmri

% Housekeeping
HOST                = wave_ghost2(SAMPLE);
OPR_DIR             = fullfile(HOST.dir, 'overall_ratings');
OPR_TEMPLATE        = 'all_overall_ratings.csv';
OPR_C_TEMPLATE      = 'all_overall_ratings_c.csv'; % first level variance removed
OPR_CC_TEMPLATE    = 'all_overall_ratings_cc.csv'; % second level variance removed

OPR_FILE            = fullfile(OPR_DIR, OPR_TEMPLATE);
OPR_C_FILE          = fullfile(OPR_DIR, OPR_C_TEMPLATE);
OPR_CC_FILE        = fullfile(OPR_DIR, OPR_CC_TEMPLATE);

% Check if source is available
if ~exist(OPR_FILE, 'file') % then we cannot do anything
    fprintf('Source file (%s) is missing. Aborting.\n', RAW_FILE)
    return
end

% Collapse firstlevel variance
if ~exist(OPR_C_FILE, 'file')
    fprintf('%s is missing. Collapsing firstlevel variance.\n', OPR_C_FILE)
    
    % Grab raw data
    data_in = readtable(OPR_FILE);
    
    % Collapse everything but ID and condition
    grouping_variables = {'id', 'condition'};
    mean_data = varfun(@mean, data_in, 'GroupingVariables', grouping_variables);
    sem_data = varfun(@sem, data_in, 'GroupingVariables', grouping_variables);
    fprintf('Height of original DATA: %10d\n', height(data_in));
    fprintf('Height of mean DATA: %10d\n', height(mean_data));
    fprintf('Reduction factor: %f\n', height(data_in) / height(mean_data));
    
    % Get rid of mean_ prefix
    for i = 1:width(mean_data)
        mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'mean_','');
    end
    
    % Transfer interesting sem columns to mean DATA
    idx = contains(sem_data.Properties.VariableNames, 'rating');
    cols_to_transfer = sem_data.Properties.VariableNames(idx);
    for i = 1:numel(cols_to_transfer)
        mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});
    end            
    
    % Write output
    data_out = mean_data;
    writetable(data_out, OPR_C_FILE);        
    fprintf('\nWrote %s.\n', OPR_C_FILE);
end

% Collapse second level variance
if ~exist(OPR_CC_FILE, 'file')
    fprintf('%s is missing. Collapsing firstlevel variance.\n', OPR_CC_FILE)
    
    % Grab first level collapsed data
    data_in = readtable(OPR_C_FILE);
    data_in.GroupCount = [];
    
    % Collapse everything but ID, shape and rating_counter    
    grouping_variables = {'condition'};
    mean_data = varfun(@mean, data_in, 'GroupingVariables', grouping_variables);
    sem_data = varfun(@sem, data_in, 'GroupingVariables', grouping_variables);
    fprintf('Height of original DATA: %10d\n', height(data_in));
    fprintf('Height of mean DATA: %10d\n', height(mean_data));
    fprintf('Reduction factor: %f\n', height(data_in) / height(mean_data));
    
    % Get rid of mean_ prefix
    for i = 1:width(mean_data)
        mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'mean_','');
    end
    
    % Transfer interesting sem columns to mean DATA
    idx = contains(sem_data.Properties.VariableNames, 'rating');
    cols_to_transfer = sem_data.Properties.VariableNames(idx);
    for i = 1:numel(cols_to_transfer)
        mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});
    end            
    
    % Write output
    data_out = mean_data;
    writetable(data_out, OPR_CC_FILE);        
    fprintf('\nWrote %s.\n', OPR_CC_FILE);
end
