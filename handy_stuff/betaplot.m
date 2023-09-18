function betaplot(lme)
% Receives lme and nicely bar plots fixed Effects
FIG_DIMS        = [8.8 5];

data    = lme.fixedEffects;
err     = lme.Coefficients.SE;

xlabels = lme.CoefficientNames;
xlabels = strrep(xlabels, '_',' ');
x       = 1:numel(xlabels);


fig = figure('Color','white', 'Units', 'centimeters',...
            'Position', [10 10 FIG_DIMS]);

b = bar(x,data);
b.FaceColor = [1 1 1];

hold on;

er = errorbar(x,data,err,err);
er.Color = [0 0 0];
er.LineStyle = 'none';

ax = gca;
xticklabels(xlabels);
xtickangle(45);
ax.XAxis.FontSize = 8;

title('LME beta weights');
