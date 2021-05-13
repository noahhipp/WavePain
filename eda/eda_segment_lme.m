function lme = eda_segment_lme
% Fit lme for segmented eda_data

% Housekeeping
[~,~,~,EDA_DIR] = wave_ghost();
EDA_NAME_IN     = 'all_eda_clean_downsampled10_collapsed_segmented.csv';
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);

% Import data
DATA = readtable(EDA_FILE_IN);

% Cast some rows to categorical
DATA.wmc1       = categorical(DATA.wm, [0 -1 1], {'no task', '1back', '2back'});
DATA.wmc2       = categorical(DATA.wm, [-1 1 0], {'1back', '2back', 'no task'});
DATA.wmc3       = categorical(DATA.wm, [-1 1], {'1back', '2back'});
% DATA.slopec1    = categorical(DATA.slope, [0 -1 1], {'flat', 'down','up'});
DATA.slopec1    = categorical(DATA.slope, [-1 1], { 'down','up'});
% DATA.segmentc1  = categorical(DATA.segment, [2:5 1 6], ...
%     {'short1','long1','long2','short2','lead_in','lead_out'});

% Only take middle segments
DATA = DATA(ismember(DATA.segment, [3,4]),:);

% Remove online
DATA(DATA.condition > 4,:) = [];

% Do LME
lme = fitlme(DATA, 's_zt_scl ~ wmc3*slopec1 + (1|ID)', 'FitMethod','REML')

% Without cat
lme = fitlme(DATA, 's_zt_scl ~ heat*wmc3*slopec1+ (1|ID)', 'FitMethod','REML')



lme = fitlme(DATA, fml, 'FitMethod','REML')
