function online_plot
% Plots online ratings for wavepain paper

% Settings
SAMPLE          = 'fmri'; % can be 'behav' or 'fMRI'
XVAR            = 't';
LEGEND_OFF      = 'legend_on'; % 'legend_off' turns it off else on

YVAR            = 'rating';
YVAR_ERROR      = 'sem_rating';

ZVAR            = 'shape';
ZVAR_NAMES      = {'M-shape', 'W-shape'};
ZVAR_VALS       = [1, 2];

HOST            = wave_ghost2(SAMPLE); %wave_gethost
NAME            = sprintf('%s_online_ratings_%s_vs_%s_%s',...
                SAMPLE, YVAR, XVAR, LEGEND_OFF);
FIG_DIR             = fullfile(HOST.results, '2022_05_14_online_ratings');
if ~exist(FIG_DIR, 'dir')
    mkdir(FIG_DIR)
end
FNAME           = fullfile(FIG_DIR,NAME);

% Figure
FIG_DIMS        = [8.8 5];

% Colors
CB              = wave_load_colors;         
ALPHA           = .5;
if strcmp(YVAR, 'slope')
    CB = [0 0 0; .6 .6 .6];
end

% Legend
L_FONTSIZE      = 8;

% Title
T_FONTSIZE      = 10;
T_FONTWEIGHT    = 'bold';

% XAxis
switch XVAR
    case 't'
        XL      = 'time [s]';        
    case 'd'
        XL      = 'd prime';
end
XL_FONTSIZE     = 8;
XL_FONTWEIGHT   = 'bold';
XA_FONTSIZE     = 8;
XA_TICKS        = [0 5 55 110];

% YAxis
YL = 'pain [VAS]';
YA_TICKS = [0 30 60 100];

% HOUSEKEEPING
NAMES = {   'all_online_ratings.csv',...
            'all_online_ratings_c.csv',...
            'all_online_ratings_cc.csv'};            

DATA_DIR     = fullfile(HOST.dir, 'online_ratings');
FILES   = fullfile(DATA_DIR, NAMES);

 % Grab data
 data = cell(numel(NAMES),1);
 i = 0;
 for file = FILES
     i = i + 1;
     data{i} = readtable(FILES{i});
 end
 
 
 
 % Plot second level ratings against time
 % 1b vs 2b
 
 % Collect data
 d_raw      = data{3};  
 for i = 1:numel(ZVAR_VALS)
     d{i}       = d_raw{d_raw{:,ZVAR} == ZVAR_VALS(i), YVAR};
     d_error{i} = d_raw{d_raw{:,ZVAR} == ZVAR_VALS(i), YVAR_ERROR};
     d{i}(isnan(d{i})) = [];
     x{i} = linspace(0,110, numel(d{i}));
 end  
 
% Stats first
% [~,p,ci,~] = ttest(d1, d2);
% fprintf('p-value: %f\nCI: %f %f\n', p, ci);
% fprintf('1-back mean: %.3f\n2-back mean: %.3f\n',...
%     nanmean(d1), nanmean(d2));
% fprintf('Mean difference (p=%.3f): %.3f seconds (90%% CI: [%.3f,%.3f])\n',...
%     p, nanmean(d1) - nanmean(d2), ci);

% driver code
% create wave
for i = 1:numel(ZVAR_VALS)
    if ZVAR_VALS(i) == 1 % then we have an M
        wave = waveit2(numel(d{i}));        
    elseif ZVAR_VALS(i) == 2 % then we have a W
        [~,wave] = waveit2(numel(d{i}));        
    end
    wave = wave .* 30 + 30;       
    
    figure('Color','white', 'Units', 'centimeters',...
        'Position', [10 10 FIG_DIMS]);
    
    % Plot ratings   
    [h{1}, h{2}] = boundedline(x{i}, d{i}, d_error{i}, 'k');
    
    % Plot wave
    hold on;
    h{3} = plot(x{i}, wave, 'k--');        
 
    % Legend
    if ~strcmp(LEGEND_OFF, 'legend_off')
        l =legend([h{1}, h{2}, h{3}], {'CPRs','CPRs SEM', 'Heat stimulus'},...
            'Location','best');        
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
    T = sprintf('%s: %s', T, ZVAR_NAMES{i});
    title(T, 'FontSize', T_FONTSIZE,'FontWeight',T_FONTWEIGHT);
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
    ylim([0 100])
    
    % Save
    grid on;    
    fname = sprintf('%s_%s_online_ratings_%s_vs_%s_%s',...
                SAMPLE,ZVAR_NAMES{i}, YVAR, XVAR, LEGEND_OFF);
    fname = fullfile(FIG_DIR, fname);
    print(fname, '-dpng','-r300');
    fprintf('Printed %s\n\n',fname);
end