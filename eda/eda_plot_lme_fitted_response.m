function eda_plot_lme_fitted_response(lme,data)
% takes in lme object and plots fitted response

betas = fixedEffects(lme);
betas_to_plot = [2,4,5,6]; % diffheat, wm, diffheat*wm
regressors = {'diffheat', 'wm', 'shape'};

data.wm(data.wm == -1) = 0; % So that encoding is 0->1back 1-->2back

% Construct design matrix
sdata = data(data.ID == 7,:);
A = [];
for i = 1:4 % loop through conditions
    A = vertcat(A, sdata{sdata.condition == i, regressors});
    if i == 1
        time = sdata.time_within_trial(sdata.condition == 1); % for plotting
    end
end
A(:,end+1) = A(:,1).*A(:,2);
fitted_response = A*betas(betas_to_plot);


% Prepare for plotting 
fitted_response = reshape(fitted_response, [],4); % so we can loop better
fitted_response(:,end+1:end+2) = nan(size(fitted_response,1),2); % preallocate differences
[m,w,dm,dw] = waveit2(110);
wave_time = linspace(0,110,numel(m));
half = numel(time)/2;

figure('Color', 'white','Name','LME fitted responses')
titles={'M21 and M12','W21 and W12','M: 2back - 1back','W: 2back - 1back'};

for i = 1:4
    subplot(2,2,i); hold on;    
    if i == 1
        % Plot M21
        tb=plot(time(1:half+1), fitted_response(1:half+1,1), 'r-','LineWidth',4);
        ob=plot(time(half:end), fitted_response(half:end,1), 'b-','LineWidth',4);
        % Plot M12
        plot(time(1:half+1), fitted_response(1:half+1,2), 'b-','LineWidth',4)
        plot(time(half:end), fitted_response(half:end,2), 'r-','LineWidth',4)        
        
    elseif i == 2
        % Plot W21
        tb=plot(time(1:half+1), fitted_response(1:half+1,3), 'r-','LineWidth',4);
        ob=plot(time(half:end), fitted_response(half:end,3), 'b-','LineWidth',4);        
        % Plot W12
        plot(time(1:half+1), fitted_response(1:half+1,4), 'b-','LineWidth',4)
        plot(time(half:end), fitted_response(half:end,4), 'r-','LineWidth',4)                
    elseif i == 3
        % M2_ - M1_
        fitted_response(1:half,end-1) = ...
            fitted_response(1:half,1)-fitted_response(1:half,2);        
        
        % M_2 - M_1
        fitted_response(half+1:end,end-1) = ...
            fitted_response(half+1:end,2)-fitted_response(half+1:end,1);
        plot(time,fitted_response(:,end-1), 'r-','LineWidth',4)
        plot(time,fitted_response(:,end-1), 'b--','LineWidth',4)
        
    elseif i ==4
        % W2_ - W1_
        fitted_response(1:half,end) = ...
            fitted_response(1:half,3)-fitted_response(1:half,4);
        % W_2 - W_1
        fitted_response(half+1:end,end) = ...
            fitted_response(half+1:end,4)-fitted_response(half+1:end,3);        
        plot(time,fitted_response(:,end), 'r-','LineWidth',4)
        plot(time,fitted_response(:,end), 'b--','LineWidth',4)        
    end                        
    
    if ismember(i, [1,3])
        wave=plot(wave_time,m, 'k--','LineWidth',2);
        dwave=plot(wave_time, dm, 'k:', 'LineWidth',2);
    else
        plot(wave_time,w, 'k--','LineWidth',2);
        plot(wave_time, dw, 'k:', 'LineWidth',2);
    end
    
    if i == 1
        legend([tb,ob,wave,dwave], {'2back','1back','heat stimulus', "heat stimulus'"});
    end
    title(titles{i}, 'FontWeight','bold', 'FontSize',14);    
    wavexaxis;
    waveyaxis('SCL fitted response', [-1 1]);
end



