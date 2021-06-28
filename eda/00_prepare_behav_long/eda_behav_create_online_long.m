function data = eda_behav_create_online_long
% The all_eda_behav.csv file does not include scl from online ratings. The
% scl from online ratings is not yet in tidy form. We retrieve a 3D
% concatentation of subject.sortScl (onlineScl: each subject has 4 columns that are
% always in the order of M W M W, regardless of actual presentation order
% in the experiment (is either MW <wm trials> WM or WM <wm trials> MW). The
% goal is to have a nice long form table in actual presentation order with
% columns:
% - ID
% - trial
% - condition (Monline --> 5, Wonline --> 6)
% - index_within_trial
% - time_within_trial
% - scl
% - heat
% - slope
% - heat_X_slope

% Housekeeping
eda_name_in     = 'all_online_scl_behav.mat';
eda_name_out    = 'all_online_scl_behav.csv';
[~,~,~, eda_dir] = wave_ghost('behav');
eda_file_in     = fullfile(eda_dir, eda_name_in);
eda_file_out    = fullfile(eda_dir, eda_name_out);

if exist(eda_file_out, 'file')
    data = 'nope';
    fprintf('To run this function again delete %s\n', eda_file_out);
    return
end

% Hardcode those ones
online_rating_file     = 'C:\Users\hipp\projects\WavePain\data\behav_sample\online_ratings\all_online_ratings_behav.csv';
overall_rating_file    = 'C:\Users\hipp\projects\WavePain\data\behav_sample\overall_ratings\all_overall_ratings.csv';

% Grab data. onlineScl is a 3D mat: row-->time, column->condition [M W
% M W], page->ID.
load(eda_file_in, 'onlineScl', 'subjects');
online_ratings = readtable(online_rating_file);
overall_ratings = readtable(overall_rating_file);

% Chop overlap off (5 samples = ~0.2s)
onlineScl = onlineScl(1:subject.minSclLength, :,:);

%=================PREPARE OUTPUT===========================================
ids     = unique(online_ratings.ID);
nancol  = nan(numel(onlineScl), 1);

% Wave and heat
[m, w]  = waveit2(subject.minSclLength);
m = m'; w=w'; % Transpose to column
m_slope = [0; diff(m)]; m_slope(m_slope > 0) = 1; m_slope(m_slope < 0) = -1;
w_slope = [0; diff(w)]; w_slope(m_slope > 0) = 1; w_slope(w_slope < 0) = -1;

data=table;
data.ID                 = repelem(ids, size(onlineScl,1) * size(onlineScl,2));
data.trial              = nancol; % this is what we have to figure out with the loop below
data.condition          = repmat(repelem([5 6 5 6], size(onlineScl,1)), 1, size(onlineScl,3))'; % 5->Monline, 6->Wonline
data.index_within_trial = repmat(1:size(onlineScl,1), 1, size(onlineScl,2) * size(onlineScl,3))';
data.time_within_trial  = repmat(linspace(0,110,size(onlineScl,1)), 1, size(onlineScl,2) * size(onlineScl,3))';
data.zdt_scl            = reshape(onlineScl, [],1);
data.heat               = repmat(vertcat(m, w, m, w), size(onlineScl,3),1);
data.wm                 = zeros(height(data),1); % just to be compatible with scl from working memory trials
data.slope              = repmat(vertcat(m_slope, w_slope, m_slope, w_slope), size(onlineScl,3),1);
data.heat_X_wm          = zeros(height(data),1);
data.heat_X_slope       = data.heat.*data.slope;
data.wm_X_slope         = zeros(height(data),1);
data.heat_X_wm_X_slope  = zeros(height(data),1);

for i = 1:numel(ids)
    id = ids(i);
    fprintf('\n==========sub%03d\n',id);
    
    % Grab subject data
    sub_data = data(data.ID == id, :);
    sub_online = online_ratings(online_ratings.ID == id,:);
    sub_overall = overall_ratings(overall_ratings.subject == id,:);
    
    % Retrieve original presentation order...
    shape = nan(1,4);
    for j = 1:4 % loop over trials
        shape(j) = unique(sub_online.shape(sub_online.trialNumber == j));        
    end
    
    % ...based on that correctly assing trials
    if isequal(shape,[1 2 2 1]) % If M W W M we need to assing the second W index 3 and 
            original_order = [1 2 4 3];            
    elseif isequal(shape, [2 1 1 2])
            original_order = [2 1 3 4];
    elseif isequal(shape,[1 2 1 2])
            original_order = [1 2 3 4];
    elseif isequal(shape,[2 1 2 1])
            original_order = [2 1 4 3];
    end                
    
    % Account for different number of total trials
    n_trials        = max(sub_overall.trialNumber);
    original_order  = original_order + [0 0 n_trials n_trials];
    
    % Inform user 
    fprintf('M W M W were presented at indices: %d %d %d %d\n', original_order);
    
    % Put data back in
    sub_data.trial = repelem(original_order, size(onlineScl,1))';
    data(data.ID == id,:) = sub_data;                           
end

% Sort rows correctly
data = sortrows(data, {'ID', 'trial', 'index_within_trial',}, 'ascend');

% Write output
writetable(data, eda_file_out);