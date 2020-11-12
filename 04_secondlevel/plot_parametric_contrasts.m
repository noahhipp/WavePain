function parametric_contrasts = plot_parametric_contrasts(varargin)
% Clarifies where values from parametric contrats stem from and returns
% corresponding timeseries. Plotting can be toggled with show

if nargin
    show = varargin{1};
else
    show = 1;
end

% Get high res waves
[m, w]  = waveit2(55000);
pm = [m, zeros(1,5000)]; % for plotting later
m       = zscore([m, zeros(1,5000)]); % zscore and append zeros at the end
w       = zscore([w, zeros(1,5000)]);

x       = linspace(0,120, 60000);
xq      = linspace(1,119, 60);

% Sample down
dsm     = interp1(x,m,xq);
dsw     = interp1(x,w,xq);

% Task regressors;
obtb = [zeros(1,11) -ones(1,17) ones(1,17), zeros(1,15)];
tbob = -obtb;

% Interactions
m21 = dsm .* tbob;
m12 = dsm .* obtb;
w21 = dsw .* tbob;
w12 = dsw .* obtb;

% Build return structure
parametric_contrasts    = struct;
parametric_contrasts.m  = dsm;
parametric_contrasts.w  = dsw;

parametric_contrasts.obtb = obtb;
parametric_contrasts.tbob = tbob;

parametric_contrasts.m21 = m21;
parametric_contrasts.m12 = m12;
parametric_contrasts.w21 = w21;
parametric_contrasts.w12 = w12;

