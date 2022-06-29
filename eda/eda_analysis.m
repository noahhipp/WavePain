function eda_analysis

% SETTING OF CONSTANTS
SAMPLE   = 'fmri'; % can be behav or fmri

% for fitted responses
LME_FORMULA             = 's_zt_scl~heat*wm_cat1*slope+(1|id)';
FITTED_RESPONSE_NAME    = 'fitted_s_zt_scl';

% for zscores within session
TO_BE_ZSCORED_VAR       = 's_native_scl';
ZSCORED_VAR             = 's_zs_scl'; % shifted zscored within session 

% for differences
DIFF_VAR                    = 's_zt_scl';
GROUPING_VARS               = {'id','trial','microblock','condition'};
% both slope difference bzw quotient. will be cast to up_slope_difference and down_slope_difference (up_slope_quotient,down_slope_quotient)
% respectively later
INPUT_VARS                  = {'both_slope_difference','both_slope_quotient'};
SLOPE_SPECIFIC_COL_NAMES    = {'down_slope_difference',...
    'down_slope_quotient'; ...
    'up_slope_difference',...
    'up_slope_quotient'};

% Housekeeping
HOST                = wave_ghost2(SAMPLE);
EDA_DIR             = fullfile(HOST.dir, 'eda');
EDA_TEMPLATE        = 'all_eda.csv';
EDA_C_TEMPLATE      = 'all_eda_c.csv'; % first level variance removed
EDA_CC_TEMPLATE     = 'all_eda_cc.csv'; % second level variance removed
EDA_LME_TEMPLATE    = 'all_eda_lme.mat';
EDA_BINNED_DIFF_TEMPLATE    = 'all_eda_binned_diff.csv';
OPR_TEMPLATE        = 'all_overall_ratings.csv';

EDA_FILE            = fullfile(EDA_DIR, EDA_TEMPLATE);
EDA_C_FILE          = fullfile(EDA_DIR, EDA_C_TEMPLATE);
EDA_CC_FILE         = fullfile(EDA_DIR, EDA_CC_TEMPLATE);
EDA_LME_FILE        = fullfile(EDA_DIR, EDA_LME_TEMPLATE);
EDA_BINNED_DIFF_FILE= fullfile(EDA_DIR, EDA_BINNED_DIFF_TEMPLATE);
OPR_FILE            = fullfile(HOST.dir, 'overall_ratings',OPR_TEMPLATE);

