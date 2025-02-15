function wave_plot_observed_response_EDA(SAMPLE)

SAMPLE          = 'behav'; % can be 'behav' or 'fMRI'
DONT_PLOT_OBSERVED_RESPONSE = 0;
XVAR            = 't';
DETREND_SCL     = 'no'; % can be 'yes' or 'no'
LEGEND_OFF      = 'legend_off'; % 'legend_off' turns it off else on

YVAR            = 's_zt_scl';
YVAR_ERROR      = strcat('sembj_',YVAR);
% YVAR_ERROR      = 'sembj_s_zt_scl';

ZVAR            = 'condition';
ZVAR_NAMES      = {'M21', 'M12','W21','W12'};
ZVAR_VALS       = [1 2 3 4];

HOST            = wave_ghost2(SAMPLE); %wave_gethost
NAME            = sprintf('%s_%s-vs-%s_%s',...
    SAMPLE, YVAR, XVAR, LEGEND_OFF);
FIG_DIR         = fullfile(HOST.results, '2022-07-06_scl-plots');
if ~exist(FIG_DIR, 'dir')
    mkdir(FIG_DIR)
end

% HOUSEKEEPING
BASE_NAME = 'all_eda_sampled-at-half-a-hertz.csv';
% BASE_NAME = 'all_eda.csv';
[~,BLA,EXT] = fileparts(BASE_NAME);
NAMES = {BASE_NAME,...
    strcat(BLA,'_c',EXT),...
    strcat(BLA,'_cc',EXT)};

DATA_DIR     = fullfile(HOST.dir, 'eda');
FILES   = fullfile(DATA_DIR, NAMES);

% Grab data
data = cell(numel(NAMES),1);
i = 0;
for file = FILES
    i = i + 1;
    data{i} = readtable(FILES{i});
end




data = data{3};

% Plot fitted response
font_sizes = [8 10 12];




% porder              = [1 1 2 2 3 4];
porder              = [1 2; 1 2; 3 4; 3 4; 6 7; 8 9];

condition_names     = {'M21', 'M12','W21' 'W12', 'Monline', 'Wonline'};
do_ylims            = 0;

f =figure('Units', 'centimeters', 'Position',[10 10 18 10]);
new = 1;


if new
    
    % Prepare wave    
    [m,w] = waveit2(110);
    wave_x = linspace(1,110,110);
    line_width          = 1;    
    
    % Set axis colors
    left_color = [0 0 0];
    right_color = [1 1 1];
    set(f,'defaultAxesColorOrder',[left_color; right_color]); 
    
    observed_data = [];
    for i = 1:6        
%         subplot(2,2,porder(i)); hold on;
        subplot(2,5,porder(i,:)); hold on;

        % Get data
        y   = data{data.condition == i, YVAR};
        err = data{data.condition == i, YVAR_ERROR};        
        
        % Plot data
        yyaxis left; % cla;
        line = waveplot2(y, condition_names{i}, err,55);
        lines{i} = line; % save it for shades
        ylim([-1.5 1.5]);
        hold on;
        
        % Customize left yaxis
        ax = gca;
        ax.YAxis(1).TickValues = [-1 0 1];
        if ismember(i, [2,5])
            ylabel('SCL [Zscores]', 'FontWeight', 'bold', 'FontSize', font_sizes(1));
        end
        
        % Plot shades
        if i == 2
            % shade between lines{1}(2) and lines{2}(2)
%             shade = wave_shade_between(lines{1}(2), lines{2}(2));
            title('M21 & M12', 'FontSize', font_sizes(2), 'Interpreter','none');
        elseif i == 4
            % shade between lines{1}(2) and lines{2}(2)
%             shade = wave_shade_between(lines{3}(3), lines{4}(3));
            title('W21 & W12', 'FontSize', font_sizes(2), 'Interpreter','none');
        end
        
        % Plot wave
        if ismember(i,[1 2 5])
            pwave=m;             
        else
            pwave=w;            
        end
        yyaxis right;  % cla;
        wave                = plot(wave_x, pwave, 'k--');
        wave.LineWidth      = line_width * .67;  
        yticks([]);
        if i==4
                hold on;                 
                online = plot(1,0.3, '-', 'LineWidth', 2, 'Color', [0.1725 0.4824 0.7137]);
                blank = plot(1,0.1,'w-');
                lg =legend([line(1:3) online blank wave],{'...no task', '...1-back','...2-back','...online rating','','Heat stimulus'});
                lg.Position= [0.83 .45, 0.1 0.1];                            
                lg.Title.String = 'Observed responses during...';
                lg.FontSize = font_sizes(1);
        end
        
        % Customize figure
        grid on;
%         title(condition_names{i}, 'FontSize', font_sizes(2), 'Interpreter','none');
        ylim([-1 1]);
        if i > 4 
            xlabel({'Time (s)'}, 'FontSize', font_sizes(1), 'FontWeight', 'bold');            
        end
        [~,ticks] = getBinBarPos(110);
        ax = gca;
        Xachse = ax.XAxis;
        ax.YAxis(1).FontSize = font_sizes(1);
        Xachse.FontSize = font_sizes(1);
        Xachse.TickValues = [ticks(2), ticks(4), ticks(6), 110];
%         Xachse.TickValues = [];
        Xachse.TickLabelFormat = '%d';
        xlim([0 110]);
        ylim([-1.5 1.5]);

        
        % Save for later
%         observed_data = vertcat(observed_data, data{i}.contrast);        
    end    
   
    sgt = sgtitle('Behavioural sample: Observed response');
    sgt.FontWeight = 'bold';
    sgt.FontSize = font_sizes(3);
    
else
    % Still have to figure this out cause selecting the subplot clears
    % it...
    fprintf('...updating...     ');
    for i = 1:6        
        subplot(3,5,porder(i,:)); hold on;
        
       
        yyaxis left; cla;
        [line, legend_labels] = waveplot(data{i}.contrast, condition_names{i}, data{i}.standarderror,55);
        if do_ylims
            ylim([-do_ylims, do_ylims]);
        end
        xlim([0 110]);
    end        
end










