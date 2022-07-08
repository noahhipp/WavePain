function eda_analysis

% SETTING OF CONSTANTS
SAMPLE   = 'behav'; % can be behav or fmri

% for fitted responses
LME_FORMULA             = 's_zt_scl~heat*wm_cat1*slope+(1|id)';
FITTED_RESPONSE_NAME    = 'fitted_s_zt_scl';

% for zscores within session
TO_BE_ZSCORED_WITHIN_SESS_VAR       = 's_native_scl';
ZSCORED_WITHIN_SESS_VAR             = 's_zs_scl'; % shifted zscored within session 

% for zscores within id
TO_BE_ZSCORED_WITHIN_ID_VAR       = 's_native_scl';
ZSCORED_WITHIN_ID_VAR             = 's_zid_scl'; % shifted zscored within session 

% for AUC (=mean()) calculations
VOIS                        = {'zt_scl','s_zt_scl', 's_native_scl', 's_zs_scl', 's_zid_scl'}; % 
F                           = @nanmean;
F_NAME                      = functions(F).function;
GROUPING_VARS_NULL_MODEL    = {'id','trial','microblock','condition'};
GROUPING_VARS_SLOPE_AUC     = {'id','trial','microblock','condition', 'segment'};

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
EDA_TEMPLATE        = 'all_eda_sampled-at-half-a-hertz.csv';
[~, NAME, EXT]      = fileparts(EDA_TEMPLATE);
EDA_C_TEMPLATE      = strcat(NAME, '_c',EXT); % first level variance removed
EDA_CC_TEMPLATE     = strcat(NAME, '_cc',EXT); % second level variance removed
EDA_LME_TEMPLATE    = strcat(NAME, '_lme',EXT);
EDA_BINNED_DIFF_TEMPLATE    = strcat(NAME, '_binned_diff',EXT);
EDA_BINNED_TEMPLATE = strcat(NAME, '_binned',EXT);

OPR_TEMPLATE        = 'all_overall_ratings.csv';

EDA_FILE            = fullfile(EDA_DIR, EDA_TEMPLATE);
EDA_C_FILE          = fullfile(EDA_DIR, EDA_C_TEMPLATE);
EDA_CC_FILE         = fullfile(EDA_DIR, EDA_CC_TEMPLATE);
EDA_LME_FILE        = fullfile(EDA_DIR, EDA_LME_TEMPLATE);
EDA_BINNED_DIFF_FILE= fullfile(EDA_DIR, EDA_BINNED_DIFF_TEMPLATE);
EDA_BINNED_FILE     = fullfile(EDA_DIR, EDA_BINNED_TEMPLATE);
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

% Check if source file has zscored within ID EDA yet
if ~any(strcmp(data.Properties.VariableNames, ZSCORED_WITHIN_ID_VAR))
    data{:, ZSCORED_WITHIN_ID_VAR} = nan(height(data),1);
    ids = unique(data.id);
    for i = 1:numel(ids)
        id = ids(i);
        idx = data.id == id;
        data{idx, ZSCORED_WITHIN_ID_VAR}...
            = (data{idx, TO_BE_ZSCORED_WITHIN_ID_VAR}...
            -nanmean(data{idx, TO_BE_ZSCORED_WITHIN_ID_VAR}))...
            ./nanstd(data{idx, TO_BE_ZSCORED_WITHIN_ID_VAR});
        fprintf('zscored sub%03d\n',id);
    end
    writetable(data,EDA_FILE);                
end

% Check if source file has zscored within session EDA yet
if ~any(strcmp(data.Properties.VariableNames, ZSCORED_WITHIN_SESS_VAR))
    data{:, ZSCORED_WITHIN_SESS_VAR} = nan(height(data),1);
    ids = unique(data.id);
    for i = 1:numel(ids)
        id = ids(i);
        sessions = unique(data.session(data.id == id));
        for j = 1:numel(sessions)
            session = sessions(j);
            idx = data.id == id & data.session == session;
            data{idx, ZSCORED_WITHIN_SESS_VAR}...
                = (data{idx, TO_BE_ZSCORED_WITHIN_SESS_VAR}...
                -nanmean(data{idx, TO_BE_ZSCORED_WITHIN_SESS_VAR}))...
                ./nanstd(data{idx, TO_BE_ZSCORED_WITHIN_SESS_VAR});
            fprintf('zscored sub%03d session %d\n',id, session);
        end
    end
    writetable(data,EDA_FILE);                
end

