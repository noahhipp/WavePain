function online_analyis

% Settings
SAMPLE   = 'behav'; % can be behav or fmri

% Housekeeping
HOST                = wave_ghost2(SAMPLE);
CPR_DIR             = fullfile(HOST.dir, 'online_ratings');
CPR_TEMPLATE        = 'all_online_ratings.csv';
CPR_C_TEMPLATE      = 'all_online_ratings_c.csv'; % first level variance removed
CPR_CC_TEMPLATE    = 'all_online_ratings_cc.csv'; % second level variance removed

CPR_FILE            = fullfile(CPR_DIR, CPR_TEMPLATE);
CPR_C_FILE          = fullfile(CPR_DIR, CPR_C_TEMPLATE);
CPR_CC_FILE        = fullfile(CPR_DIR, CPR_CC_TEMPLATE);

% Check if source is available
if ~exist(CPR_FILE, 'file') % then we cannot do anything
    fprintf('Source file (%s) is missing. Aborting.\n', RAW_FILE)
    return
end

% Collapse firstlevel variance
if ~exist(CPR_C_FILE, 'file')
    fprintf('%s is missing. Collapsing firstlevel variance.\n', CPR_C_FILE)
    
    % Grab raw data
    data_in = readtable(CPR_FILE);
    
    % Collapse everything but ID, shape and rating_counter    
    grouping_variables = {'id', 'shape', 'rating_counter'};
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
    writetable(data_out, CPR_C_FILE);        
    fprintf('\nWrote %s.\n', CPR_C_FILE);
end

% Collapse second level variance
if ~exist(CPR_CC_FILE, 'file')
    fprintf('%s is missing. Collapsing firstlevel variance.\n', CPR_CC_FILE)
    
    % Grab first level collapsed data
    data_in = readtable(CPR_C_FILE);
    data_in.GroupCount = [];
    
    % Collapse everything but ID, shape and rating_counter    
    grouping_variables = {'shape', 'rating_counter'};
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
    writetable(data_out, CPR_CC_FILE);        
    fprintf('\nWrote %s.\n', CPR_CC_FILE);
end
