function eda_analysis

% SETTING OF CONSTANTS
SAMPLE   = 'behav'; % can be behav or fmri

% for fitted responses
LME_FORMULA             = 's_zt_scl~heat*wm_cat1*slope+(1|id)'; 
FITTED_RESPONSE_NAME    = 'fitted_s_zt_scl';

% for differences
DIFF_VAR                    = 's_zt_scl';
GROUPING_VARS               = {'id','trial','condition'};
% both slope difference bzw quotient. will be cast to usd and dsd (usq,dsq)
% respectively later
INPUT_VARS                  = {'bsd','bsq'}; 
SLOPE_SPECIFIC_COL_NAMES    = {'dsd','dsq'; 'usd','usq'};

% Housekeeping
HOST                = wave_ghost2(SAMPLE);
EDA_DIR             = fullfile(HOST.dir, 'eda');
EDA_TEMPLATE        = 'all_eda.csv';
EDA_C_TEMPLATE      = 'all_eda_c.csv'; % first level variance removed
EDA_CC_TEMPLATE     = 'all_eda_cc.csv'; % second level variance removed
EDA_LME_TEMPLATE    = 'all_eda_lme.mat';
EDA_BINNED_DIFF_TEMPLATE    = 'all_eda_binned_diff.csv';

EDA_FILE            = fullfile(EDA_DIR, EDA_TEMPLATE);
EDA_C_FILE          = fullfile(EDA_DIR, EDA_C_TEMPLATE);
EDA_CC_FILE         = fullfile(EDA_DIR, EDA_CC_TEMPLATE);
EDA_LME_FILE        = fullfile(EDA_DIR, EDA_LME_TEMPLATE);
EDA_BINNED_DIFF_FILE= fullfile(EDA_DIR, EDA_BINNED_DIFF_TEMPLATE);

% Check if source is available
if ~exist(EDA_FILE, 'file') % then we cannot do anything
    fprintf('Source file (%s) is missing. Aborting.\n', RAW_FILE)
    return
end

% Check if source file has fitted responses yet
data_in = readtable(EDA_FILE);
if ~any(strcmp(data_in.Properties.VariableNames, FITTED_RESPONSE_NAME))
    
    % Make sone categorical variables
    data_in.wm_cat1 = categorical(data_in.wm,...
        [0, -1, 1], {'no_task','1back','2back'});
    
    % Now we fit the lme, show it to the user and save it
    fprintf('Fitting lme to explain %s...', 'SCL'); 
    lme = fitlme(data_in,LME_FORMULA, 'FitMethod', 'REML');
    fprintf('done.\n');
    disp(lme);
    save(EDA_LME_FILE, 'lme');
    
    % Obtain fitted response 
    fitted_response = fitted(lme);
    
    % Write to output
    data_out = data_in;
    data_out{:, FITTED_RESPONSE_NAME} = fitted_response;
    writetable(data_out, EDA_FILE);
    fprintf('Added %s column to %s\n', FITTED_RESPONSE_NAME, EDA_FILE);        
end

