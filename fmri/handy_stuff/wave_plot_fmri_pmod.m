function wave_plot_fmri_pmod(data)
% takes data as returned by anova canonical pmod contrast and plots it in a
% nice labeled bar graph

%------------------------------CHECK INPUT---------------------------------
check0 = 0;
check1 = 0;
if numel(data{1}.contrast) == 7
    check0 = 1;
end
if numel(fieldnames(data{1})) == 3
    check1 = 1;
end

if ~check0 || ~check1
    warning('checks not passed. please check input')
    return
end
%------------------------------CHECK INPUT END-----------------------------

%------------------------------PREPARING STUFF-----------------------------

% Get access to figure;
global pmod_fig
if ishandle(pmod_fig)
    figure(pmod_fig);
    new     = 0; % used to toggle customization
    fprintf('Found %25s plot', 'existing figure for pmod');
else
    pmod_fig = figure('Color', [1 1 1]);
    new     = 1;
    fprintf('Created %23s plot', 'new figure for pmod');    
end

% Collect coordinates
[~,xyz_mm] = wave_load_coordinates;

%------------------------------PREPARING STUFF-END-------------------------

%------------------------------PLOTTING ACTION ----------------------------
y_label = 'fMRI signal [au]';
hold on;
pmod_names          = {'Heat', 'WM', 'Slope',...
        'Heat X WM', 'Heat X Slope','WM X Slope',...
        'Heat X WM X Slope'};
    
    x = 1:numel(pmod_names);

% Update plot
cla;
grid on;

b   = bar(x, data{1}.contrast);
b.FaceColor = [1 1 1];
b.LineWidth = 2;
er  = errorbar(x, data{1}.contrast, data{1}.standarderror);
er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 2;
    
if new
    fprintf('...instantiating...');        
    xticklabels(pmod_names);
    xticks(x);
    ax = gca;
    ax.FontSize = 14;
    ax.XAxis.TickLabelInterpreter = 'none';
    xtickangle(90);
    xlabel('Contrasts', 'FontWeight', 'bold');
    ylabel(y_label, 'FontWeight', 'bold');    
end

% title
fig_title = sprintf('CANONICAL PMOD ANOVA for x=%1.1f y=%1.1f z=%1.1f', xyz_mm);
sgtitle(fig_title, 'FontWeight', 'bold', 'FontSize', 16);

% safe stuff to binary files
wave_save_ylims(ylim);
wave_save(data{1}.contrast, 'betas');
wave_save(data{1}.contrast, 'custom_betas');

fprintf('done!\n');