% Take care of trials without partners
LONELY_TRIALS_INFO =... 
   [08, 22, 02;... % [id, trial, condition
    09, 22, 02;...
    43, 09, 04;...
    43, 19, 01;...
    44, 06, 02];

% Check if source is available
if ~exist(EDA_FILE, 'file') % then we cannot do anything
    fprintf('Source file (%s) is missing. Aborting.\n', EDA_FILE)
    return
end

% Check if source file has fitted responses yet
data = readtable(EDA_FILE);
if 0 % turned off for now as the module is severly overfitted
    if ~any(strcmp(data.Properties.VariableNames, FITTED_RESPONSE_NAME))
        
        % Make sone categorical variables
        data.wm_cat1 = categorical(data.wm,...
            [0, -1, 1], {'no_task','1back','2back'});
        
        % Now we fit the lme, show it to the user and save it
        fprintf('Fitting lme to explain %s...', 'SCL');
        lme = fitlme(data,LME_FORMULA, 'FitMethod', 'REML');
        fprintf('done.\n');
        disp(lme);
        save(EDA_LME_FILE, 'lme');
        
        % Obtain fitted response
        fitted_response = fitted(lme);
        
        % Write to output
        data = data_in;
        data{:, FITTED_RESPONSE_NAME} = fitted_response;
        writetable(data, EDA_FILE);
        fprintf('Added %s column to %s\n', FITTED_RESPONSE_NAME, EDA_FILE);
    end
end

% Check if source file has zscored within session EDA yet
if ~any(strcmp(data.Properties.VariableNames, FITTED_RESPONSE_NAME))
    data{:, ZSCORED_VAR} = nan(height(data),1);
    ids = unique(data.id);
    for i = 1:numel(ids)
        id = ids(i);
        sessions = unique(data.session(data.id == id));
        for j = 1:numel(sessions)
            session = sessions(j);
            idx = data.id == id & data.session == session;
            data{idx, ZSCORED_VAR}...
                = (data{idx, TO_BE_ZSCORED_VAR}...
                -nanmean(data{idx, TO_BE_ZSCORED_VAR}))...
                ./nanstd(data{idx, TO_BE_ZSCORED_VAR});
            fprintf('zscored sub%03d session %d\n',id, session);
        end
    end
    writetable(data,EDA_FILE);                
end

% Check if EDA diff file exists yet
if ~exist(EDA_BINNED_DIFF_FILE, 'file')
    d = readtable(EDA_FILE);
    col_names = d.Properties.VariableNames;
    d_opr = readtable(OPR_FILE);
    
    % Generate dummy trials for trials without partners
    if strcmp(SAMPLE, 'fmri')
        dummy_tbl = table;
        for i = 1:size(LONELY_TRIALS_INFO, 1)
            lonely_trial = generate_dummy_trial(LONELY_TRIALS_INFO(i,:),col_names);
            dummy_tbl = vertcat(dummy_tbl, lonely_trial);
        end
        d = vertcat(d,dummy_tbl);
        d = sortrows(d, {'id','trial','index_within_trial'});           
        
        % Discard ratings for trials without EDA
        d_opr((d_opr.id == 15 & d_opr.session == 1) |... % physio zu spät gestartet
            (ismember(d_opr.id,[18 19 20])) |... % those subs have no EDA
            (d_opr.condition > 4),:) = []; % delete all online rating trials
    end
    
    
    
    
    
    
    
    
    % Make tables for each segment and append them to struct
    S = struct;
    % First M segment
    S.m10 = d(d.wm == -1 & d.slope == -1 & d.condition == 2,:);
    S.m20 = d(d.wm ==  1 & d.slope == -1 & d.condition == 1,:); %m21 2back
    [S.m10, S.m20] = wave_make_tables_same_height(S.m10, S.m20);
    S.m10.both_slope_difference = S.m20.(DIFF_VAR) - S.m10.(DIFF_VAR);
    S.m20.both_slope_difference = S.m20.(DIFF_VAR) - S.m10.(DIFF_VAR);
    S.m10.both_slope_quotient   = S.m20.(DIFF_VAR) > S.m10.(DIFF_VAR);  % when we mean this later we get the desired ratio
    S.m20.both_slope_quotient   = S.m20.(DIFF_VAR) > S.m10.(DIFF_VAR);  % this is redundant but better safe than sorry
    
    % Second M segment
    S.m01 = d(d.wm == -1 & d.slope ==  1 & d.condition == 1,:); %m21 1back
    S.m02 = d(d.wm ==  1 & d.slope ==  1 & d.condition == 2,:);
    [S.m01, S.m02] = wave_make_tables_same_height(S.m01, S.m02);
    S.m01.both_slope_difference = S.m02.(DIFF_VAR) - S.m01.(DIFF_VAR);
    S.m02.both_slope_difference = S.m02.(DIFF_VAR) - S.m01.(DIFF_VAR);
    S.m01.both_slope_quotient   = S.m02.(DIFF_VAR) > S.m01.(DIFF_VAR); %
    S.m02.both_slope_quotient   = S.m02.(DIFF_VAR) > S.m01.(DIFF_VAR);
    
    % First W segment
    S.w20 = d(d.wm ==  1 & d.slope ==  1 & d.condition == 3,:);
    S.w10 = d(d.wm == -1 & d.slope ==  1 & d.condition == 4,:);
    [S.w10, S.w20] = wave_make_tables_same_height(S.w10, S.w20);
    S.w10.both_slope_difference = S.w20.(DIFF_VAR) - S.w10.(DIFF_VAR);
    S.w20.both_slope_difference = S.w20.(DIFF_VAR) - S.w10.(DIFF_VAR);
    S.w10.both_slope_quotient   = S.w20.(DIFF_VAR) > S.w10.(DIFF_VAR);
    S.w20.both_slope_quotient   = S.w20.(DIFF_VAR) > S.w10.(DIFF_VAR);
    
    % Second W segment
    S.w02 = d(d.wm ==  1 & d.slope == -1 & d.condition == 4,:);
    S.w01 = d(d.wm == -1 & d.slope == -1 & d.condition == 3,:);
    [S.w01, S.w02] = wave_make_tables_same_height(S.w01, S.w02);
    S.w01.both_slope_difference = S.w02.(DIFF_VAR) - S.w01.(DIFF_VAR);
    S.w02.both_slope_difference = S.w02.(DIFF_VAR) - S.w01.(DIFF_VAR);
    S.w01.both_slope_quotient   = S.w02.(DIFF_VAR) > S.w01.(DIFF_VAR);
    S.w02.both_slope_quotient   = S.w02.(DIFF_VAR) > S.w01.(DIFF_VAR);
    
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
            segment.Properties.VariableNames(6:7) =...
                SLOPE_SPECIFIC_COL_NAMES(1,:);
            d_down = vertcat(d_down, segment);
        elseif any(strcmp(segment_name, {'m01','m02','w10','w20'})) % up
            segment.Properties.VariableNames(6:7) =...
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
        
        % Check again to be double safe and
        % import the oprs to d_down
        if isequal(d_up.condition, d_opr.condition)
            fprintf('d_up and %s have equal condition vectors. good\n',...
                OPR_TEMPLATE);
            
            % Looks good we stick up_slope_difference and up_slope_quotient to d_down
            d_down.up_slope_difference = d_up.up_slope_difference;
            d_down.up_slope_quotient = d_up.up_slope_quotient;
            
            d_out = d_down;
            
            % and the OPRs
            d_out.rating = d_opr.rating;
            
            % and the paired OPR difference (up slope - down slope
            % attention)
            d_out.microblock = d_opr.microblock;
            d_out = sortrows(d_out, {'id','microblock','condition'});
            
            d_out.delta_rating = nan(height(d_out),1);
            c1 = d_out(d_out.condition == 1,:);
            c2 = d_out(d_out.condition == 2,:);
            c3 = d_out(d_out.condition == 3,:);
            c4 = d_out(d_out.condition == 4,:);
            
            d_out.delta_rating(d_out.condition == 1) = ...
                c1.rating - c2.rating;
            d_out.delta_rating(d_out.condition == 2) = ...
                c1.rating - c2.rating;
            d_out.delta_rating(d_out.condition == 3) = ...
                c4.rating - c3.rating;
            d_out.delta_rating(d_out.condition == 4) = ...
                c4.rating - c3.rating;
            
            % Write output
            d_out = sortrows(d_out, {'id','trial'});
            writetable(d_out, EDA_BINNED_DIFF_FILE);
            fprintf('Wrote %s\n', EDA_BINNED_DIFF_FILE);
        else
            error('difference in condition vector of %s and d_down',...
                OPR_TEMPLATE);
        end
    else
        error('messed up. keep your head up debugging is 90% of coding')
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


% Subfunctions
function tbl = generate_dummy_trial(lonely_trial, vars)

HEIGHT = 1100;
WIDTH = numel(vars);

id = lonely_trial(1);
trial = lonely_trial(2);
condition = lonely_trial(3);

m = nan(HEIGHT, WIDTH);
tbl = array2table(m, 'VariableNames', vars);

onecol = ones(HEIGHT,1);
tbl.id = onecol.*id;
tbl.trial = onecol.*trial;
tbl.condition = onecol.*condition;
tbl.session = onecol.*ceil(trial/12);
tbl.microblock = onecol.*ceil(trial/4);


