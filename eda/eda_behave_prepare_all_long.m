function eda_behave_prepare_all_long
% Prepare all_eda_behav.csv for merge with all_online_scl_behav.csv. We
% have to:
% - change column names (ID, trial condition, index_within_trial,
% time_within_trial, zdt_scl, heat, wm, slope, <interactions>
%
% - CHANGE CONDITION NAMES (VERY IMPORTANT): see subject and fubject for
% difference

% Housekeeping
eda_name_in     = 'wm_eda_behav_old_variable_names.csv'; % This gets overwritten at the end
eda_name_out    = 'wm_eda_behav.csv'; % We use this to backup the old data
[~,~,~, eda_dir] = wave_ghost('behav');
eda_file_in     = fullfile(eda_dir, eda_name_in);
eda_file_out    = fullfile(eda_dir, eda_name_out);

if exist(eda_file_out, 'file')
    data = 'nope';
    fprintf('To run this function again delete %s\n', eda_file_out);
    return
end

subject.minSclLength = 2767;


% Grab data
original_data = readtable(eda_file_in);

% Drop control conditions
original_data(original_data.conditionID > 4,:) = [];

% Change condition names (add 10 to avoid logical indexing conflicts eg
% 1->2, then if we want to change 2s we also change old 1s
convs = [1 12; 2 11; 3 14; 4 13]; % change ID 1->12, 2->11 etc.
original_data = colsub(original_data, 'conditionID', convs);

% Change attention bzw wm regressor encoding
convs = [1 10; 0 9; -1 11];
original_data = colsub(original_data, 'attention', convs);

% Correct trial numbers because starting at sub015 there were 2 online
% trials preceding the experiment
original_data.trialNumber(original_data.subject >= 15)...
    = original_data.trialNumber(original_data.subject >= 15) +2;

% Correct wave regressor
[m,w] = waveit2(subject.minSclLength);
original_data.heat(original_data.conditionID < 3) =...
    repmat(m,1,sum(original_data.conditionID < 3) / numel(m))';
original_data.heat(original_data.conditionID > 2) =...
    repmat(w,1,sum(original_data.conditionID > 2) / numel(w))';

% Make slope regressor
slope = vertcat(0, diff(original_data.heat));
slope(slope < 0) = -1;
slope(slope > 0) = 1;

% Prepare new data
data = table;
data.ID                 = original_data.subject;
data.trial              = original_data.trialNumber;
data.condition          = original_data.conditionID;
n_trials                = height(data) / subject.minSclLength;
data.index_within_trial = repmat(1:subject.minSclLength, 1, ...
    n_trials)';
data.time_within_trial  = repmat(linspace(0,110,subject.minSclLength),1,...
    n_trials)';
data.native_scl            = original_data.scl;
data.heat               = original_data.heat;
data.wm                 = original_data.attention;
data.slope              = slope;
data.heat_X_wm          = data.heat.* data.wm;
data.heat_X_slope       = data.heat.*data.slope;
data.wm_X_slope         = data.wm.*data.slope;
data.heat_X_wm_X_slope  = data.heat.*data.wm.*data.slope;

% Write output
writetable(data, eda_file_out);
fprintf('Wrote %s\nwith %d lines\n', eda_file_out, height(data));


function tbl = colsub(tbl, col, convs)
for i = 1:size(convs,1)
    to_change = tbl{:,col} == convs(i,1);
    tbl{to_change,col} = convs(i,2);    
end
tbl{:,col} = tbl{:,col} -10;