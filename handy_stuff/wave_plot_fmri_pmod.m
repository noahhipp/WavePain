function wave_plot_fmri_pmod(data)
% takes data as returned by anova canonical pmod contrast and plots it in a
% nice labeled bar graph

%------------------------------CHECK INPUT---------------------------------
ana_type = 0;
check1 = 0;
if numel(data{1}.contrast) == 10
    ana_type = 1;
elseif numel(data{1}.contrast) == 7
    ana_type = 2; % old data with 7 regressors
elseif numel(data{1}.contrast) == 18 % pmodV5
    ana_type = 3; % new data with 18 regressors
elseif numel(data{1}.contrast) == 26 % pmodV6
    ana_type = 4;
end

if numel(fieldnames(data{1})) == 3
    check1 = 1;
end

if ~ana_type || ~check1
    warning('checks not passed. please check input')
    return
end
%------------------------------CHECK INPUT END-----------------------------

%------------------------------PREPARING STUFF-----------------------------
FIG_DIMS        = [8.8 8];


% Get access to figure;
global pmod_fig
if ishandle(pmod_fig)
    figure(pmod_fig);
    new     = 0; % used to toggle customization
    fprintf('Found %25s plot', 'existing figure for pmod');
else
    pmod_fig = figure('Color', [1 1 1], 'Units', 'centimeters',...
        'Position',[10 10 FIG_DIMS]);
    new     = 1;
    fprintf('Created %23s plot', 'new figure for pmod');
end

% Collect coordinates
[~,xyz_mm] = wave_load_coordinates;

%------------------------------PREPARING STUFF-END-------------------------

%------------------------------PLOTTING ACTION ----------------------------
y_label = 'Parameter estimate';
hold on;
if ana_type == 1
    pmod_names          = {'wm_Heat', 'wm_WM', 'wm_Slope',...
        'wm_Heat X WM', 'wm_Heat X Slope','wm_WM X Slope',...
        'wm_Heat X WM X Slope',...
        'online_Heat', 'online_Slope', 'online_Heat X Slope'};
elseif ana_type == 2
    pmod_names          = {'Heat', 'WM', 'Slope',...
        'Heat X WM', 'Heat X Slope','WM X Slope',...
        'Heat X WM X Slope'};
elseif ana_type == 3
    pmod_names          = {'wm_heat', 'wm_wm1', 'wm_wm2', 'wm_slope',...
        'wm_heat_X_wm1', 'wm_heat_X_wm2', 'wm_heat_X_slope','wm_wm1_X_slope', 'wm_wm2_X_slope',...
        'wm_heat_X_wm1_X_slope', 'wm_heat_X_wm2_X_slope',...
        'wm_ramp_up', 'wm_ramp_down',...
        'online_heat', 'online_slope', 'online_heat_X_slope',...
        'online_ramp_up', 'online_ramp_down'};
elseif ana_type == 4
    pmod_names          = {'wm_heat', 'wm_wm1', 'wm_wm2', 'wm_slope',...
        'wm_heat_X_wm1', 'wm_heat_X_wm2', 'wm_heat_X_slope','wm_wm1_X_slope', 'wm_wm2_X_slope',...
        'wm_heat_X_wm1_X_slope', 'wm_heat_X_wm2_X_slope',...
        'wm_ramp_up', 'wm_ramp_down',...
        'online_heat', 'online_slope', 'online_heat_X_slope',...
        'online_ramp_up', 'online_ramp_down',...
        'wm1_LARGER_wm2','wm1_SMALLER_wm2',...
        'heat_X_wm1_GREATER_wm2', 'heat_X_wm1_SMALLER_wm2',...
        'diffheat_X_wm1_GREATER_wm2', 'diffheat_X_wm1_SMALLER_wm2',...
        'heat_X_diffheat_wm1_GREATER_wm2', 'heat_X_diffheat_wm1_SMALLER_wm2'};
end

x = 1:numel(pmod_names);

% Update plot
cla;
grid on;

b   = bar(x, data{1}.contrast);

b.FaceColor = [1 1 1];
b.LineWidth = 1;
er  = errorbar(x, data{1}.contrast, data{1}.standarderror);
er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 1;

if new
    fprintf('...instantiating...');
    xticklabels(pmod_names);
    xticks(x);
    ax = gca;
    ax.FontSize = 8;
    ax.XAxis.TickLabelInterpreter = 'none';
    xtickangle(45);
    xlabel('Regressor', 'FontWeight', 'normal');
    ylabel(y_label, 'FontWeight', 'normal');
end

% title
fig_title = sprintf('Parameter estimates for x=%1.1f y=%1.1f z=%1.1f', xyz_mm);
title(fig_title, 'FontWeight', 'bold', 'FontSize', 10);

% safe stuff to binary files
wave_save_ylims(ylim);
wave_save(data{1}.contrast, 'betas');
wave_save(data{1}.contrast, 'custom_betas');

fprintf('done!\n');