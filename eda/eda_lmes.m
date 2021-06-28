function [lme,data]=eda_lmes
% fit lmes to aggregated second level

% Housekeeping
[~,~,~,EDA_DIR] = wave_ghost();
EDA_NAME_IN     = 'all_eda_clean_downsampled01_collapsed.csv';
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);

% Read in data
data = readtable(EDA_FILE_IN);

% Get rid of conditions we dont want
data(data.condition > 4,:) = [];
data(data.wm == 0,:) = [];
data.time = data.time_within_trial -22.015;


% Cast to categorical
data.cwm_sort1 = categorical(data.wm, [-1 0 1], {'1back', 'nothing', '2back'});
data.cwm_sort2 = categorical(data.wm, [0 -1 1], { 'nothing', '1back', '2back'});
data.cwm_sort3 = categorical(data.wm, [-1 1], {'1back', '2back'});

% Shape regressor
try
    data.shape = data.shape -1; % to make it M 0 W 1
    data.cshape_sort1 = categorical(data.shape, [0,1], {'M','W'});
catch
    data.shape = nan(height(data),1);
    shape_vals = [0 1];
    data.shape(data.condition < 3) = shape_vals(1);
    data.shape(data.condition > 2) = shape_vals(2);
    data.cshape_sort1 = categorical(data.shape, shape_vals, {'M','W'});
end



% Center temp regressors
% data.c2vas0 = data.vas0 - mean(data.vas0);
% data.c2vas30 = data.vas30 - mean(data.vas30);
% data.c2vas60 = data.vas60 - mean(data.vas60);

% lme= fitlme(data, sprintf('%s ~ time+ diffheat*cwm_sort3 + (1|ID)+ (time-1|ID)', dv), 'FitMethod', 'REML')
% 
% 
% lme=fitlme(data, 's_zt_dtt_scl ~ time+ diffheat*cwm_sort3 + (1|ID)+ (time-1|ID)', 'FitMethod', 'REML')
% 
% With detrend
% lme=fitlme(data, 's_zt_dtt_scl ~ time+ diffheat*cwm_sort3 + (1|ID)', 'FitMethod', 'REML')
% 
% Without detrend
lme=fitlme(data, 's_zt_scl ~ time+ diffheat*cwm_sort3 + (1|ID)', 'FitMethod', 'REML') % shifted

lme=fitlme(data, 's_zt_scl ~ time+ cshape_sort1 + diffheat*cwm_sort3 + (time-1|ID) + (1|ID)', 'FitMethod', 'REML') % shifted
% lme=fitlme(data, 'zt_scl ~ time+ diffheat*cwm_sort3 + (1|ID)', 'FitMethod', 'REML') % not shifted

% With temps
% lme = fitlme(data,'s_zt_scl ~ time*c2vas0*c2vas60 + diffheat*cwm_sort3 + (time-1|ID)+ (1|ID)', 'FitMethod','REML')









































% dvs = {'native_scl'};
% lmes = {};
% 
% for i = 1:numel(dvs)
%     dv = dvs{i};
% %     data{:,dv} = nanshift(data{:,dv}, shift*F);
%     lme_form = sprintf('%s ~ time*diffheat*cwm_sort3 + (1|ID)+ (time-1|ID)', dv);
%     
%     lme= fitlme(data, lme_form, 'FitMethod', 'REML');
%     lmes{i} = lme;
%     [~,~,stats] = fixedEffects(lme);
%     
%     lme= fitlme(data, sprintf('%s ~ time+ diffheat*cwm_sort3 + (1|ID)+ (time-1|ID)', dv), 'FitMethod', 'REML')
%     lme= fitlme(data, sprintf('%s ~ time*diffheat*cwm_sort3 + (1|ID)', dv), 'FitMethod', 'REML')
%     lme= fitlme(data, sprintf('%s ~ time+diffheat*cwm_sort3 + (1|ID)', dv), 'FitMethod', 'REML')
%     lme= fitlme(data, sprintf('%s ~ time*diffheat*cwm_sort3 + (1|ID)+ (time-1|ID)', dv), 'FitMethod', 'REML')
%     lme= fitlme(data, sprintf('%s ~ time*diffheat*cwm_sort3 + (1|ID)+ (time-1|ID)', dv), 'FitMethod', 'REML')
%     
%     
%     
%     
%     
%     
%     
%     
%     eda_plot_betas(stats, lme_form); % 2:end as we exclude intercept        
% end

% function eda_plot_betas(stats, tit)
% 
% betas = stats.Estimate(2:end);
% sem = stats.SE(2:end);
% 
% figure('Color','white');
% y_label = 'LME Estimate +- SE';
% 
% pmod_names          = {'Heat', 'WM', 'Slope',...
%     'Heat X WM', 'Heat X Slope','WM X Slope',...
%     'Heat X WM X Slope'};
% 
% pmod_names          = {'Heat', 'Slope',...
%     'Heat X Slope'};
% 
% 
% x = 1:numel(pmod_names);
% 
% b   = bar(x, betas);
% b.FaceColor = [1 1 1];
% b.LineWidth = 2;
% hold on;
% er  = errorbar(x, betas, sem);
% er.Color = [0 0 0];
% er.LineStyle = 'none';
% er.LineWidth = 2;
% 
% xticklabels(pmod_names);
% xticks(x);
% ax = gca;
% ax.FontSize = 14;
% ax.XAxis.TickLabelInterpreter = 'none';
% xtickangle(90);
% xlabel('Beta', 'FontWeight', 'bold');
% ylabel(y_label, 'FontWeight', 'bold');
% 
%  sgtitle(tit,'FontWeight', 'bold', 'FontSize',16, 'Interpreter', 'none');