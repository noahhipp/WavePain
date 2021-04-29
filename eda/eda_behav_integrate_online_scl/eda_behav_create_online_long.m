function eda_behav_create_online_long
% The all_eda_behav.csv file does not include scl from online ratings. The
% scl from online ratings is not yet in tidy form. We retrieve a 3D
% concatentation of subject.sortScl (onlineScl: each subject has 4 columns that are
% always in the order of M W M W, regardless of actual presentation order
% in the experiment (is either MW <wm trials> WM or WM <wm trials> MW). The
% goal is to have a nice long form table in chronological order with
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
eda_name_out    = 'all_online_scl.csv';
[~,~,~, eda_dir] = wave_ghost('behav');
eda_file_in     = fullfile(eda_dir, eda_name_in);
eda_file_out    = fullfile(eda_dir, eda_name_out);

% Hardcode those ones
online_rating_file     = 'E:\wavepain\data\behav_sample\online_ratings\all_online_ratings_behav.csv';
overall_rating_file    = 'E:\wavepain\data\behav_sample\overall_ratings\all_overall_ratings.csv';

% Grab data
load(eda_file_in, 'onlineScl', 'subjects');
online_ratings = readtable(online_rating_file);
overall_ratings = readtable(overall_rating_file);









