function wave_plot_fmri_fir(data)
% takes data from 6 wavepain anova contrasts and plots it according to
% wavepain standards

%------------------------------CHECK INPUT---------------------------------
check0 = 0;
check1 = 0;
if numel(data) == 6
    check0 = 1;
end
if numel(data{1}.contrast == 60)
    check1 = 1;
end

if ~check0 || ~check1
    warning('checks not passed. please check input')
    return
end
%------------------------------CHECK INPUT END-----------------------------


%------------------------------PREPARING STUFF-----------------------------

% Get access to figure;
global fir_fig
if isempty(fig_fig)
    fir_fig = figure('Color', [1 1 1]);
    new     = 1;
    fprintf('Created new figure for fir plot...');
else
    figure(fir_fig);
    new     = 0; % used to toggle customization
    fprintf('Found existing figure for fir plot...');
    
    
    update_plot(data) % or something like that
    return
end

% Collect coordinates
[~,xyz_mm] = wave_load_coordinates;
%------------------------------PREPARING STUFF-END-------------------------

%------------------------------PLOTTING ACTION ----------------------------
% title
fig_title = sprintf('Voxel coordinates (mm): x=%1.1f y=%1.1f z=%1.1f', xyz_mm);
sgtitle(fig_title);

% plotting order (= sequence to take through subplots)
porder = [1,3,2,4,5,6];


if new
    fprinft('Preparing NEW fir plot...');
    
    % Prepare wave
    load('parametric_contrats_60fir.mat','parametric_contrasts')
    m = parametric_contrasts.m;
    w = parametric_contrasts.w;
    wave_x = linspace(1,119,60);
    line_width          = 4;
    y_amplitude         = 1;
    for i = 1:6
        condition_names      = {'M21', 'M12','W21', 'W12','Monline','Wonline'};
        subplot(3,2,porder(i)); hold on;
        
        % Plot data
        yyaxis left; cla;
        [line, legend_labels] = waveplot(data(i).contrast, condition_names{i}, data(i).standarderror,55);
        
        % Plot wave
        if ismember(i,[1 2 5]);   pwave=m;
        else;       pwave=w; end
        yyaxis right; cla;
        wave                = plot(wave_x, pwave, 'k--');
        wave.LineWidth      = line_width * .67;
        
        % Customize figure
        grid on;
        title(contrast_names{j}, 'FontSize', 14, 'Interpreter','none')
        ylim([-y_amplitude y_amplitude]);
        xlabel('Time (s)', 'FontSize', 14);
        [~,ticks] = getBinBarPos(110);
        ax = gca;
        Xachse = ax.XAxis;
        ax.YAxis(1).FontSize = 14;
        Xachse.FontSize = 14;
        Xachse.TickValues = [ticks(2), ticks(4), ticks(6), 110];
        Xachse.TickLabelFormat = '%d';
    end
    
else
    fprinft('Using EXISTING fir plot...');
    for i = 1:6
        subplot(3,2,porder(i));
        yyaxis left; cla;
        [line, legend_labels] = waveplot(data(i).contrast, condition_names{i}, data(i).standarderror,55);
    end    
    fprintf('Done!\n');
end





%------------------------------PLOTTING ACTION END-------------------------









