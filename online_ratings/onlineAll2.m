function onlineAll2
% Makes onlineScl + Rating + Stimulus plots for CB

% Options
plotOption = [1 1];

% Collect data
ratings = getAll('onlineRatingsAll.mat', 'sortedOnlineRatings', 2, 3, 2);
scl = getAll('onlineSCLAll.mat', 'sortedOnlineScl', 2, 3, 1);

ratingsem = std(ratings, 0, 3) / sqrt(size(ratings,3));
ratings = mean(ratings,3);
xratings = linspace(0,size(ratings,1), size(ratings,1));

sclsem = std(scl, 0, 3) / sqrt(size(scl,3));
scl = mean(scl,3);
xscl = linspace(0,size(ratings,1),size(scl,1));

[wave(1,:) wave(2,:)] = waveit(size(ratings,1),[-15,75]);





% Temp + Rating

% Make figure
figure('Name','CB: online t + r','NumberTitle','off', 'Color',[1 1 1]);
titles = {'M', 'W'};
for n = 1:2
    subplot(2,1,n)
    
    % Plot temp
    temp = plot(wave(n,:), 'k--', 'LineWidth', 2); hold on;
    ylabel('\bf VAS', 'FontSize', 14); ylim([0 100]);
    xlabel('\bf Time (s)', 'FontSize', 14); xlim([0 size(ratings,1)]);
    title(titles{n}, 'FontSize', 24);
    ax = gca;
    Xachse = ax.XAxis;
    Xachse.TickValues = [0 550 1100];
    Xachse.TickLabels = {'0','55', '110'};
    Xachse.FontSize = 14;
    Yachse = ax.YAxis;
    Yachse.TickValues = [0 30 60 100];
    Yachse.TickLabels = {'0','30', '60', '100'};
    Yachse.FontSize = 14;
    
    % Plot Rating
    if plotOption(1)
    line = boundedline(xratings, ratings(:,n), ratingsem(:,n), 'r-', 'alpha');  
    line.LineWidth = 4;
    end
    
    % Plot SCL
    if plotOption(2)
    yyaxis right   
    ylabel('\bfSCL (Zscores)', 'FontSize', 14);
    ylim([-1.3 1.3]);
    line2 = boundedline(xscl, scl(:,n), sclsem(:,n), 'b-', 'alpha');
    line2.LineWidth = 4;    
    ax = gca;  
    Yachse = ax.YAxis;
    Yachse(2).Color = [0 0 0];
    Yachse(2).TickValues = [-1 0 1];
    Yachse(2).FontSize = 14;
    end
    
    % Legend
    if sum(plotOption) == 2
        l=legend([temp, line, line2], 'Heat stimulus','Online rating', 'Online SCL', 'FontSize', 14);
    elseif plotOption(1) == 1
        l=legend([temp, line], 'Heat stimulus', 'Online rating');
    elseif plotOption(2) == 1
        l=legend([temp, line2], 'Heat stimulus', 'Online SCL');
    end
    l.FontSize = 14;
    l.FontWeight = 'bold';
end
