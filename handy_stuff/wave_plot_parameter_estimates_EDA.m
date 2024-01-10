function wave_plot_parameter_estimates_EDA(lme1, lme2)
% Receives two lmes and plots the parameter estimates

% Check input
y1 = lme1.Coefficients.Estimate(2:end);
y2 = lme2.Coefficients.Estimate(2:end);

if numel(y1) ~= numel(y2)
    error('LMEs provided do not have equal number of variables. Aborting...');
end

sem1 = lme1.Coefficients.SE(2:end);
sem2 = lme2.Coefficients.SE(2:end);

% Settings
font_sizes  = [8 10 12];
fig_size    = [10 10];



x  = 1:numel(y1);
xlabels = {'heat','wm','diffheat',...
    'heat X wm', 'heat X diffheat', 'wm X diffheat',...
    'heat X wm X diffheat'};

WAVE_COLORS = wave_load_colors;
c = [0 0 0;... % no task
    WAVE_COLORS(2,:);... % 1back
    WAVE_COLORS(1,:)]; % 2back

% Plot bars
f = figure('Units', 'centimeters','Position', [10 10 fig_size]);
b = bar(x, [y1,y2], 'BarWidth', 0.9);

% Plot errorbars
hold on;
x1 = b(1).XEndPoints;
x2 = b(2).XEndPoints;
eb(1) = errorbar(x1, y1, sem1, 'k','LineStyle','none');
eb(2) = errorbar(x2, y2, sem2, 'k','LineStyle','none');




% Customize
b(1).FaceColor = c(2,:);
b(2).FaceColor = c(3,:);


xticklabels(xlabels)
ax = gca;
ax.XAxis.TickLabelRotation = 45;
xlabel('Predictor', 'FontWeight', 'bold');
ax.XAxis.FontSize = font_sizes(1);

ylabel('Parameter estimate [Zscores]', 'FontWeight', 'bold');
ax.YAxis.FontSize = font_sizes(1);

l = legend({'1back', '2back'});
l.Title.String = 'LME reference category';
l.FontSize = font_sizes(1);

title('Behavioural sample: LME parameter estimates',...
    'FontSize', font_sizes(3), 'FontWeight', 'bold');


