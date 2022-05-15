function paper_draw_conditions
% draws 3x2 subplot for wavepain conditions

N = 1100;

% Settings
LABELS_OFF = 1;
LEGEND_OFF = 1;
MODIFY_TBLS = 1;

TBLS_ALPHA = 0.25;
TBLS_STYLE = '--';

% for fname
TBLS_STYLE_NAME = TBLS_STYLE;
if strcmp(TBLS_STYLE,':')
    TBLS_STYLE_NAME = 'dotted';
elseif strcmp(TBLS_STYLE,'--')
    TBLS_STYLE_NAME = 'dashed';
end

XLIMS = [0 110];
YLIMS = [0 100];
YLABEL = 'Temperature [VAS]';
LINEWIDTH = 2;
TITLES = {'M21', 'M12', 'W21','W12','M-online', 'W-online'};
TITLESIZE = 16;
TICKSIZE = 12;

FNAME = sprintf('condtions_tbls_alpha%.2f_%s.png', TBLS_ALPHA, TBLS_STYLE_NAME);
DIR   = 'D:\OneDrive - Universität Hamburg\projects\wavepain\results\22_05_12_draw_conditions';
PATH  = fullfile(DIR, FNAME);

[m, w] = waveit2(N);
m = m*30+30;
w = w*30+30;
x      = linspace(0,110,N);

figure('Color', 'white', 'Units', 'centimeters', 'Position', [0 0 18 8]);


% sgtitle(FNAME, 'FontSize', 20, 'Interpreter', 'none');

porder              = [1 2; 6 7; 3 4; 8 9; 11 12; 13 14];
for i = 1:6
    subplot(3,5,porder(i,:));
    
    % Determine task order
    if ismember(i, [1 3])
        task_order = 21;        
    elseif ismember(i, [2 4])        
        task_order = 12;
    else
        task_order = 0;
    end
    
    % Draw patches
    p = wave_batches(task_order, YLIMS);    
    
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
    if ~LEGEND_OFF
        if i ==4
            lg = legend([heat p(1) p(2)], {'Heat stimulus', '1-back task', '2-back task'});
            lg.Position = [.83 .45 .1 .1];
            lg.FontSize = 12;
        end
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
    
    % Final touch
    if LABELS_OFF
        lose_labels   
    end
    
    if MODIFY_TBLS
        modify_tbls(TBLS_ALPHA, TBLS_STYLE, LINEWIDTH, task_order, heat)
    end
end

% Save
saveas(gcf, PATH);



% wave_batches
% add wave batches to axis
function p = wave_batches(task_order, yspan)

if task_order == 0
    p = nan;
    return
end

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

% lose_labels
% delete all titles, axis labels, tick labels from current figrue
function lose_labels
title('');
xlabel('');
ylabel('');
xticklabels({});
yticklabels({});

fprintf('\nlost labels O_O\n');

% modify_tbls (modify_twobacklinesegment)
% modify the heat line segments under 2back. following ideas:
% - reduce alpha
% - reduce linewidth
% - change style
%       - tb dashed everything else constant
%       - tb dotted everything else dashed (probably better as heat is dashed
%       throughout all plots

function modify_tbls(alpha, style, line_width, task_order, line)

% Find tb segment
[~,ticks] = getBinBarPos(110);

if task_order == 21
    tb = [ticks(2) ticks(4)];
elseif task_order == 12
    tb = [ticks(4) ticks(6)];
else
    % then we have CRT and nothing to do
    return
end

% Find index of tb
tbidx = find(line.XData >= tb(1) & line.XData < tb(2));

% Copy to new arrays for new tb line
tbx = line.XData(tbidx);
tby = line.YData(tbidx);

% Make old tb segment invisible
line.XData(tbidx) = nan;

% Draw new line
hold on;
plot(tbx, tby,...
    'Color', [0, 0, 0, alpha],...
    'LineWidth', line_width,...
    'LineStyle', style);