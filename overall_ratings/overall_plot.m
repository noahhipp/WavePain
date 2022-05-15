function overall_plot
% use fancy raincloudroutine to plot overall ratings

% Housekeeping
NAME_IN     = 'all_overall_fmri_collapsed.csv';
[~,~,~,~,~,BASE_DIR]    = wave_ghost();

DIR         = fullfile(BASE_DIR, 'overall_ratings');
FILE_IN     = fullfile(DIR, NAME_IN);
DATA = readtable(FILE_IN);


% Convert data to desired format
up_conds = [4 1];
down_conds = [2 3 ];
% up_conds = 1;
% down_conds = 2;
d{1} = DATA.rating(ismember(DATA.condition, up_conds));
d{2} = DATA.rating(ismember(DATA.condition, down_conds));

cb = wave_load_colors;

[~,p,ci,~] = ttest(d{1}, d{2});
fprintf('p-value: %f\nCI: %f %f\n', p, ci);
fprintf('Up mean: %f\nDown mean: %f\nMean diff: %f\n', mean(d{1}), mean(d{2}), mean(d{1}) - mean(d{2}));
fprintf('Mean difference (p=%.4f):\n%d VAS (90%% CI: [%d,%d])\n', p, round(mean(d{1}) - mean(d{2})), round(ci));


% driver code
figure('Color','white','Name','make it rain');
h1 = raincloud_plot(d{1}, 'box_on', 1, 'color', cb(5,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .35,...
     'box_col_match', 1);
h2 = raincloud_plot(d{2}, 'box_on', 1, 'color', [119, 221, 119]./255, 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .55, 'dot_dodge_amount', .75,...
     'box_col_match', 1);
l =legend([h1{1} h2{1}], {'up slope', 'down slope'}, 'Location','northwest');
l.Title.String = 'Attention on:';
l.FontSize = 12;
title(['N=47'], 'FontSize', 16,'FontWeight','bold');
box off

% customize it
xlim([0 100]);
xlabel('VAS','FontSize',14, 'FontWeight', 'bold');
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.TickValues = [];