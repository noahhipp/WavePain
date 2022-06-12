function eda_wm_plot

% Plots online wm s_zt_scls for wavepain paper

% Settings
SAMPLE          = 'behav'; % can be 'behav' or 'fMRI'
DONT_PLOT_OBSERVED_RESPONSE = 1;
XVAR            = 't';
DETREND_SCL     = 'no'; % can be 'yes' or 'no'
LEGEND_OFF      = 'legend_off'; % 'legend_off' turns it off else on

YVAR            = 's_zt_scl';
YVAR_ERROR      = 'sembj_id_dv';

ZVAR            = 'condition';
ZVAR_NAMES      = {'M21', 'M12','W21','W12'};
ZVAR_VALS       = [1 2 3 4];

HOST            = wave_ghost2(SAMPLE); %wave_gethost
NAME            = sprintf('%s_wm_s_zt_scls_%s_vs_%s_%s',...
    SAMPLE, YVAR, XVAR, LEGEND_OFF);
FIG_DIR         = fullfile(HOST.results, '2022_05_21_wm_s_zt_scls');
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
YL = 'SCL [zscores]';
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

% PLOT SECOND LEVEL s_zt_scl TIME
if ~DONT_PLOT_OBSERVED_RESPONSE
    % Collect data
    d_raw      = data{3};
    for i = 1:numel(ZVAR_VALS)
        z = ZVAR_VALS(i);
        d{i}       = d_raw{d_raw{:,ZVAR} == z, YVAR};
        d_error{i} = d_raw{d_raw{:,ZVAR} == z, YVAR_ERROR};
        
        %      d{i}(isnan(d{i})) = [];
        %      d_error{i}(isnan(d_error{i})) = [];
        x{i} = linspace(0 ,110, numel(d{i}));
    end
    
    % driver code
    % create wave
    for i = 1:numel(ZVAR_VALS)
        z       = ZVAR_VALS(i);
        z_name  = ZVAR_NAMES{i};
        
        % Determine wave
        if ismember(z, [1,2,5])% then we have an M
            wave = waveit2(numel(d{i}));
        elseif ismember(z, [3,4,6]) % then its a W
            [~,wave] = waveit2(numel(d{i}));
        else
            error('unknown condition. aborting. better luck next time.');
        end
        
        % Whether to open a new figure
        if ismember(z, [1,3,5,6])
            fresh_figure = 1;
            figure('Color','white', 'Units', 'centimeters',...
                'Position', [10 10 FIG_DIMS]);
        else
            fresh_figure = 0;
        end
        
        % Plot s_zt_scls
        if strcmp('yes', DETREND_SCL)
            % have to take care of nans now
            nan_idx         = isnan(d{i});
            first_nan_idx       = find(nan_idx, 1);
            d{i}(nan_idx)   = d{1}(first_nan_idx-1);
            d{i} = detrend(d{i});
        end
        
        [hlines, hshades, legend_labels] = waveplot2(d{i},z_name, d_error{i});
        for j = 1:numel(hlines)
            hlines(j).LineWidth = LINEWIDTH;
        end
        
        clear
        % Plot wave
        hold on;
        hwave = plot(x{i}, wave, 'k--');
        nothing = scatter(1,1,'w');
        
        % Legend
        if ~strcmp(LEGEND_OFF, 'legend_off')
            l =legend([hlines(1), hlines(2), hlines(3),...
                hshades(1), hshades(2), hshades(3)],...
                [strcat({'...'},legend_labels), strcat({'SEM '},legend_labels)],...
                'Location','best', 'NumColumns',2, 'Interpreter', 'none');
            l.Title.String = 'SCL during...';
            l.FontSize = L_FONTSIZE;
            %         l2 = legend(hwave, 'Heat stimulus', 'Location', 'best');
            %         l2.FontSize = L_FONTSIZE;
        end
        
        % Title
        
        
        if fresh_figure % then we construct the title from scratch
            if strcmp(SAMPLE, 'behav')
                T = 'Behavioural sample';
            elseif strcmp(SAMPLE, 'fmri') || strcmp(SAMPLE, 'fMRI')
                T = 'fMRI sample';
            else
                error("Sample not recognized, must be 'behav' or 'fmri'");
            end
            T = sprintf('%s: %s', T, ZVAR_NAMES{i});
        else % we just append current condition name
            T = sprintf('%s and %s', T, z_name);
        end
        fprintf('%s plotted\n',T);
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
        fname = sprintf('%s_%s_wm_s_zt_scls_%s_vs_%s_%s',...
            SAMPLE,ZVAR_NAMES{i}, YVAR, XVAR, LEGEND_OFF);
        fname = fullfile(FIG_DIR, fname);
        print(fname, '-dpng','-r300');
        fprintf('Printed %s\n\n',fname);
    end
    close all;
end

% FIT LME
LME_FORMULA = 's_zt_scl~heat*wm_cat1*slope+(1|id)';

% Grab raw data
d = data{1};

% Append categorical variables
d.wm_cat1 = categorical(d.wm, [0, -1, 1], {'no_task','1back','2back'}); 

% Fitlme
lme = fitlme(d,LME_FORMULA, 'FitMethod', 'REML');
disp(lme);

% PLOT OBSERVED RESPONSES
fitted_res

% % Collect beta weights
% betas = fixedEffects(lme);
% betas = betas(2:end); % discard intercept
% 
% % Collect design matrix
% d2 = data{3}; % secondlevel means
% d2 = d2(:,{'heat','wm','slope',...
%     'heat_X_slope', 'heat_X_wm','wm_X_slope', 'heat_X_wm_X_slope'});
% d2.time = repmat(linspace(0,110,1101)',6,1); % construct time vector for easier plotting
% 
% if DISCARD_NO_TASK_FOR_LME
%     d2(d2.wm == 0,:) = [];
% end
% 
% % Now adjust wm encoding
% d2.wm(d2.wm == -1) = 0;
% 
% A = table2array(d2(:,1:end-1));
% fitted_responses = A(1:end-1)*betas;
% 
% % the question is how do I correctly weigh in --> NOPE fuck the non task
% % areas for now it should be enough to plot fitted responses for the task
% % regions only



