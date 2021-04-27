function eda_firstlevel_plots
% Makes classic 5x2 Wavepain plots

do_save = 0;

% Housekeeping
eda_name_in       = 'all_eda_clean_downsampled_collapsed.csv';
[~,~,~,eda_dir,cloud_dir] = wave_ghost;
eda_file_in       = fullfile(eda_dir, eda_name_in);
save_path         = fullfile(cloud_dir, '21_04_27_eda_analysis\zdtm_scl');

if ~exist(save_path, 'dir')
    mkdir(save_path);
end

% Get data
data = readtable(eda_file_in);

% Plotting settings
porder          = [1 3 2 4 5 6];
condition_names = {'M21','M12', 'W21','W12','Monline','Wonline'};


for i = unique(data.ID)'
    figure('Position',[0 0 1920 1080]);
    sgtitle(sprintf('sub%03d',i));
    fprintf('=====\nPlotting sub%03d\n', i);
    
    for j = unique(data.condition(data.ID == i))'
        trial = data(data.ID == i & data.condition == j,:);
        
        subplot(3,2,porder(j));
        waveplot(trial.zdtm_scl, condition_names{j}, trial.sem_zdtm_scl);
        hold on;        
    end
    
    % Save figure
    fig_name = sprintf('sub%03d',i);
    fig_file = fullfile(save_path,fig_name);
    print(fig_file, '-dpng','-r300');
    fprintf('Saved sub%03d\n',i);    
end