% Check if source file has segment regressor yet
if 1 %~any(strcmp(data.Properties.VariableNames, 'segment'))
    % Add in segment regressor
        data.segment = repmat({'not of interest'}, height(data),1);
        data.segment(data.wm == -1 & data.slope == -1 & data.condition == 2)= {'m10'};
        data.segment(data.wm ==  1 & data.slope == -1 & data.condition == 1)= {'m20'}; 
        data.segment(data.wm == -1 & data.slope ==  1 & data.condition == 1)= {'m01'};
        data.segment(data.wm ==  1 & data.slope ==  1 & data.condition == 2)= {'m02'};
        data.segment(data.wm ==  1 & data.slope ==  1 & data.condition == 3)= {'w20'};
        data.segment(data.wm == -1 & data.slope ==  1 & data.condition == 4)= {'w10'};
        data.segment(data.wm ==  1 & data.slope == -1 & data.condition == 4)= {'w02'};
        data.segment(data.wm == -1 & data.slope == -1 & data.condition == 3)= {'w01'};
        data.segment = categorical(data.segment);
        writetable(data,EDA_FILE);                
end

% Check if EDA diff file exists yet
if ~exist(EDA_BINNED_FILE, 'file')
    d = readtable(EDA_FILE);
    d.segment = categorical(d.segment); % apparently this information is lost at read in
    col_names = d.Properties.VariableNames;
    d_opr = readtable(OPR_FILE);
    col_names_opr = d_opr.Properties.VariableNames;
    
    % Generate dummy trials for trials without partners for EDA and OPR
    if strcmp(SAMPLE, 'fmri')
        dummy_tbl   = table;
        dtbl_opr    = table;
        for i = 1:size(LONELY_TRIALS_INFO, 1)            
            % EDA
            lonely_trial = generate_dummy_trial(LONELY_TRIALS_INFO(i,:),col_names);
            dummy_tbl = vertcat(dummy_tbl, lonely_trial);
            
            % OPR
            lt_opr = generate_dummy_trial(LONELY_TRIALS_INFO(i,:),...
                col_names_opr, 1);
            dtbl_opr= vertcat(dtbl_opr, lt_opr);            
        end
        d = vertcat(d,dummy_tbl);
        d = sortrows(d, {'id','trial', 'index_within_trial'});           
        
        d_opr = vertcat(d_opr,dtbl_opr);
        d_opr = sortrows(d_opr, {'id','trial_number'});           
        
        % Discard ratings for trials without EDA
        d_opr((d_opr.id == 15 & d_opr.session == 1) |... % physio zu spät gestartet
            (ismember(d_opr.id,[18 19 20])) |... % those subs have no EDA
            (d_opr.condition > 4),:) = []; % delete all online rating trials
        
        d(d.condition > 4,:) = []; % delete all online rating trials
    end
    
    d(d.segment=='not of interest',:) = [];
    for i = 1:numel(VOIS)
        VOI = VOIS{i};
        
        % Null model: total AUC (which is euqivalent to scaled mean*t)
        % this table will already have the correct height (one row per
        % trial) so we do the other stuff now       
        d_null_model = varfun(F, d, 'InputVariables', VOI,...
            'GroupingVariables', GROUPING_VARS_NULL_MODEL);
        
        % Take care of slope AUC (aka slope means)        
        d_downauc = varfun(F, d(d.slope ==-1,:), 'InputVariables', VOI,...
            'GroupingVariables', GROUPING_VARS_SLOPE_AUC);
        
        d_upauc   = varfun(F, d(d.slope == 1,:), 'InputVariables', VOI,...
            'GroupingVariables', GROUPING_VARS_SLOPE_AUC);
        
        idx = ismember(d_null_model(:,1:4),d_upauc(:,1:4),'rows');
        d_null_model = d_null_model(idx,:);
        
        % Prepare new var names
        null_var = strcat('total_auc_',VOI);
        slope_var = strcat('slope_auc_',VOI);
        down_var = strcat('down_auc_',VOI);
        up_var = strcat('up_auc_',VOI);
        
        if i == 1
            d_opr = d_opr(idx,:);
        end
        
        % Add cols onto d_opr
        d_opr.(null_var) = d_null_model.([F_NAME, '_', VOI]);
        d_opr.(down_var) = d_downauc.([F_NAME, '_', VOI]);
        d_opr.(up_var) = d_upauc.([F_NAME, '_', VOI]);
        d_opr.(slope_var) = (d_upauc.([F_NAME, '_', VOI]) + d_downauc.([F_NAME, '_', VOI]))./2; % because we add 2 means we need to divide by 2
        
    end  
    writetable(d_opr, EDA_BINNED_FILE);
