function eda_plot_fitted_response(betas)

% load design matrix
load("E:\wavepain\data\behav_sample\eda\xX.mat");

if numel(betas) == 7
    betas = [betas betas(1) betas(2) betas(5)];
end

% get fitted responses
disp(betas);
betas = betas';
wm_response = A.wm * betas(1:7);
online_response = A.online * betas(8:end);

% reshape for plotting
wm_response = reshape(wm_response',[],4);
online_response = reshape(online_response',[],2);

figure('Color', 'white', 'Name','fitted scl_response');
condition_names = {'M21','M12', 'W21','W12','Monline','Wonline'};

responses = [wm_response, online_response];
porder = [1 1 2 4 5 6];
for i = 1:6
    subplot(3,2,porder(i)); hold on;
    waveplot(responses(:,i), condition_names{i});    
    title(condition_names{i});
    wavexaxis;
end
