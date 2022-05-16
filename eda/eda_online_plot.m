function eda_online_plot
% Plots online s_zt_scls for wavepain paper

% Settings
SAMPLE          = 'behav'; % can be 'behav' or 'fMRI'
XVAR            = 't';
DETREND_SCL     = 'yes'; % can be 'yes' or 'no'
LEGEND_OFF      = 'legend_on'; % 'legend_off' turns it off else on

YVAR            = 's_zt_scl';
YVAR_ERROR      = 'sem_s_zt_scl';

ZVAR            = 'condition';
ZVAR_NAMES      = {'M-shape', 'W-shape'};
ZVAR_VALS       = [5 , 6];

HOST            = wave_ghost2(SAMPLE); %wave_gethost
NAME            = sprintf('%s_online_s_zt_scls_%s_vs_%s_%s',...
                SAMPLE, YVAR, XVAR, LEGEND_OFF);
FIG_DIR         = fullfile(HOST.results, '2022_05_16_online_s_zt_scls');
if ~exist(FIG_DIR, 'dir')
    mkdir(FIG_DIR)
end

% Figure
FIG_DIMS        = [8.8 5];

% LINE
LINEWIDTH       = 2;

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
XA_TICKS        = [0 5 55 105];
XLIMS           = [0 105];

% YAxis
YL = 'pain [VAS]';
YA_TICKS = [0 30 60 100];

% HOUSEKEEPING
NAMES = {   'all_eda.csv',...
            'all_eda_c.csv',...
            'all_eda_cc.csv'};            

DATA_DIR     = fullfile(HOST.dir, 'eda');
FILES   = fullfile(DATA_DIR, NAMES);

 % Grab data
 data = cell(numel(NAMES),1);
 i = 0;
 for file = FILES
     i = i + 1;
     data{i} = readtable(FILES{i});
 end   
 
 % Plot second level s_zt_scls against time 
 
 % Collect data
 d_raw      = data{3};  
 for i = 1:numel(ZVAR_VALS)
     d{i}       = d_raw{d_raw{:,ZVAR} == ZVAR_VALS(i), YVAR};
     d_error{i} = d_raw{d_raw{:,ZVAR} == ZVAR_VALS(i), YVAR_ERROR};
     
%      d{i}(isnan(d{i})) = [];
%      d_error{i}(isnan(d_error{i})) = [];
     x{i} = linspace(0 ,110, numel(d{i}));
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
    if ZVAR_VALS(i) == 5 % then we have an M
        wave = waveit2(numel(d{i}));        
    elseif ZVAR_VALS(i) == 6 % then we have a W
        [~,wave] = waveit2(numel(d{i}));        
    end
%     wave = wave .* 30 + 30;       
    
    figure('Color','white', 'Units', 'centimeters',...
        'Position', [10 10 FIG_DIMS]);
    
    % Plot s_zt_scls   
    if strcmp('yes', DETREND_SCL)
        % have to take care of nans now
        nan_idx         = isnan(d{i});
        first_nan_idx       = find(nan_idx, 1);
        d{i}(nan_idx)   = d{1}(first_nan_idx-1);                
        d{i} = detrend(d{i});
    end        
    
    [h{1}, h{2}] = boundedline(x{i}, d{i}, d_error{i}, 'k');
    h{1}.LineWidth = LINEWIDTH;
    
    % Plot wave
    hold on;
    h{3} = plot(x{i}, wave, 'k--');        
 
    % Legend
    if ~strcmp(LEGEND_OFF, 'legend_off')
        l =legend([h{1}, h{2}, h{3}], {'SCL','SCL SEM', 'Heat stimulus'},...
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
    xlim(XLIMS);
    xlabel(XL,'FontSize',XL_FONTSIZE, 'FontWeight', XL_FONTWEIGHT);        
    ax.XAxis.FontSize = XA_FONTSIZE;
    ax.XAxis.TickValues = XA_TICKS;
    
    
    % YAxis
    ylabel(YL,'FontSize',XL_FONTSIZE, 'FontWeight', XL_FONTWEIGHT);        
    ax.YAxis.TickValues = YA_TICKS;
    ax.YAxis.FontSize = XA_FONTSIZE;    
%     ylim([0 100])
    
    % Save
    grid on;    
    xlim(XLIMS);
    fname = sprintf('%s_%s_online_s_zt_scls_%s_vs_%s_%s',...
                SAMPLE,ZVAR_NAMES{i}, YVAR, XVAR, LEGEND_OFF);
    fname = fullfile(FIG_DIR, fname);
    print(fname, '-dpng','-r300');
    fprintf('Printed %s\n\n',fname);
end