end
    
    
%     % Make tables for each segment and append them to struct
%     S = struct;
%     % First M segment
%     S.m10 = d(d.wm == -1 & d.slope == -1 & d.condition == 2,:);
%     S.m20 = d(d.wm ==  1 & d.slope == -1 & d.condition == 1,:); %m21 2back
%     [S.m10, S.m20] = wave_make_tables_same_height(S.m10, S.m20);
%     S.m10.both_slope_difference = S.m20.(VOI) - S.m10.(VOI);
%     S.m20.both_slope_difference = S.m20.(VOI) - S.m10.(VOI);
%     S.m10.both_slope_quotient   = S.m20.(VOI) > S.m10.(VOI);  % when we mean this later we get the desired ratio
%     S.m20.both_slope_quotient   = S.m20.(VOI) > S.m10.(VOI);  % this is redundant but better safe than sorry
%     
%     % Second M segment
%     S.m01 = d(d.wm == -1 & d.slope ==  1 & d.condition == 1,:); %m21 1back
%     S.m02 = d(d.wm ==  1 & d.slope ==  1 & d.condition == 2,:);
%     [S.m01, S.m02] = wave_make_tables_same_height(S.m01, S.m02);
%     S.m01.both_slope_difference = S.m02.(VOI) - S.m01.(VOI);
%     S.m02.both_slope_difference = S.m02.(VOI) - S.m01.(VOI);
%     S.m01.both_slope_quotient   = S.m02.(VOI) > S.m01.(VOI); %
%     S.m02.both_slope_quotient   = S.m02.(VOI) > S.m01.(VOI);
%     
%     % First W segment
%     S.w20 = d(d.wm ==  1 & d.slope ==  1 & d.condition == 3,:);
%     S.w10 = d(d.wm == -1 & d.slope ==  1 & d.condition == 4,:);
%     [S.w10, S.w20] = wave_make_tables_same_height(S.w10, S.w20);
%     S.w10.both_slope_difference = S.w20.(VOI) - S.w10.(VOI);
%     S.w20.both_slope_difference = S.w20.(VOI) - S.w10.(VOI);
%     S.w10.both_slope_quotient   = S.w20.(VOI) > S.w10.(VOI);
%     S.w20.both_slope_quotient   = S.w20.(VOI) > S.w10.(VOI);
%     
%     % Second W segment
%     S.w02 = d(d.wm ==  1 & d.slope == -1 & d.condition == 4,:);
%     S.w01 = d(d.wm == -1 & d.slope == -1 & d.condition == 3,:);
%     [S.w01, S.w02] = wave_make_tables_same_height(S.w01, S.w02);
%     S.w01.both_slope_difference = S.w02.(VOI) - S.w01.(VOI);
%     S.w02.both_slope_difference = S.w02.(VOI) - S.w01.(VOI);
%     S.w01.both_slope_quotient   = S.w02.(VOI) > S.w01.(VOI);
%     S.w02.both_slope_quotient   = S.w02.(VOI) > S.w01.(VOI);
%     
%     % Now loop over struct to apply function and append result to
%     % repsective slope collector
%     d_down  = table;
%     d_up    = table;
%     
%     fn = fieldnames(S);
%     for i = 1:numel(fn)
%         % Pick segment
%         segment_name = fn{i};
%         segment = S.(segment_name);
%         
%         % Now collapse each segment to obtain vars of interest
%         segment = varfun(@nanmean, segment, 'InputVariables', INPUT_VARS,...
%             'GroupingVariables', GROUPING_VARS);
%         
%         % Rename cols according to slope and append to segment collector
%         if any(strcmp(segment_name, {'m10','m20','w01','w02'})) % down
%             segment.Properties.VariableNames(6:7) =...
%                 SLOPE_SPECIFIC_COL_NAMES(1,:);
%             d_down = vertcat(d_down, segment);
%         elseif any(strcmp(segment_name, {'m01','m02','w10','w20'})) % up
%             segment.Properties.VariableNames(6:7) =...
%                 SLOPE_SPECIFIC_COL_NAMES(2,:);
%             d_up = vertcat(d_up, segment);
%         else % there is nothing else
%             error('this might be dangerous')
%         end
%         
%         
%     end
%     
%     % Assemble output file (one row per trial):
%     d_up = sortrows(d_up, {'id','trial'});
%     d_down = sortrows(d_down, {'id','trial'});
%     
%     % If all went well the data is now in idetical order as before and more
%     % important d_up and d_down are parallel (same trial order) lets check
%     if isequal(d_up.condition, d_down.condition)
%         fprintf('d_up and d_down possess equal condition vectors. good.\n');
%         
%         % Check again to be double safe and
%         % import the oprs to d_down
%         if isequal(d_up.condition, d_opr.condition)
%             fprintf('d_up and %s have equal condition vectors. good\n',...
%                 OPR_TEMPLATE);
%             
%             % Looks good we stick up_slope_difference and up_slope_quotient to d_down
%             d_down.up_slope_difference = d_up.up_slope_difference;
%             d_down.up_slope_quotient = d_up.up_slope_quotient;
%             
%             d_out = d_down;
%             
%             % and the OPRs
%             d_out.rating = d_opr.rating;
%             
%             % and the paired OPR difference (up slope - down slope
%             % attention)
%             d_out.microblock = d_opr.microblock;
%             d_out = sortrows(d_out, {'id','microblock','condition'});
%             
%             d_out.delta_rating = nan(height(d_out),1);
%             c1 = d_out(d_out.condition == 1,:);
%             c2 = d_out(d_out.condition == 2,:);
%             c3 = d_out(d_out.condition == 3,:);
%             c4 = d_out(d_out.condition == 4,:);
%             
%             d_out.delta_rating(d_out.condition == 1) = ...
%                 c1.rating - c2.rating;
%             d_out.delta_rating(d_out.condition == 2) = ...
%                 c1.rating - c2.rating;
%             d_out.delta_rating(d_out.condition == 3) = ...
%                 c4.rating - c3.rating;
%             d_out.delta_rating(d_out.condition == 4) = ...
%                 c4.rating - c3.rating;
%             
%             % Write output
%             d_out = sortrows(d_out, {'id','trial'});
%             writetable(d_out, EDA_BINNED_DIFF_FILE);
%             fprintf('Wrote %s\n', EDA_BINNED_DIFF_FILE);
%         else
%             error('difference in condition vector of %s and d_down',...
%                 OPR_TEMPLATE);
%         end
%     else
%         error('messed up. keep your head up debugging is 90% of coding')
%     end
% end
% 
% 
% 
% Collapse firstlevel variance
if ~exist(EDA_C_FILE, 'file')
    fprintf('%s is missing. Collapsing firstlevel variance.\n', EDA_C_FILE)
    
    % Grab raw data
    data_in = readtable(EDA_FILE);
    fprintf('Loaded %s\n', EDA_FILE);
    
    % Remove segment as its categorical and would cause errors
    data_in.segment = [];
    
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
    
    % Grab first level collapsed data and delete categorical cols
    data_in = readtable(EDA_FILE);
    data_in.segment = [];
    
    % Determine cols to calculate sembj for
    to_calc_sembj_idx = contains(data_in.Properties.VariableNames,...
        {'eda','scl'});
    to_calc_sembj_colnames ...
        = data_in.Properties.VariableNames(to_calc_sembj_idx);
    to_calc_sembj_colnames(2,:) = strcat('id_',to_calc_sembj_colnames(1,:));
    
    for i = 1:size(to_calc_sembj_colnames,2)
        dv_name     = to_calc_sembj_colnames{1,i};
        id_dv_name  = to_calc_sembj_colnames{2,i};
        
        data_in.(id_dv_name) = complex(data_in.id, data.(dv_name));
    end    
    
    % Collapse everything but ID, shape and rating_counter
    grouping_variables = {'condition', 'index_within_trial'};
    mean_data = varfun(@nanmean, data_in, 'GroupingVariables', grouping_variables);
    sem_data = varfun(@sembj, data_in,...,
        'InputVariables', to_calc_sembj_colnames(2,:),...
        'GroupingVariables', grouping_variables);
    fprintf('Height of original DATA: %10d\n', height(data_in));
    fprintf('Height of mean DATA: %10d\n', height(mean_data));
    fprintf('Reduction factor: %f\n', height(data_in) / height(mean_data));        
    
    % Transfer interesting sem columns to mean DATA
    idx = contains(sem_data.Properties.VariableNames, 'id');    
    mean_data = horzcat(mean_data, sem_data(:,idx));
    
    % Polish variable names    
    mean_data.Properties.VariableNames...
        = strrep(mean_data.Properties.VariableNames, 'nanmean_','');
    mean_data.Properties.VariableNames...
        = strrep(mean_data.Properties.VariableNames, '_id','');        
    
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
function tbl = generate_dummy_trial(lonely_trial, vars, varargin)

HEIGHT = 1100;
if nargin > 2
    HEIGHT = varargin{1};
end
WIDTH = numel(vars);

id = lonely_trial(1);
trial = lonely_trial(2);
condition = lonely_trial(3);

m = nan(HEIGHT, WIDTH);
tbl = array2table(m, 'VariableNames', vars);

onecol = ones(HEIGHT,1);
tbl.id = onecol.*id;


if any(strcmp(vars, 'trial_number'))
    tbl.trial_number = onecol.*trial;
else
    tbl.trial = onecol.*trial;
end
tbl.condition = onecol.*condition;
tbl.session = onecol.*ceil(trial/12);
tbl.microblock = onecol.*ceil(trial/4);

if any(strcmp(vars, 'segment'))
    tbl.segment = categorical(tbl.segment);
end


