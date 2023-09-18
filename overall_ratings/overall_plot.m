function overall_plot
% % use fancy raincloudroutine to plot nback performance

% Settings
SAMPLE          = 'fmri'; % can be 'behav' or 'fMRI'
XVAR            = 'rating';
LEGEND_OFF      = 'legend_on'; % 'legend_off' turns it off else on

HUE             = 'condition';
HUE_NAMES       = {'Up slope', 'Down slope'};
HUE1            = [1 4];
HUE2            = [2 3];

ZVAR            = 'shape';
ZVAR_NAMES      = {'M-shape','W-shape'};
ZVAR_VALS       = [1 2];


HOST            = wave_ghost2(SAMPLE); %wave_gethost
NAME            = sprintf('_%s_%s_by_%s_',SAMPLE, XVAR, HUE);
FIG_DIR             = fullfile(HOST.results, '2022_05_16_overall_ratings');
if ~exist(FIG_DIR, 'dir')
    mkdir(FIG_DIR)
end
FNAME           = fullfile(FIG_DIR,NAME);

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
    case 'rating'
        XL      = 'pain [VAS]';
end
XL_FONTSIZE     = 8;
XL_FONTWEIGHT   = 'bold';
XA_FONTSIZE     = 8;
XA_TICKS        = [0 50 100];

% YAxis
YL              = '';
YLIMS           = [-.02 .025];
YA_TICKS        = [];

% HOUSEKEEPING
NAMES = {   'all_overall_ratings.csv',...
    'all_overall_ratings_c.csv',...
    'all_overall_ratings_cc.csv'};

DIR     = fullfile(HOST.dir, 'overall_ratings');
FILES   = fullfile(DIR, NAMES);

% Grab data
data = cell(numel(NAMES),1);
i = 0;
for file = FILES
    i = i + 1;
    data{i} = readtable(FILES{i});
end

% Plot ratings
% attention on up slope vs down slope

% shape loop start (figure level)
for i = 1:numel(ZVAR_VALS)
    
    % Collect data
    d      = data{2};
    d1  = d{d{:,HUE} == HUE1(i), XVAR};
    d2  = d{d{:,HUE} == HUE2(i), XVAR};
    
    % Stats first
    [~,p,ci,~] = ttest(d1, d2);
    fprintf('p-value: %f\nCI: %f %f\n', p, ci);
    fprintf('%s mean: %.3f\n%s mean: %.3f\n',...
        HUE_NAMES{1}, nanmean(d1),HUE_NAMES{2}, nanmean(d2));
    fprintf('Mean difference (p=%.3f): %.3f %s (90%% CI: [%.3f,%.3f])\n',...
        p, nanmean(d1) - nanmean(d2),XL, ci);
    
    % Kickout nans
    d1(isnan(d1)) = [];
    d2(isnan(d2)) = [];
    
    % driver code
    figure('Color','white', 'Units', 'centimeters', 'Position', [10 10 FIG_DIMS]);
    
    h1 = raincloud_plot(d1, 'box_on', 1, 'color', CB(5,:), 'alpha', ALPHA,...
        'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .3,...
        'box_col_match', 1);
    
    h2 = raincloud_plot(d2, 'box_on', 1, 'color', CB(6,:), 'alpha', ALPHA,...
        'box_dodge', 1, 'box_dodge_amount', .5, 'dot_dodge_amount', .65,...
        'box_col_match', 1);
    
    % Legend
    if ~strcmp(LEGEND_OFF, 'legend_off')
        l =legend([h1{1} h2{1}], HUE_NAMES, 'Location','best');
        l.Title.String = 'Attention on:';
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
    title(sprintf('%s: %s', T, ZVAR_NAMES{i}), 'FontSize', T_FONTSIZE,'FontWeight',T_FONTWEIGHT);
    box off
    
    % XAxis
    ax = gca;
    xlabel(XL,'FontSize',XL_FONTSIZE, 'FontWeight', XL_FONTWEIGHT);
    ax.XAxis.FontSize = XA_FONTSIZE;
    ax.XAxis.TickValues = XA_TICKS;
    
    % YAxis
    ylabel(YL,'FontSize',XL_FONTSIZE, 'FontWeight', XL_FONTWEIGHT);
    ax.YAxis.TickValues = YA_TICKS;
    ax.YAxis.FontSize = XA_FONTSIZE;
    ylim(YLIMS)
    
    % Save
    grid on;
    fname = sprintf('%s_%s_overall_%ss_%s',...
                SAMPLE,ZVAR_NAMES{i}, XVAR, LEGEND_OFF);
    fname = fullfile(FIG_DIR, fname);
    print(fname, '-dpng','-r300');
    fprintf('Printed %s\n\n',fname);
end