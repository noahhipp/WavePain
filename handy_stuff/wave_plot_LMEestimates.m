function wave_plot_LMEestimates(lme)
% Takes in LME and plots estimates with:
% - bars for estimates
% - error bars for error
% - asterix for p value
% - xlabels according to predictor names

% Get data
y = lme.Coefficients.Estimate;
x = 1:numel(y);
err = lme.Coefficients.SE;

% Plot
figure;
b = bar(x, y); hold on;
eb = errorbar(x, y, err,...
    'LineStyle', 'none', 'Color', 'k', 'LineWidth', 2);

for i = 1:numel(x)
    text(i, y(i) - .03 - err(i), p2asterisk(lme.Coefficients.pValue(i)),...
        'Color', 'k','FontSize', 16, 'HorizontalAlignment', 'center');
end

% Configuration
xtl = lme.CoefficientNames;
xlabel('Coefficient name');
xticklabels(xtl);
xtickangle(45);
ylabel('Estimate [Zscores]');
title(char(lme.Formula), 'Interpreter', 'none');



