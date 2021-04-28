function eda_secondlevel_plots
% Makes a bunch of 3x2 wavepain plots for different preprocessings of
% wavepain eda

% Housekeeping
eda_name_in      = 'all_eda_clean_downsampled_collapsed_collapsed.csv';
[~,~,~,eda_dir] = wave_ghost;
eda_file_in       = fullfile(eda_dir, eda_name_in);

% Read in data
data = readtable(eda_file_in);

% Plotting
% columns_to_plot = {'raw_eda', 'native_scl','z_scl','z_eda','zdtdt_scl','zdtm_scl','scl', 'zdt_scl', 'zdtm_scl_bl', 'zdt_scl_bl'};
columns_to_plot = {'zdtm_scl','zdt_scl', 'zdtm_scl_bl', 'zdt_scl_bl'};
condition_names = {'M21','M12', 'W21','W12','Monline','Wonline'};
porder          = [1 1 2 2 3 4];

errors = {};
for c = columns_to_plot
    % Prepare error column
    error_column=strcat('sem_',c{1});

    figure('Position',[0,0,1000,800])
    sgtitle(c{1},'FontSize',20, 'FontWeight', 'bold', 'Interpreter', 'none');

    for i = unique(data.condition)'        
        trial   = data(data.condition==i,:);
        signal = trial{:,c{1}};
        sem    = trial{:,error_column};

        % Plot it
        subplot(2,2,porder(i));
        waveplot(signal, condition_names{i}, sem);            
        hold on; 
        plot(trial.heat .* 0.4, 'k--', 'LineWidth',4);
        
        % Settings
        wavexaxis2;
        waveyaxis('SCL [Zscores]', [-0.7,0.7]);              
    end % condition loop end
end
