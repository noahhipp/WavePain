function eda_analysis

% Settings
SAMPLE   = 'behav'; % can be behav or fmri

% Housekeeping
HOST                = wave_ghost2(SAMPLE);
EDA_DIR             = fullfile(HOST.dir, 'eda');
EDA_TEMPLATE        = 'all_eda.csv';
EDA_C_TEMPLATE      = 'all_eda_c.csv'; % first level variance removed
EDA_CC_TEMPLATE    = 'all_eda_cc.csv'; % second level variance removed

EDA_FILE            = fullfile(EDA_DIR, EDA_TEMPLATE);
EDA_C_FILE          = fullfile(EDA_DIR, EDA_C_TEMPLATE);
EDA_CC_FILE        = fullfile(EDA_DIR, EDA_CC_TEMPLATE);

% Check if source is available
if ~exist(EDA_FILE, 'file') % then we cannot do anything
    fprintf('Source file (%s) is missing. Aborting.\n', RAW_FILE)
    return
end

% Collapse firstlevel variance
if ~exist(EDA_C_FILE, 'file')
    fprintf('%s is missing. Collapsing firstlevel variance.\n', EDA_C_FILE)
    
    % Grab raw data
    data_in = readtable(EDA_FILE);
    
    % Collapse everything but ID, shape and rating_counter    
    grouping_variables = {'id', 'condition', 'index_within_trial'};
    mean_data = varfun(@nanmean, data_in, 'GroupingVariables', grouping_variables);
    sem_data = varfun(@sem, data_in, 'GroupingVariables', grouping_variables);
    fprintf('Height of original DATA: %10d\n', height(data_in));
    fprintf('Height of mean DATA: %10d\n', height(mean_data));
    fprintf('Reduction factor: %f\n', height(data_in) / height(mean_data));
    
    % Get rid of mean_ prefix
    for i = 1:width(mean_data)
        mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'nanmean_','');
    end
    
    % Transfer interesting sem columns to mean DATA
    idx = contains(sem_data.Properties.VariableNames, 'scl');
    cols_to_transfer = sem_data.Properties.VariableNames(idx);
    for i = 1:numel(cols_to_transfer)
        mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});
    end            
    
    % Write output
    data_out = mean_data;
    writetable(data_out, EDA_C_FILE);        
    fprintf('\nWrote %s.\n', EDA_C_FILE);
    
else
    fprintf('Wanna delete %s and run again?\n', EDA_C_FILE)
    prompt = input('(y/N)?\n', 's');
    if strcmp(prompt, 'y')
        delete(EDA_C_FILE);
        return
    end
end

% Collapse second level variance
if ~exist(EDA_CC_FILE, 'file')
    fprintf('%s is missing. Collapsing firstlevel variance.\n', EDA_CC_FILE)
    
    % Grab first level collapsed data
    data_in = readtable(EDA_C_FILE);
    data_in.GroupCount = [];
    
    % Collapse everything but ID, shape and rating_counter    
    grouping_variables = {'condition', 'index_within_trial'};
    mean_data = varfun(@nanmean, data_in, 'GroupingVariables', grouping_variables);
    sem_data = varfun(@sem, data_in, 'GroupingVariables', grouping_variables);
    fprintf('Height of original DATA: %10d\n', height(data_in));
    fprintf('Height of mean DATA: %10d\n', height(mean_data));
    fprintf('Reduction factor: %f\n', height(data_in) / height(mean_data));
    
    % Get rid of mean_ prefix
    for i = 1:width(mean_data)
        mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'nanmean_','');
    end
    
    % Transfer interesting sem columns to mean DATA
    idx = contains(sem_data.Properties.VariableNames, 'rating');
    cols_to_transfer = sem_data.Properties.VariableNames(idx);
    for i = 1:numel(cols_to_transfer)
        mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});
    end            
    
    % Write output
    data_out = mean_data;
    writetable(data_out, EDA_CC_FILE);        
    fprintf('\nWrote %s.\n', EDA_CC_FILE);
else
    fprintf('Wanna delete %s and run again?\n', EDA_CC_FILE)
    prompt = input('y/N)?\n', 's');
    if strcmp(prompt, 'y')
        delete(EDA_CC_FILE);                
        return
    end
end
