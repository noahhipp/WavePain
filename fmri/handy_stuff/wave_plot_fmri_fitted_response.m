function wave_plot_fmri_fitted_response
% loads custom betas and design matrix and plots fitted response

%------------------------------RETRIEVE INPUT------------------------------
% This is fixed
% A = wave_load_designmatrix;

% load("C:\projects\wavepain\code\fmri\03_firstlevel\firstlevel_canonical_pmod\plotting\raw_xX.mat", 'xX');
load("C:\projects\wavepain\code\fmri\03_firstlevel\firstlevel_canonical_pmod\plotting\conv_xX.mat", 'xX');

wm_X = xX.wm;
online_X = xX.online;



% This we can manipulate using wave_sliders
betas               = wave_load('custom_betas',[10,1]);

wm_betas        = betas(1:7);
online_betas    = betas(8:10);    

wm_data         = wm_X*wm_betas;% obtain fitted response
online_data     = online_X*online_betas;
data            = vertcat(wm_data, online_data);
data = reshape(data, [], 6); % reshape so we can loop through for plotting


%------------------------------RETRIEVE INPUT END--------------------------

%------------------------------PREPARING STUFF-----------------------------

% Get access to figure;
global fr_fig
if ishandle(fr_fig)
    figure(fr_fig);
    new     = 1; % used to toggle customization
    fprintf('Found %25s plot', 'existing figure for FR');
else
    fr_fig = figure('Color', [1 1 1]);
    new     = 1;
    fprintf('Created %23s plot', 'new figure for FR');    
end

% Collect coordinates
[~,xyz_mm] = wave_load_coordinates;
%------------------------------PREPARING STUFF-END-------------------------

%------------------------------PLOTTING ACTION ----------------------------
% plotting order (= sequence to take through subplots)
porder              = [1 2; 6 7; 3 4; 8 9; 11 12; 13 14];
condition_names     = {'M21', 'M12','W21', 'W12','Monline','Wonline'};
do_ylims            = 0;

if new
    fprintf('...instantiating...');
    
    % Prepare wave
    load('parametric_contrats_60fir.mat','parametric_contrasts')
    m = (parametric_contrasts.m - parametric_contrasts.m(1)) .* (1/7); % minus mal minus das ist kein stuss, minus mal minus das gibt plus
    w = (parametric_contrasts.w - parametric_contrasts.w(1)) .* (1/7);
    wave_x = linspace(1,119,60);
    line_width          = 4;    
    
    % Set axis colors
    left_color = [0 0 0];
    right_color = [1 1 1];
    set(fr_fig,'defaultAxesColorOrder',[left_color; right_color]); 
    
    observed_data = [];
    for i = 1:6        
        subplot(3,5,porder(i,:)); hold on;
        
        % Plot data
        yyaxis left; cla;
        line = waveplot(data(:,i), condition_names{i}, zeros(size(data,1),1), 1101);
        if do_ylims
            ylim([-do_ylims, do_ylims]);
        end                                        
        
        % Plot wave
        if ismember(i,[1 2 5]);   pwave=m; 
            if i == 2;ylabel('fMRI Signal [au]', 'FontSize', 12, 'FontWeight', 'bold'); end
        else;       pwave=w;            
        end
        yyaxis right; cla;
        wave                = plot(wave_x, pwave, 'k--');
        wave.LineWidth      = line_width * .67;        
        if i==4
                hold on;                
                online = plot(1,0.3, '-*', 'LineWidth', 4, 'Color', [0.1725 0.4824 0.7137]);
                blank = plot(1,0.1,'w-');
                lg =legend([line(1:3) online blank wave],{'...no task', '...1-back','...2-back','...online rating','','Heat stimulus'});
                lg.Position= [0.83 .45, 0.1 0.1];                            
                lg.Title.String = 'Fitted response during...';
                lg.FontSize = 12;
        end
        
        % Customize figure
        grid on;
        title(condition_names{i}, 'FontSize', 14, 'Interpreter','none');
        ylim([-0.25 0.25]);
        if i > 4
            xlabel('Time (s)', 'FontSize', 12, 'FontWeight', 'bold');            
        end
        [~,ticks] = getBinBarPos(110);
        ax = gca;
        Xachse = ax.XAxis;
        ax.YAxis(1).FontSize = 12;
        Xachse.FontSize = 12;
        Xachse.TickValues = [ticks(2), ticks(4), ticks(6), 110];
        Xachse.TickLabelFormat = '%d';                        
    end
    
else
    % Still have to figure this out cause selecting the subplot clears
    % it...
    fprintf('...updating...     ');
    for i = 1:6        
        subplot(3,5,porder(i,:)); hold on;
        
       
        yyaxis left; cla;
        [line, legend_labels] = waveplot(data(:,i), condition_names{i}, zeros(size(data,1),1),55);
        if do_ylims
            ylim([-do_ylims, do_ylims]);
        end
        xlim([0 110]);
    end        
end

% title
fig_title = sprintf('Fitted response for x=%1.1f y=%1.1f z=%1.1f', xyz_mm);
sgtitle(fig_title, 'FontWeight', 'bold', 'FontSize', 16);

fprintf('done!\n');
%------------------------------PLOTTING ACTION END-------------------------






