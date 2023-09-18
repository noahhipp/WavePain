function eda_plot_lme
% receives linear mixed model and plots fitted responses

% Housekeeping
SAMPLE = 'fmri';

HOST                = wave_ghost2(SAMPLE);
EDA_DIR             = fullfile(HOST.dir, 'eda');
EDA_TEMPLATE        = 'all_eda_sampled-at-half-a-hertz.csv';
[~, NAME, EXT]      = fileparts(EDA_TEMPLATE);
EDA_LME_TEMPLATE    = strcat(NAME, '_lme','.mat');

EDA_FILE            = fullfile(EDA_DIR, EDA_TEMPLATE);
EDA_LME_FILE        = fullfile(EDA_DIR, EDA_LME_TEMPLATE);

% Get data
load(EDA_LME_FILE, 'lmes');
lme = lmes{1};
data = lme.Variables;

% This is what the model looks like. Now we have to build a design Matrix
% for it
%  {'(Intercept)'           }         0.016738    0.010953      1.5282    15124
%     {'heat'                  }          0.19527    0.030568       6.388    15124
%     {'slope'                 }        0.0090885    0.012572     0.72292    15124
%     {'wm_c0_1back'           }        -0.073598    0.020177     -3.6477    15124
%     {'wm_c0_2back'           }        0.0013974    0.020177    0.069257    15124
%     {'heat:slope'            }         0.077996    0.018011      4.3306    15124
%     {'heat:wm_c0_1back'      }        -0.082013     0.02913     -2.8154    15124
%     {'heat:wm_c0_2back'      }        -0.084949     0.02913     -2.9162    15124
%     {'slope:wm_c0_1back'     }         -0.02372      0.0211     -1.1242    15124
%     {'slope:wm_c0_2back'     }        0.0072772      0.0211      0.3449    15124
%     {'heat:slope:wm_c0_1back'}         -0.14678    0.029791     -4.9272    15124
%     {'heat:slope:wm_c0_2back'}         -0.15702    0.029791     -5.2707    15124

% Collect betas
betas = lme.fixedEffects;

% Build design matrix
X = zeros(height(data),numel(betas));



% if strcmp(SAMPLE, 'fmri') 
    data.heat_X_slope = data.heat .* data.slope;
    data.heat_X_wm    = data.heat .* abs(data.wm);
    data.wm_X_slope   = data.slope .* abs(data.wm);
    data.heat_X_wm_X_slope = data.heat .* data.slope .* abs(data.wm);
% end

if any(contains(lme.CoefficientNames, 'slope'))
    X(:,1) = 1; % intercept is always 1
    X(:,2) = data.heat; % heat
    X(:,3) = data.slope; % slope
    X(data.wm_c0 == '1back',4) = 1;
    X(data.wm_c0 == '2back',5) = 1;
    X(:,6) = data.heat_X_slope;
    X(data.wm_c0 == '1back',7) = data.heat_X_wm(data.wm_c0 == '1back');
    X(data.wm_c0 == '2back',8) = data.heat_X_wm(data.wm_c0 == '2back');
    X(data.wm_c0 == '1back',9) = data.wm_X_slope(data.wm_c0 == '1back');
    X(data.wm_c0 == '2back',10) = data.wm_X_slope(data.wm_c0 == '2back');
    X(data.wm_c0 == '1back',11) = data.heat_X_wm_X_slope(data.wm_c0 == '1back');
    X(data.wm_c0 == '2back',12) = data.heat_X_wm_X_slope(data.wm_c0 == '2back');
    
elseif any(contains(lme.CoefficientNames, 'diffheat'))
    data.heat_X_diffheat = data.heat .* data.diffheat;
    data.heat_X_wm    = data.heat .* abs(data.wm);
    data.wm_X_diffheat   = data.diffheat .* abs(data.wm);
    data.heat_X_wm_X_diffheat = data.heat .* data.diffheat .* abs(data.wm);
    
    X(:,1) = 1; % intercept is always 1
    X(:,2) = data.heat; % heat
    X(:,3) = data.diffheat; % diffheat
    X(data.wm_c0 == '1back',4) = 1;
    X(data.wm_c0 == '2back',5) = 1;
    X(:,6) = data.heat_X_diffheat;
    X(data.wm_c0 == '1back',7) = data.heat_X_wm(data.wm_c0 == '1back');
    X(data.wm_c0 == '2back',8) = data.heat_X_wm(data.wm_c0 == '2back');
    X(data.wm_c0 == '1back',9) = data.wm_X_diffheat(data.wm_c0 == '1back');
    X(data.wm_c0 == '2back',10) = data.wm_X_diffheat(data.wm_c0 == '2back');
    X(data.wm_c0 == '1back',11) = data.heat_X_wm_X_diffheat(data.wm_c0 == '1back');
    X(data.wm_c0 == '2back',12) = data.heat_X_wm_X_diffheat(data.wm_c0 == '2back');
end

% Calculate fitted response
yhat = X * betas;

% Append to data so we can use datas regressors to remove the variance
data.yhat = yhat;
data.predicted = predict(lme, 'Conditional',0);
yhat_mean = varfun(@mean, data, 'InputVariables', {'yhat','predicted','heat','time_within_trial', 's_zid_scl'},...
    'GroupingVariables',{'condition', 'index_within_trial'});

% Get rid of mean prefix
yhat_mean.Properties.VariableNames = strrep(yhat_mean.Properties.VariableNames, 'mean_','');

% we use the error of the 3way interaction to plot shades
yhat_mean.error = ones(height(yhat_mean),1) .* lme.Coefficients.SE(end); 

% Prepare plotting
XVAR            = 't';
LEGEND_OFF      = 'legend_off'; % 'legend_off' turns it off else on

YVAR            = 'yhat';
YVAR_ERROR      = 'error';

ZVAR            = 'condition';
ZVAR_NAMES      = {'M21', 'M12','W21','W12'};
ZVAR_VALS       = [1 2 3 4];

FIG_DIR         = fullfile(HOST.results, '2023-02-20_scl-plots');
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



% Collect data
d_raw      = yhat_mean;
for i = 1:numel(ZVAR_VALS)
    z = ZVAR_VALS(i);
    d{i}       = d_raw{d_raw{:,ZVAR} == z, YVAR};
    d_error{i} = d_raw{d_raw{:,ZVAR} == z, YVAR_ERROR};
    
    x{i} = linspace(0 ,110, numel(d{i}));
end


% Plot fitted response
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
    
    [hlines, hshades, legend_labels] = waveplot2(d{i},z_name, d_error{i});
    for j = 1:numel(hlines)
        hlines(j).LineWidth = LINEWIDTH;
    end
    
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
    fname = sprintf('%s_%s_%s-vs-%s_%s',...
        SAMPLE,ZVAR_NAMES{i}, YVAR, XVAR, LEGEND_OFF);
    fname = fullfile(FIG_DIR, fname);
    print(fname, '-dpng','-r300');
    fprintf('Printed %s\n\n',fname);
end

    
    
    

