function eda_lme
% try to explain variance of SCL data using linear mixed effect models

% Housekeeping
SAMPLE = 'fmri';

HOST                = wave_ghost2(SAMPLE);
EDA_DIR             = fullfile(HOST.dir, 'eda');
EDA_TEMPLATE        = 'all_eda_sampled-at-half-a-hertz.csv';
[~, NAME, EXT]      = fileparts(EDA_TEMPLATE);
EDA_C_TEMPLATE      = strcat(NAME, '_c',EXT); % first level variance removed
EDA_CC_TEMPLATE     = strcat(NAME, '_cc',EXT); % second level variance removed
EDA_LME_TEMPLATE    = strcat(NAME, '_lme',EXT);
EDA_BINNED_DIFF_TEMPLATE    = strcat(NAME, '_binned_diff',EXT);
EDA_BINNED_TEMPLATE = strcat(NAME, '_binned',EXT);

EDA_FILE            = fullfile(EDA_DIR, EDA_TEMPLATE);
EDA_C_FILE          = fullfile(EDA_DIR, EDA_C_TEMPLATE);
EDA_CC_FILE         = fullfile(EDA_DIR, EDA_CC_TEMPLATE);
EDA_LME_FILE        = fullfile(EDA_DIR, EDA_LME_TEMPLATE);
EDA_BINNED_DIFF_FILE= fullfile(EDA_DIR, EDA_BINNED_DIFF_TEMPLATE);
EDA_BINNED_FILE     = fullfile(EDA_DIR, EDA_BINNED_TEMPLATE);

% Settings
YVAR            = 's_zid_scl';
YVAR_ERROR      = strcat('sembj_',YVAR);

% FIT LME
% Grab raw data
d = readtable(EDA_FILE);
fprintf('successfully read in %s\n', EDA_FILE);

% Check whether predictors are correlated
wavetablecorr(d);
figure; % for model performance

% Append categorical variables
d.wm_c0 = categorical(d.wm, [0, -1, 1], {'notask','1back','2back'}); % no task is reference category
d.wm_c1 = categorical(d.wm, [-1, 0, 1], {'1back','notask','2back'}); % 1back is reference category
d.wm_c2 = categorical(d.wm, [1, 0, -1], {'2back','notask','1back'}); % 2back is reference category

% Only specify largest models by hand
LME_FORMULAS = {            
    sprintf('%s~heat*wm_c0*slope+(1|id)+(heat|id)+(wm_c0|id)+(slope|id)', YVAR);... % with correlated slope and intercept for each parameter and extra id intercept
    sprintf('%s~heat*wm_c1*slope+(1|id)+(heat|id)+(wm_c1|id)+(slope|id)', YVAR);...
    sprintf('%s~heat*wm_c2*slope+(1|id)+(heat|id)+(wm_c2|id)+(slope|id)', YVAR)};          

% Now split the formulas, extend them factor by factor and estimate them 
LME_FORMULAS = split(LME_FORMULAS, '+');
lmes = cell(size(LME_FORMULAS));
aics = nan(size(LME_FORMULAS));
bics = nan(size(LME_FORMULAS));
for i = 1:size(LME_FORMULAS, 1) % category loop
    for j = 1:size(LME_FORMULAS, 2) % random effect loop
        complete_lme_forms{i,j} = strjoin(LME_FORMULAS(i,1:j),'+');
        
        fprintf('Starting to fit %s...', complete_lme_forms{i,j});
        lmes{i,j} = fitlme(d, complete_lme_forms{i,j}, 'FitMethod', 'REML', 'StartMethod', 'random');        
        fprintf('done.\n');
        
        aics(i,j) = lmes{i,j}.ModelCriterion.AIC;
        bics(i,j) = lmes{i,j}.ModelCriterion.BIC;
        
        % Compare model to predecessor
        if j > 1
            comparisons{i,j-1} = compare(lmes{i,j-1}, lmes{i,j});
        end                
    end % effect loop end
    
    % Plot information criteria
    subplot(1,3,i);
    plot(aics(i,:)); hold on;
    plot(bics(i,:)); 
    
    legend({'AIC','BIC'});
    xlim([0 j]); xticks([1:j]); 
    xticklabels(strrep(complete_lme_forms(i,:), '_',' '));    
    xlabel('LME formula');
    xtickangle(45);
    ylabel('Model performance [AIC|BIC]');
    ax = gca;
    ax.FontSize = 10;                
    title(sprintf...
        ('%s sample: Model information criteria for wm_c%d', SAMPLE, i-1),...
        'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
end % category loop








