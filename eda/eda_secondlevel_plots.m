function eda_secondlevel_plots
% Makes a bunch of 3x2 wavepain plots for different preprocessings of
% wavepain eda

% Housekeeping
EDA_NAME_IN      = 'all_eda_behav_downsampled10_collapsed_collapsed.csv';
SHIFT_NAME       = 'eda_bestshifts.csv';
[~,~,~,EDA_DIR]  = wave_ghost('behav');
EDA_FILE_IN      = fullfile(EDA_DIR, EDA_NAME_IN);
SHIFT_FILE       = fullfile(EDA_DIR, SHIFT_NAME);
F                = 10; % Sampling freq of our data

% Read in data
data   = readtable(EDA_FILE_IN);
SHIFTS = readtable(SHIFT_FILE);
shift  = SHIFTS.fmri_all;

% Plotting
% columns_to_plot = {'raw_eda', 'native_scl','z_scl','z_eda','zdtdt_scl','zdtm_scl','scl', 'zdt_scl', 'zdtm_scl_bl', 'zdt_scl_bl'};
columns_to_plot = {'s_zt_scl', 's_zt_dtt_scl', 'special_scl'};
titles = columns_to_plot;
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
        sem    = trial{:,error_column};
        
%        % Shift data
%         signal = nanshift(signal, shift*F);
%         sem = nanshift(sem, shift*F);

        % Plot it
        subplot(3,5,porder(j,:));
        line = waveplot(signal, condition_names{j}, sem);            
        hold on; 
        wave = plot(trial.time_within_trial,trial.heat .* 0.4, 'k--', 'LineWidth',3);
        
        % Settings
        wavexaxis2;
        if ismember(j, [1 2 5])
            waveyaxis(ylab, [-0.8,0.8]);              
        else
            waveyaxis('',[-0.8,0.8]);
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
