function eda_lmes
% fit lmes to aggregated second level

% Housekeeping
eda_name_in      = 'all_eda_clean_downsampled_collapsed.csv';
[~,~,~,eda_dir] = wave_ghost;
eda_file_in       = fullfile(eda_dir, eda_name_in);

shift = -6;

% Read in data
data = readtable(eda_file_in);


data(data.condition > 4,:) = [];

dvs = {'zdt_scl', 'zdtm_scl'};
lmes = {};

for i = 1:numel(dvs)
    dv = dvs{i};
    data{:,dv} = circshift(data{:,dv}, -6);
    lme_form = sprintf('%s ~ heat*wm*slope + (1|ID)', dv);
    
    lme= fitlme(data, lme_form, 'FitMethod', 'REML')
    lmes{i} = lme;
    [~,~,stats] = fixedEffects(lme);
    
    eda_plot_betas(stats, lme_form); % 2:end as we exclude intercept        
end

function eda_plot_betas(stats, tit)

betas = stats.Estimate(2:end);
sem = stats.SE(2:end);

figure('Color','white');
y_label = 'LME Estimate +- SE';

pmod_names          = {'Heat', 'WM', 'Slope',...
    'Heat X WM', 'Heat X Slope','WM X Slope',...
    'Heat X WM X Slope'};


x = 1:numel(pmod_names);

b   = bar(x, betas);
b.FaceColor = [1 1 1];
b.LineWidth = 2;
hold on;
er  = errorbar(x, betas, sem);
er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 2;

xticklabels(pmod_names);
xticks(x);
ax = gca;
ax.FontSize = 14;
ax.XAxis.TickLabelInterpreter = 'none';
xtickangle(90);
xlabel('Beta', 'FontWeight', 'bold');
ylabel(y_label, 'FontWeight', 'bold');

 sgtitle(tit,'FontWeight', 'bold', 'FontSize',16, 'Interpreter', 'none');