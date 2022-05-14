function [refM,refW] = onlineAll(varargin)
% Plots OnlineRatings and SCL (first and second level)

detrendScl = 1;
highPass = 0;
if nargin == 1
    detrendScl = 1;
elseif nargin == 2;
    highPass = 1;
end


% First Level
subjects = [15:35]; % All subs with OnlineRatings
onlineRatings = [];
onlineScl = [];
online_table = table;
unsorted_online_scl = [];

for n = 1:numel(subjects)
    S = subject(subjects(n),1);
    [oR,scl] = S.plotOnlineRating;
    if n ~= 1
        lap = length(scl) - length(onlineScl);
        if lap < 0
            scl = vertcat(scl,nan(-1*lap,4));
        elseif lap > 0
            scl = scl(1:end-lap,:);
        end
    end
    onlineRatings(:,:,n) = oR;
    onlineScl(:,:,n) = scl;
    online_table = vertcat(online_table, S.onlineRating);    
end


% Second level
subjects = [15:35]; % All subs with OnlineRatings
onlineRatings = nanmean(onlineRatings,3);
xForRatings = linspace(0,110,size(onlineRatings,1));
% eScl = nanstd(onlineScl,0,3)/sqrt(numel(subjects));
onlineScl = nanmean(onlineScl,3);
xForScl = linspace(0,110,size(onlineScl,1));

conversionString = 'MWMW';
[M,W] = waveit(110,[-15 75]);

figure('Name', 'ALL: 4 OnlineRatings + SCL','NumberTitle','off');

for n = 1:size(onlineRatings,2) + 2
    
    % Get data
    if n < 5
        cRatings = onlineRatings(:,n);
        cScl= onlineScl(:,n);
    elseif n == 5
        figure('Name', 'ALL: 2 OnlineRatings + SCL','NumberTitle','off');
        subplot(2,1,1);
        cRatings = nanmean(onlineRatings(:,[1 3]),2);
        cScl = nanmean(onlineScl(:,[1 3]),2);
        refM = cScl;
        title(sprintf('N = %d Shape: M both Microblocks',numel(subjects)));
    else
        subplot(2,1,2);
        cRatings = nanmean(onlineRatings(:,[2 4]),2);
        cScl = nanmean(onlineScl(:,[2 4]),2);
        refW = cScl;
        title(sprintf('N = %d Shape: W both Microblocks',numel(subjects)));
    end
    
    % Plot ratings
    if n < 5
        subplot(2,2,n);
        title(sprintf('N = %d\nShape: %s Microblock: %d',numel(subjects),conversionString(n), ceil(n/2)));
    end
    yyaxis right
    plot(xForRatings,cRatings,'r'); xlim([0 110]); ylim([0 100]);
    xlabel('time (s)'); ylabel('VAS');
    
    % Plot stimulus
    hold on
    if ismember(n,[1 3 5]) % if M-Wave
        plot(M,'k--')
    else % if W-Wave
        plot(W,'k--')
    end
    
    % Plot Scl
    yyaxis left
    label = 'SCL';        
    plot(xForScl, cScl, 'b');    
    sclMean = nanmean(cScl);
    ylim([sclMean - 1, sclMean + 1]);
    ylabel('SCL (Zscores)');
    legend(label,'Online-Ratings','Thermode');
end





