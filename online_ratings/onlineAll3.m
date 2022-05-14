function onlineAll3
% Makes onlineScl + Rating + Stimulus plots for CB

% Options
plotOption = [1 1];

% Collect data
ratings = readtable('C:\Users\hipp\projects\WavePain\data\fmri_sample\all_subs\online_everything_collapsed.csv');
scl = readtable('C:\Users\hipp\projects\WavePain\data\fmri_sample\all_subs\all_eda_collapsed.csv');

% ratingsem = std(ratings, 0, 3) / sqrt(size(ratings,3));
% ratings = mean(ratings,3);
xratings = linspace(0,110, 1100);
% 
% sclsem = std(scl, 0, 3) / sqrt(size(scl,3));
% scl = mean(scl,3);
xscl = linspace(0,110,4400);

[wave(1,:) wave(2,:)] = waveit(1100,[-15,75]);





% Temp + Rating

% Make figure
figure('Name','CB: online t + r','NumberTitle','off', 'Color',[1 1 1]);
titles = {'N = 47', 'N = 47'};
for n = 1:2
    subplot(2,1,n)
    
    % Plot temp
    temp = plot(xratings,wave(n,:), 'k--', 'LineWidth', 2); hold on;
    ylabel('\bf VAS', 'FontSize', 14); ylim([0 100]);
    xlabel('\bf Time (s)', 'FontSize', 14); xlim([0 110]);
    title(titles{n}, 'FontSize', 20, 'FontWeight', 'bold');
    ax = gca;
    Xachse = ax.XAxis;
    Xachse.TickValues = [0 55 110];
    Xachse.TickLabels = {'0','55', '110'};
    Xachse.FontSize = 14;
    Yachse = ax.YAxis;
    Yachse.TickValues = [0 30 60 100];
    Yachse.TickLabels = {'0','30', '60', '100'};
    Yachse.FontSize = 14;
    
    % Plot Rating
    if plotOption(1)
    rating = ratings.mean_rating(ratings.shape == n);
    ratingsem = ratings.sem(ratings.shape == n);
    line = boundedline(xratings, rating, ratingsem, 'r-', 'alpha');  
    line.LineWidth = 4;
    end
    
    % Plot SCL
    if plotOption(2)
    yyaxis right   
    ylabel('\bfSCL (Zscores)', 'FontSize', 14);
    ylim([-1 1]);
    dscl = scl.mean_scl(scl.condition==n+4);
    dsclsem = scl.sem(scl.condition==n+4);
    line2 = boundedline(xscl-6.3, dscl(1:4400), dsclsem(1:4400), 'b-', 'alpha'); % 6.3s comes from fmri_eda_analysis.m
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
