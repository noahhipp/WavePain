 function eda_predict_lme
% recevies lmes and predicts values on dummy data that allows us to
% generate subject wise parameter estiamtes

% Housekeeping
SAMPLE = 'fmri';

HOST                = wave_ghost2(SAMPLE);
EDA_DIR             = fullfile(HOST.dir, 'eda');
EDA_TEMPLATE        = 'all_eda_sampled-at-half-a-hertz.csv';
[~, NAME, EXT]      = fileparts(EDA_TEMPLATE);
EDA_C_TEMPLATE      = strcat(NAME, '_c',EXT); % first level variance removed
EDA_CC_TEMPLATE     = strcat(NAME, '_cc',EXT); % second level variance removed
EDA_LME_TEMPLATE    = strcat(NAME, '_lme','.mat');
EDA_BINNED_DIFF_TEMPLATE    = strcat(NAME, '_binned_diff',EXT);
EDA_BINNED_TEMPLATE = strcat(NAME, '_binned',EXT);

EDA_FILE            = fullfile(EDA_DIR, EDA_TEMPLATE);
EDA_C_FILE          = fullfile(EDA_DIR, EDA_C_TEMPLATE);
EDA_CC_FILE         = fullfile(EDA_DIR, EDA_CC_TEMPLATE);
EDA_LME_FILE        = fullfile(EDA_DIR, EDA_LME_TEMPLATE);
EDA_BINNED_DIFF_FILE= fullfile(EDA_DIR, EDA_BINNED_DIFF_TEMPLATE);
EDA_BINNED_FILE     = fullfile(EDA_DIR, EDA_BINNED_TEMPLATE);
EDA_LME_FILE = fullfile(EDA_DIR, EDA_LME_TEMPLATE);

% Grab lmes
load(EDA_LME_FILE)

% just testing
lme = lmes{13};
ids = unique(lme.Variables.id);
tblnew = array2table(zeros(numel(ids),numel(lme.VariableNames)),...
    'VariableNames', lme.VariableNames);
tblnew.id = ids;








function table_new = generate_table_new(lme, predictors)
% receives lme and builds a table that if fed to predict(lme,table_new)
% allows inference of parameter estimates

ids = unique(lme.Variables.id);

% Prepare default block
block       = zeros(numel(ids), numel(predictors) + 1);
block       = array2table(block, 'VariableNames', ['id',predictors]);
block.id    = ids;

% Loop through predictors
table_new = table;








