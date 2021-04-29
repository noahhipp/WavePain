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
columns_to_plot = {'zdtm_scl','zdt_scl'};
titles = {'session zscore --> session detrend --> trial demean',...
    'trial zscore --> trial detrend'};
condition_names = {'M21','M12', 'W21','W12','Monline','Wonline'};

for i = 1:numel(columns_to_plot)
    % Prepare error column
    col_to_plot = columns_to_plot{i};
    error_column=strcat('sem_',col_to_plot);        

    figure('Position',[0,0,1000,800], 'Color', 'white')
    sgtitle(titles{i},'FontSize',20, 'FontWeight', 'bold', 'Interpreter', 'none');
    ylab = 'SCL [Zscores]';
    porder              = [1 2; 1 2; 3 4; 3 4;  6 7; 8 9];

    for j = [unique(data.condition)', 1 2 3 4] % our conditions and then our baseline conditions again                
        
        % Grab data
        trial   = data(data.condition==j,:);
        signal = trial{:,col_to_plot};
        signal = circshift(signal, -6);
        sem    = trial{:,error_column};
        sem = circshift(sem, -6);

        % Plot it
        subplot(3,5,porder(j,:));
        line = waveplot(signal, condition_names{j}, sem);            
        hold on; 
        wave = plot(trial.heat .* 0.4, 'k--', 'LineWidth',3);
        
        % Settings
        wavexaxis2;
        if ismember(j, [1 2 5])
            waveyaxis(ylab, [-0.7,0.7]);              
        else
            waveyaxis('',[-0.7,0.7]);
        end
        
        % Legend
        if j == 4
            online = plot(1,0.3, '-*', 'LineWidth', 4, 'Color', [0.1725 0.4824 0.7137]);
            blank = plot(1,0.1,'w-');
            lg =legend([line(1:3) online blank wave],{'...no task', '...1-back','...2-back','...online rating','','Heat stimulus'});
            lg.Position= [0.83 .45, 0.1 0.1];
            lg.Title.String = 'SCL during...';
            lg.FontSize = 12;
        end
        
        % Switch column and prepare for difference plotting
        if j == 6
            ylab = strcat('\Delta', ylab);
            col_to_plot = strcat(col_to_plot, '_bl');
            error_column=strcat('sem_',col_to_plot);
            porder = porder + 10;
        end                
    end % condition loop end
end