% Check if EDA diff file exists yet
if ~exist(EDA_BINNED_DIFF_FILE, 'file')
    d = readtable(EDA_FILE);
    
    % Make tables for each segment and append them to struct
    S = struct;
    % First M segment
    S.m10 = d(d.wm == -1 & d.slope == -1 & d.condition == 2,:); 
    S.m20 = d(d.wm ==  1 & d.slope == -1 & d.condition == 1,:); %m21 2back    
    S.m10.bsd = m10.(DIFF_VAR) - m20.(DIFF_VAR); 
    S.m20.bsd = m10.(DIFF_VAR) - m20.(DIFF_VAR); 
    S.m10.bsq = m10.(DIFF_VAR) < m20.(DIFF_VAR); % when we mean this later we get the desired ratio
    S.m20.bsq = m10.(DIFF_VAR) < m20.(DIFF_VAR); % this is redundant but better safe than sorry
    
    % Second M segment
    S.m01 = d(d.wm == -1 & d.slope ==  1 & d.condition == 1,:); %m21 1back 
    S.m02 = d(d.wm ==  1 & d.slope ==  1 & d.condition == 2,:); 
    S.m01.bsd = m01.(DIFF_VAR) - m02.(DIFF_VAR); % negative values indicate 1back < 2back
    S.m02.bsd = m01.(DIFF_VAR) - m02.(DIFF_VAR);
    S.m01.bsq = m01.(DIFF_VAR) < m02.(DIFF_VAR); % values close to 1 indicate 1back < 2back
    S.m02.bsq = m01.(DIFF_VAR) < m02.(DIFF_VAR);
    
    % First W segment
    S.w20 = d(d.wm ==  1 & d.slope ==  1 & d.condition == 3,:); 
    S.w10 = d(d.wm == -1 & d.slope ==  1 & d.condition == 4,:); 
    S.w10.bsd = w10.(DIFF_VAR) - w20.(DIFF_VAR);
    S.w20.bsd = w10.(DIFF_VAR) - w20.(DIFF_VAR);
    S.w10.bsq = w10.(DIFF_VAR) < w20.(DIFF_VAR);
    S.w20.bsq = w10.(DIFF_VAR) < w20.(DIFF_VAR);
    
    % Second W segment   
    S.w02 = d(d.wm ==  1 & d.slope == -1 & d.condition == 4,:); 
    S.w01 = d(d.wm == -1 & d.slope == -1 & d.condition == 3,:); 
    S.w01.bsd = w01.(DIFF_VAR) - w02.(DIFF_VAR);
    S.w02.bsd = w01.(DIFF_VAR) - w02.(DIFF_VAR);
    S.w01.bsq = w01.(DIFF_VAR) < w02.(DIFF_VAR);
    S.w02.bsq = w01.(DIFF_VAR) < w02.(DIFF_VAR);    
   
    % Now loop over struct to apply function and append result to
    % repsective slope collector
    d_down  = table;
    d_up    = table;
    
    fn = fieldnames(S);
    for i = 1:numel(fn)        
        % Pick segment
        segment_name = fn{i};
        segment = S.(segment_name);        
        
        % Now collapse each segment to obtain vars of interest
        segment = varfun(@nanmean, segment, 'InputVariables', INPUT_VARS,...
            'GroupingVariables', GROUPING_VARS);       
         
        % Rename cols according to slope and append to segment collector
        if any(strcmp(segment_name, {'m10','m20','w01','w02'})) % down
            segment.Properties.VariableNames(5:6) =...
                SLOPE_SPECIFIC_COL_NAMES(1,:);
            d_down = vertcat(d_down, segment);
        elseif any(strcmp(segment_name, {'m01','m02','w10','w20'})) % up
            segment.Properties.VariableNames(5:6) =...
                SLOPE_SPECIFIC_COL_NAMES(2,:);
            d_up = vertcat(d_up, segment);
        else % there is nothing else
            error('this might be dangerous')
        end                     
    end
    
    % Assemble output file (one row per trial):
    d_up = sortrows(d_up, {'id','trial'});
    d_down = sortrows(d_down, {'id','trial'});
    
    % If all went well the data is now in idetical order as before and more
    % important d_up and d_down are parallel (same trial order) lets check
    if isequal(d_up.condition, d_down.condition)
        fprintf('d_up and d_down possess equal condition vectors. good.\n');
        d_down = [d_down, d_up.usd, d_up.usq];
        writetable(d_dow
    else
        error('messed up. keep your head up debugging is 50% of coding'9,
        
    end
    
    
    
end



% Collapse firstlevel variance
if ~exist(EDA_C_FILE, 'file')
    fprintf('%s is missing. Collapsing firstlevel variance.\n', EDA_C_FILE)
    
    % Grab raw data
    data_in = readtable(EDA_FILE);
    fprintf('Loaded %s\n', EDA_FILE);
    
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

% Collapse first and second level variance
if ~exist(EDA_CC_FILE, 'file')
    fprintf('%s is missing. Collapsing first- and secondlevel variance.\n', EDA_CC_FILE)
    
    % Grab first level collapsed data
    data_in = readtable(EDA_FILE);
    
    % Create complex column for sembj    
    data_in.id_dv = complex(data_in.id, data_in.s_zt_scl);    
    
    % Collapse everything but ID, shape and rating_counter    
    grouping_variables = {'condition', 'index_within_trial'};
    mean_data = varfun(@nanmean, data_in, 'GroupingVariables', grouping_variables);
    sem_data = varfun(@sembj, data_in,...,
        'InputVariables', {'id_dv'},...
        'GroupingVariables', grouping_variables);
    fprintf('Height of original DATA: %10d\n', height(data_in));
    fprintf('Height of mean DATA: %10d\n', height(mean_data));
    fprintf('Reduction factor: %f\n', height(data_in) / height(mean_data));
    
    % Get rid of mean_ prefix
    for i = 1:width(mean_data)
        mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'nanmean_','');
    end
    
    % Transfer interesting sem columns to mean DATA
    idx = contains(sem_data.Properties.VariableNames, 'dv');
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
