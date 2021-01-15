function wave_tconplot_batch(tcons, tcon_names)
% takes an array of tcons and an cell array with names (as the SPM
% tcon_util would) and makes a figure for each according to wavepain
% standards


do_save = 1;
ylims = [-3.5, 3.5];

% Checks
if size(tcons,1) ~= numel(tcon_names)
    error('Number of names specified does not match number of contrasts provided');
end

% Housekeeping
save_at = '21_01_14_parametric_contrasts_cb3';
base_dir = 'C:\Users\hipp\projects\WavePain\results';
save_dir = fullfile(base_dir, save_at);

% Open figure
figure('Color', 'white', 'Position', [0 0 1920 1080]);

% Loop through figures start
for i = 1:numel(tcon_names)
    % Plot contrast
    wave_tconplot(tcons(i,:), tcon_names{i}, ylims);
    
    % Save figure
    if do_save        
        fig_name = fullfile(save_dir, sprintf('%02d_%s', i,tcon_names{i}));
        try
            print(fig_name,'-dpng','-r300')
        catch
            fig_name = fullfile(save_dir, sprintf('%02d_catchname', i));
            print(fig_name, '-dpng', '-r300');            
        end
    end
    
    % Close/clear figure
    clf('reset');        
end % Loop throuh figures end