% Plot
if show
    [~,ticks] = getBinBarPos(110);
    
    for i = 1:12
        switch i
            case 1
                figure('Color',[1 1 1], 'Name', 'M heat regressor ');
                subplot(2,1,1);
                hold on;
                plot(x,m,'k-','LineWidth',4);
                vline(xq,'r--*');
                vline(xq+1,'k-');
                plot(1,1,'k-'); % plot invisible lines with vline properties to use those as alibis in legend
                plot(1,1,'r--');
                legend('thermode stimulus', 'FIR bin borders', 'extracted values for contrast', 'FontSize', 14);
            case 2
                subplot(2,1,2);
                plot(xq,dsm','r-*');
                legend('Heat contrast','FontSize', 14);
                ylim([-2,2]);
            case 3
                figure('Color',[1 1 1], 'Name', 'W heat regressor ');
                subplot(2,1,1);
                hold on;
                plot(x,w,'k-','LineWidth',4);
                vline(xq,'r--*')
                vline(xq+1,'k-');
                plot(1,1,'k-'); % plot invisible lines with vline properties to use those as alibis in legend
                plot(1,1,'r--');
                legend('thermode stimulus', 'FIR bin borders', 'extracted values for contrast', 'FontSize', 14);
            case 4
                subplot(2,1,2);
                plot(xq,dsw','r-*');
                legend('Heat contrast','FontSize', 14);
                ylim([-2,2]);
                
            case 5
                figure('Color',[1 1 1], 'Name', '21 working memory regressor ');
                subplot(2,1,1);
                hold on;
                plot(x,m,'k-','LineWidth',4);
                vline(xq(12:28),'r-*');
                vline(xq(29:45),'b-*');
                vline(xq+1,'k-'); % fir borders
                plot(1,1,'k-'); % plot invisible lines with vline properties to use those as alibis in legend
                plot(1,1,'r-');
                plot(1,1,'b-');
                legend('thermode stimulus', 'FIR bin borders', 'bins for 2back','bins for 1back', 'FontSize', 14);
            case 6
                subplot(2,1,2);
                hold on;
                
                stim = plot(x,pm, 'k--', 'LineWidth', 2);
                
                plot(xq(1:12),tbob(1:12),'k-*', 'LineWidth',4);
                nb =plot(xq(45:end),tbob(45:end),'k-*', 'LineWidth',4);
                tb = plot(xq(12:28),tbob(12:28),'r-*', 'LineWidth',4);
                plot(xq(28:29),tbob(28:29), 'r-', 'LineWidth',4);
                ob = plot(xq(29:45),tbob(29:45),'b-*', 'LineWidth',4);
                ylim([-2,2]);
                
                legend([nb, tb, ob, stim],...
                    {'Working memory contrast (no task)', 'Working memory contrast (2back)',...
                    'Working memory contrast (1back)', 'thermode stimulus' });
                
            case 7
                figure('Color',[1 1 1], 'Name', '12 working memory contrast ');
                subplot(2,1,1);
                hold on;
                plot(x,m,'k-','LineWidth',4);
                vline(xq(12:28),'b-*');
                vline(xq(29:45),'r-*');
                vline(xq+1,'k-'); % fir borders
                plot(1,1,'k-'); % plot invisible lines with vline properties to use those as alibis in legend
                plot(1,1,'b-');
                plot(1,1,'r-');
                legend('thermode stimulus', 'FIR bin borders', 'bins for 1back','bins for 2back', 'FontSize', 14);
            case 8
                subplot(2,1,2);
                hold on;
                
                stim = plot(x,pm, 'k--', 'LineWidth', 2);
                plot(xq(1:12),obtb(1:12),'k-*', 'LineWidth',4);
                nb = plot(xq(45:end),obtb(45:end),'k-*', 'LineWidth',4);
                ob = plot(xq(12:28),obtb(12:28),'b-*', 'LineWidth',4);
                plot(xq(28:29),obtb(28:29), 'b-', 'LineWidth',4);
                tb = plot(xq(29:45),obtb(29:45),'r-*', 'LineWidth',4);
                ylim([-2,2]);
                
                legend([nb, ob, tb, stim],...
                    {'Working memory contrast (no task)', 'Working memory contrast (1back)',...
                    'Working memory contrast (2back)', 'thermode stimulus'});
                
            case 9
                figure('Color',[1 1 1], 'Name', 'Heat x working memory');
                subplot(2,2,1);
                hold on;
                plot(xq(1:12),m21(1:12),'k-*', 'LineWidth',4);
                nb = plot(xq(45:end),m21(45:end),'k-*', 'LineWidth',4);
                tb = plot(xq(12:28),m21(12:28),'r-*', 'LineWidth',4);
                plot(xq(28:29),m21(28:29), 'r-', 'LineWidth',4);
                ob = plot(xq(29:45), m21(29:45),'b-*', 'LineWidth',4);
                legend([nb, tb, ob],...
                    {'Heat X working memory contrast (no task)', 'Heat X working memory contrast (2back)',...
                    'Heat X working memory contrast (1back)'}, 'Location','best');
                title('M21', 'FontSize', 16);
                
            case 10                
                subplot(2,2,3);
                hold on;
                plot(xq(1:12),m12(1:12),'k-*', 'LineWidth',4);
                nb = plot(xq(45:end),m12(45:end),'k-*', 'LineWidth',4);
                ob = plot(xq(12:28),m12(12:28),'b-*', 'LineWidth',4);
                plot(xq(28:29),m12(28:29), 'b-', 'LineWidth',4);
                tb = plot(xq(29:45), m12(29:45),'r-*', 'LineWidth',4);
                legend([nb, ob, tb],...
                    {'Heat X working memory contrast (no task)', 'Heat X working memory contrast (1back)',...
                    'Heat X working memory contrast (2back)'}, 'Location','best');
                title('M12', 'FontSize', 16);
                
            case 11                
                subplot(2,2,2);
                hold on;
                plot(xq(1:12),w21(1:12),'k-*', 'LineWidth',4);
                nb = plot(xq(45:end),w21(45:end),'k-*', 'LineWidth',4);
                tb = plot(xq(12:28),w21(12:28),'r-*', 'LineWidth',4);
                plot(xq(28:29),w21(28:29), 'r-', 'LineWidth',4);
                ob = plot(xq(29:45), w21(29:45),'b-*', 'LineWidth',4);
                legend([nb, tb, ob],...
                    {'Heat X working memory contrast (no task)', 'Heat X working memory contrast (2back)',...
                    'Heat X working memory contrast (1back)'}, 'Location','best');
                title('W21', 'FontSize', 16);
                
            case 12                
                subplot(2,2,4);
                hold on;
                plot(xq(1:12),w12(1:12),'k-*', 'LineWidth',4);
                nb = plot(xq(45:end),w12(45:end),'k-*', 'LineWidth',4);
                ob = plot(xq(12:28),w12(12:28),'b-*', 'LineWidth',4);
                plot(xq(28:29),w12(28:29), 'b-', 'LineWidth',4);
                tb = plot(xq(29:45), w12(29:45),'r-*', 'LineWidth',4);
                legend([nb, ob, tb],...
                    {'Heat X working memory contrast (no task)', 'Heat X working memory contrast (1back)',...
                    'Heat X working memory contrast (2back)'}, 'Location','best');
                title('W12', 'FontSize', 16);
        end
        
        %
        
        xticks(ticks);
        ax = gca;
        ax.FontSize = 16;
        xlabel('Time [s]');
        grid on;
        
    end
    
    
    
end