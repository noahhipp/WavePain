function paper_draw_conditions
% draws 3x2 subplot for wavepain conditions

N = 1100;

% Settings
XLIMS = [0 110];
YLIMS = [0 100];
YLABEL = 'Temperature [VAS]';
LINEWIDTH = 2;
TITLES = {'M21', 'M12', 'W21','W12','M-online', 'W-online'};
TITLESIZE = 16;
TICKSIZE = 12;

[m, w] = waveit2(N);
m = m*30+30;
w = w*30+30;
x      = linspace(0,110,N);

figure('Color', 'white');

porder              = [1 2; 6 7; 3 4; 8 9; 11 12; 13 14];
for i = 1:6
    subplot(3,5,porder(i,:));
    
    % Add patches
    if ismember(i, [1 3])
        p = wave_batches(21, YLIMS);
    elseif ismember(i, [2 4])        
        p = wave_batches(12, YLIMS);
    end
    
    % Plot
    hold on;
    if ismember(i, [1 2 5])
        heat = plot(x,m, 'k--', 'LineWidth', LINEWIDTH);
        waveyaxis(YLABEL, YLIMS);
    else
        heat = plot(x,w, 'k--', 'LineWidth', LINEWIDTH);
        waveyaxis('', YLIMS);
    end        
    
    % Legend
    if i ==4
        lg = legend([heat p(1) p(2)], {'Heat stimulus', '1-back task', '2-back task'});
        lg.Position = [.83 .45 .1 .1];
        lg.FontSize = 12;
    end
    wavexaxis;    
    title(TITLES{i}, 'FontSize', TITLESIZE, 'FontWeight', 'bold');
    
    % Customize
    % y axis
    ylim(YLIMS);
    ylabel(YLABEL, 'FontWeight', 'bold');
    grid on;
    ax = gca;
    ax.YAxis.FontSize = TICKSIZE;
    ax.YTick = [0 30 60 100];
    
    % x axis
    [~,ticks] = getBinBarPos(110);
    xlim(XLIMS);
    xticks([0 ticks([1 2:2:6]) 110]);
    xticklabels({'0','5','22','55','88','110'});
    xlabel('Time [s]', 'FontWeight', 'bold');
    grid on;
    ax = gca;
    ax.FontSize = TICKSIZE;
end









% wave_batches
% add wave batches to axis
function p = wave_batches(task_order, yspan)

% OPTIONS
COLORS = wave_load_colors;
TB_C = COLORS(1,:);
OB_C = COLORS(2,:);
ALPHA = 0.5;

% Get positions to draw to
[~,ticks] = getBinBarPos(110);

% Draw first patch
p(1) = patch([ticks(2) ticks(4) ticks(4) ticks(2)], [yspan(1) yspan(1) yspan(2) yspan(2)], TB_C);
p(1).FaceAlpha = ALPHA;
p(1).EdgeAlpha = ALPHA;
p(1).EdgeColor = TB_C;

% Draw second one
p(2) = patch([ticks(4) ticks(6) ticks(6) ticks(4)], [yspan(1) yspan(1) yspan(2) yspan(2)], OB_C);
p(2).FaceAlpha = ALPHA;
p(2).EdgeAlpha = ALPHA;
p(2).EdgeColor = OB_C;

% Invert colors if we have to
if task_order == 12 
    p(1).FaceColor = OB_C;
    p(1).EdgeColor = OB_C;
    p(2).FaceColor = TB_C;
    p(2).EdgeColor = TB_C;
end
