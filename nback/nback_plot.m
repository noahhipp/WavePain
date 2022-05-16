function nback_plot
% % use fancy raincloudroutine to plot nback performance

% Settings
SAMPLE          = 'behav'; % can be 'behav' or 'fMRI'
XVAR            = 'rt';
LEGEND_OFF      = 'legend_on'; % 'legend_off' turns it off else on

HUE             = 'task';
HUE_NAMES       = {'1-back', '2-back'};
HUE1            = 1;
HUE2            = 2;

HOST            = wave_ghost2(SAMPLE); %wave_gethost
NAME            = sprintf('%s_nback_%s_by_%s_%s',...
                SAMPLE, XVAR, HUE, LEGEND_OFF);
FIG_DIR         = fullfile(HOST.results,...
                '2022_05_13_nback_performance');
FNAME           = fullfile(FIG_DIR, NAME);

% Figure
FIG_DIMS        = [8.8 5];

% Colors
CB              = wave_load_colors;         
ALPHA           = .5;
if strcmp(HUE, 'slope')
    CB = [0 0 0; .6 .6 .6];
end

% Legend
L_FONTSIZE      = 8;

% Title
T_FONTSIZE      = 10;
T_FONTWEIGHT    = 'bold';

% XAxis
switch XVAR
    case 'rt'
        XL      = 'reaction time [s]';
    case 'd'
        XL      = 'd prime';
end
XL_FONTSIZE     = 8;
XL_FONTWEIGHT   = 'bold';
XA_FONTSIZE     = 8;

% HOUSEKEEPING
NAMES = {   'all_nback.csv',...
            'all_nback_slope_collapsed.csv',...
            'all_nback_slope_collapsed_collapsed.csv',...
            'all_nback_slope_collapsed_collapsed_c.csv'};        

DIR     = fullfile(HOST.dir, 'nback');
FILES   = fullfile(DIR, NAMES);

 % Grab data
 data = cell(numel(NAMES),1);
 i = 0;
 for file = FILES
     i = i + 1;
     data{i} = readtable(FILES{i});
 end  
 
 % Plot reaction times 
 % 1b vs 2b
 
 % Collect data
 d      = data{3}; 
 d1  = d{d{:,HUE} == HUE1, XVAR};
 d2  = d{d{:,HUE} == HUE2, XVAR};
 
% Stats first
[~,p,ci,~] = ttest(d1, d2);
fprintf('p-value: %f\nCI: %f %f\n', p, ci);
fprintf('1-back mean: %.3f\n2-back mean: %.3f\n',...
    nanmean(d1), nanmean(d2));
fprintf('Mean difference (p=%.3f): %.3f seconds (90%% CI: [%.3f,%.3f])\n',...
    p, nanmean(d1) - nanmean(d2), ci);

% Kickout nans
d1(isnan(d1)) = [];
d2(isnan(d2)) = [];

% driver code
figure('Color','white',...
    'Units', 'centimeters', 'Position', [10 10 FIG_DIMS]);

h1 = raincloud_plot(d1, 'box_on', 1, 'color', CB(2,:), 'alpha', ALPHA,...
     'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .3,...
     'box_col_match', 1);
 
h2 = raincloud_plot(d2, 'box_on', 1, 'color', CB(1,:), 'alpha', ALPHA,...
     'box_dodge', 1, 'box_dodge_amount', .5, 'dot_dodge_amount', .65,...
     'box_col_match', 1);
 
% Legend 
if ~strcmp(LEGEND_OFF, 'legend_off')
        l =legend([h1{1} h2{1}], HUE_NAMES, 'Location','best');
        l.Title.String = '';
        l.FontSize = L_FONTSIZE;
end

% Title
if strcmp(SAMPLE, 'behav')
    T = 'Behavioural sample';
elseif strcmp(SAMPLE, 'fmri') || strcmp(SAMPLE, 'fMRI')
    T = 'fMRI sample';
else
    error("Sample not recognized, must be 'behav' or 'fmri'");
end
title(T, 'FontSize', T_FONTSIZE,'FontWeight',T_FONTWEIGHT);
box off

% Axis
xlabel(XL,'FontSize',XL_FONTSIZE, 'FontWeight', XL_FONTWEIGHT);
ax = gca;
ax.XAxis.FontSize = XA_FONTSIZE;
ax.YAxis.TickValues = [];

% ylim([-1 1.5])

% Save
print(FNAME, '-dpng','-r300');
fprintf('Printed %s.png\n\n', FNAME);