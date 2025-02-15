function child1_plot_f_contrasts_baseline_corrected

% Settings
do_save = 0;
colors = {'k', 'r','b'}; % replace with fancy seaborn palette later

xG.def              = 'Contrast estimates and 90% C.I.';
% M21_vs_Monline, M12 vs Monline, M21 vs M12, w21_vs_wonline, w12 vs wonline, w21 vs w12,   
contrasts_to_plot   = [375 376 374 377 378 382]; % contrasts we want to plot %ftl
condition_names      = {'M21', 'M12','M21vsM12', 'W21', 'W12','W21vsW12'};
line_width          = 4;

% Grab variables from base workspace
global st;
global cb1_fig;
SPM                     = evalin('base', 'SPM');
% results_table           = evalin('base', 'TabDat.dat');
xSPM                    = evalin('base', 'xSPM');
cd(SPM.swd);

% Housekeeping
xA                      = spm_atlas('load', 'Neuromorphometrics');
contrast_names          = {};

for i = 1:numel(contrasts_to_plot)
    contrast_names{i}   = SPM.xCon(contrasts_to_plot(i)).name;
end
base_dir                = '/home/hipp/projects/WavePain/results/spm/';
contrast_dir            = strjoin(contrast_names, '_and_');
save_dir                = fullfile(base_dir, contrast_dir);
fir_order               = 60;
if ~exist(save_dir, 'dir')
    mkdir(save_dir)
end

% Plotting action
load('parametric_contrats_60fir.mat','parametric_contrasts')
m = parametric_contrasts.m;
w = parametric_contrasts.w;
wave_x = linspace(1,119,60);


%     if ~isempty(results_table{i,3}) % black voxel in results table, we care about those

% We get this from st.centre now
% Get coordinates and label
        xyz_rd      = st.centre; % mm space
        xyz         = mm2voxel(xyz_rd, xSPM);  % voxel space
        region      = spm_atlas('query', xA, xyz_rd);                

% Now loop through our contrasts
if ishandle(cb1_fig)
    figure(cb1_fig); 
else
    cb1_fig = figure('Name', 'template', 'Position', [0 0 108 192], 'Color', [1, 1, 1]);    
end
x = linspace(0,120,fir_order)';

sgtitle(sprintf('Voxel coordinates: x=%1.1f y=%1.1f z=%1.1f aka %s',xyz_rd, region), 'FontSize', 24)

porder = [1,3,5,2,4,6];

for j = 1:size(contrasts_to_plot,2)
    xG.spec.Ic              = contrasts_to_plot(j);
    [~, ~, ~, ~, data]      = spm_graph(SPM, xyz, xG);        
    
    % Plot data    
    subplot(3,2,porder(j));
     

    %     if ~ismember(j,[3,6])
    yyaxis left; cla;
    waveplot(data.contrast, condition_names{j}, data.standarderror, 55);                        
%     else
%         line = boundedline(x, data.contrast, data.standarderror, 'k-', 'alpha');            % ftl add errorline function
%         line.LineWidth = line_width;        
%     end
        
    
    % Plot wave
    yyaxis right; cla;
    if j < 4;   wave=m;
    else;       wave=w; end
    hold on;    
    wave                = plot(wave_x, wave, 'k--');
    wave.LineWidth      = line_width * .67;
    
    % Customize figure
%     legend([line, wave], 'F-contrast', 'Heat stimulus', 'FontSize', 14)
    grid on;
    title(contrast_names{j}, 'FontSize', 14, 'Interpreter','none')            
    xlabel('Time (s)', 'FontSize', 14);        
    [~,ticks] = getBinBarPos(110);
    ax = gca;
    Xachse = ax.XAxis;
    ax.YAxis(1).FontSize = 14;
    Xachse.FontSize = 14;
    Xachse.TickValues = [ticks(2), ticks(4), ticks(6)];
    Xachse.TickLabelFormat = '%d';        
end

% Trying to rename one entry in legend: Heres some MATLAB for ya
%     leg = findobj('type','legend');
%     for k=1:numel(leg)
%         leg(k).String{end} = 'Heat stimulus';
%     end

 
% Save figure
if do_save
    fname = sprintf('x_%03.1__y_%03.1f__z_%03.1f_export_%s',xyz_rd, matlab.lang.makeValidName(region));
    print(fullfile(save_dir, fname),'-dpng','-r300') ;
end


