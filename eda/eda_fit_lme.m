function [lmes] = eda_fit_lme
% try to explain variance of SCL data using linear mixed effect models

% Housekeeping
SAMPLE = 'behav';

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

% Settings
YVAR            = 's_zt_scl';
YVAR_ERROR      = strcat('sembj_',YVAR);

% FIT LME
% Grab raw data
d = readtable(EDA_FILE);
fprintf('successfully read in %s\n', EDA_FILE);

% Add mean corrected binary wm regressors
d.wm1 = d.wm == -1; % 1 when 1back, else 0
d.wm2 = d.wm == 1;  % 1 when 2back, else 0

d.wm1 = d.wm1 - mean(d.wm1);
d.wm2 = d.wm2 - mean(d.wm2);

% Check whether predictors are correlated
wavetablecorr(d);

% Append categorical variables
d.wm_c0 = categorical(d.wm, [0, -1, 1], {'notask','1back','2back'}); % no task is reference category
d.wm_c1 = categorical(d.wm, [-1, 0, 1], {'1back','notask','2back'}); % 1back is reference category
d.wm_c2 = categorical(d.wm, [1, 0, -1], {'2back','notask','1back'}); % 2back is reference category


% wavetablecorr(dc(dc.id == 7 & dc.microblock == 1, {'heat','wm','slope','heat_X_wm','heat_X_slope','wm_X_slope', 'heat_X_wm_X_slope'})); % mean correcting dc.slope does not reduce wm slope correlation

% % Only specify largest models by hand --> models are incorrect as we
% assume an intercept where there can't be one as the data is zscored. see
% correct way below
% LME_FORMULAS = {            
%     sprintf('%s~heat*wm_c0*slope+(1|id)+(heat|id)+(wm_c0|id)+(slope|id)', YVAR);... % with correlated slope and intercept for each parameter and extra id intercept
%     sprintf('%s~heat*wm_c1*slope+(1|id)+(heat|id)+(wm_c1|id)+(slope|id)', YVAR);...
%     sprintf('%s~heat*wm_c2*slope+(1|id)+(heat|id)+(wm_c2|id)+(slope|id)', YVAR)};

% rlme3 = fitlme(T,'s_zid_scl ~ 1 + heat*slope + heat*wm_c2 + slope*wm_c2 + heat:slope:wm_c2 + (-1 + heat | id) + (-1 + wm_c2 | id) + (-1 + slope | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)


% % Now split the formulas, extend them factor by factor and estimate them 
% LME_FORMULAS = split(LME_FORMULAS, '+');
% lmes = cell(size(LME_FORMULAS));
% aics = nan(size(LME_FORMULAS));
% bics = nan(size(LME_FORMULAS));
% for i = 1:size(LME_FORMULAS, 1) % category loop
%     for j = 1:size(LME_FORMULAS, 2) % random effect loop
%         complete_lme_forms{i,j} = strjoin(LME_FORMULAS(i,1:j),'+');
%         
%         fprintf('Starting to fit %s...', complete_lme_forms{i,j});
%         lmes{i,j} = fitlme(d, complete_lme_forms{i,j}, 'FitMethod', 'REML', 'StartMethod', 'random');        
%         fprintf('done.\n');
%         
%         aics(i,j) = lmes{i,j}.ModelCriterion.AIC;
%         bics(i,j) = lmes{i,j}.ModelCriterion.BIC;
%         
%         % Compare model to predecessor
%         if j > 1
%             comparisons{i,j-1} = compare(lmes{i,j-1}, lmes{i,j});
%         end                
%     end % effect loop end
%     
%     % Plot information criteria
%     subplot(1,3,i);
%     plot(aics(i,:)); hold on;
%     plot(bics(i,:)); 
%     
%     legend({'AIC','BIC'});
%     xlim([0 j]); xticks([1:j]); 
%     xticklabels(strrep(complete_lme_forms(i,:), '_',' '));    
%     xlabel('LME formula');
%     xtickangle(45);
%     ylabel('Model performance [AIC|BIC]');
%     ax = gca;
%     ax.FontSize = 10;                
%     title(sprintf...
%         ('%s sample: Model information criteria for wm_c%d', SAMPLE, i-1),...
%         'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
% end % category loop

% diffheat exploration
d.diffheat = zscore([0; diff(d.heat)]);
d.diffheat = d.diffheat./max(d.diffheat);
d.gradheat = gradient(d.heat);

d = movevars(d, 'diffheat','After', 'wm_c2');
d = movevars(d, 'slope','After', 'wm2');

% Create cropped version with inner slopes only
dc = d;
dc(d.time_within_trial < 22 | d.time_within_trial > 88, :) = [];

% Create cropped version with tasks only and discard online
Tc = dc;
Tc(Tc.wm_c0 == 'notask', :) = [];
Tc.wm_c0 = categorical(Tc.wm,[-1 1],{'1back','2back'});
Tc.wm_c1 = categorical(Tc.wm,[1 -1],{'2back','1back'});


% this is björns way and correct
LME_FORMULAS = {            
    sprintf('%s ~ 1 + heat*wm_c0*slope + (-1 + heat | id )', YVAR), ...
   sprintf('%s ~ 1 + heat*diffheat*wm_c0 + (-1 + heat | id )', YVAR),...
   sprintf('%s ~ 1 + heat*diffheat*wm_c1 + (-1 + heat | id )', YVAR),...
    sprintf('%s ~ 1 + heat + wm1 + wm2 + slope + heat*wm1 + heat*wm2 + heat*slope + wm1*slope + wm2*slope + heat*wm1*slope + heat*wm2*slope + (-1 + heat | id)', YVAR),...
    sprintf('%s ~ 1 + heat * wm * slope + (-1 + heat | id)', YVAR)};
    
lmes = struct;
for i = 1:numel(LME_FORMULAS)
    complete_lme_forms{i} = LME_FORMULAS{i};
    fprintf('Fitting %s\n...', complete_lme_forms{i});
    lmes.full{i} = fitlme(d, complete_lme_forms{i}, 'FitMethod', 'REML', 'StartMethod', 'random');
    lmes.cropped{i} = fitlme(dc, complete_lme_forms{i}, 'FitMethod', 'REML', 'StartMethod', 'random'); % cropped --> M --> V, W --> ^
    try
        lmes.diffheat_cropped{i} = fitlme(Tc, complete_lme_forms{i}, 'FitMethod', 'REML', 'StartMethod', 'random');
    catch
        fprintf('\ncould not fit %s to diffheat data\n', complete_lme_forms{i});
    end
    fprintf('...done.\n');
end

save(EDA_LME_FILE, 'lmes');