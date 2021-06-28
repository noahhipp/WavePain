function eda_cb_lme
% Sets up one individual heat*wm*slope model for each participants. Write
% betas to table. Run ANOVA on them. Plot fitted response.

% Housekeeping
EDA_NAME_IN     = 'all_eda_behav_downsampled01.csv';
[~,~,~,EDA_DIR] = wave_ghost('behav');
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);

EDA_NAME_OUT    = 'fmri_betas.csv';
EDA_FILE_OUT     = fullfile(EDA_DIR, EDA_NAME_OUT);

% Avoid double work
if exist(EDA_FILE_OUT, 'file')
    lme_betas = readtable(EDA_FILE_OUT);
else
    % run one modell per participant
    DATA = readtable(EDA_FILE_IN);
    lme_betas = [];
    col_names = {'ID','heat','wm','slope','heat_X_wm','heat_X_slope','wm_X_slope','heat_X_wm_X_slope'...
        'online_heat','online_slope','online_heat_X_slope'};
    
    for i = unique(DATA.ID)'
        fprintf('\n\n doing sub%03d\n',i);
        
        % Slice data
        wm_data = DATA(DATA.ID == i & DATA.condition < 5,:);
        online_data = DATA(DATA.ID == i & DATA.condition > 4,:);
        
        % Estimate lmes and retrieve betas
        wm_lme = fitlme(wm_data,'s_zt_scl ~ heat*wm*slope','FitMethod','REML');
        wm_betas = fixedEffects(wm_lme);        
        try  % The first 4 behav subs don't have online scl yet
            online_lme = fitlme(online_data, 's_zt_scl ~ heat*slope','FitMethod','REML');
            online_betas = fixedEffects(online_lme);
        catch
            online_betas = nan(4,1);
        end                
        
        % Convert to table and append to output
        sub_betas = array2table([i, wm_betas(2:end)', online_betas(2:end)'],...
            'VariableNames', col_names);        
        lme_betas = vertcat(lme_betas, sub_betas);                        
        disp(sub_betas);    
    end    
    
    % Write output
    writetable(lme_betas, EDA_FILE_OUT);
end
      

% ================= ANOVA START============================================
% ================= ANOVA END==============================================

% ================= ttest START============================================
% ================= ttest END==============================================
% ================= PLOTTING START==================================
col_names = {'ID','heat','wm','slope','heat_X_wm','heat_X_slope','wm_X_slope','heat_X_wm_X_slope'...
        'online_heat','online_slope','online_heat_X_slope'};

mean_betas = varfun(@nanmean, lme_betas);
betas      = mean_betas{:,2:end};

sem_betas = varfun(@sem, lme_betas);
sem_betas = sem_betas{:,2:end};

% Bar plot betas
pmod_names          = col_names(2:end);    
x                   = 1:numel(pmod_names);

figure;
grid on;

b   = bar(x(1:7), betas(1:7)); hold on;
b.FaceColor = [1 1 1];
b.LineWidth = 2;
er  = errorbar(x(1:7), betas(1:7), sem_betas(1:7));
er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 2;    

xticklabels(pmod_names(1:7));
xticks(x);
xlim([.5 7.5])
ax = gca;
ax.FontSize = 14;
ax.XAxis.TickLabelInterpreter = 'none';
xtickangle(45);
xlabel('Betas', 'FontWeight', 'bold');
ylabel('Parameter estimates', 'FontWeight','bold');
ylim([-.1 .4]);

% Wave plot fitted response

% load design matrix
load(fullfile(EDA_DIR,'xX.mat'),'A');

% get fitted responses
disp(betas);
betas = betas';
wm_response = A.wm * betas(1:7);
online_response = A.online * betas(8:end);

% reshape for plotting
wm_response = reshape(wm_response',[],4);
online_response = reshape(online_response',[],2);

figure('Color', 'white', 'Name','fitted scl_response');
condition_names = {'M21','M12', 'W21','W12','Monline','Wonline'};

responses = [wm_response, online_response];
porder = [1 1 2 2 3 4];
for i = 1:6
    subplot(2,2,porder(i)); hold on;
    waveplot(responses(:,i), condition_names{i});    
    title(condition_names{i});
    wavexaxis;
end












% ================= PLOTTING END====================================


% Sem function
function out = sem(in)
out = nanstd(in)./sum(~isnan(in));
