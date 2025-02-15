function export_values_from_spm_graph

% Settings
do_save = 1;

xG.def              = 'Contrast estimates and 90% C.I.';

contrasts_to_plot   = [361]; % contrasts we want to plot
voxels_to_plot      = 5; % plot top [] voxels

% Grab variables from base workspace
global st;
SPM             = evalin('base', 'SPM');
xSPM            = evalin('base', 'xSPM'); 
results_table   = evalin('base', 'TabDat.dat');
cd(SPM.swd);

% Housekeeping
xA                      = spm_atlas('load', 'Neuromorphometrics');
contrast_names          = {};
for i = 1:numel(contrasts_to_plot)
    contrast_names{i}   = SPM.xCon(contrasts_to_plot(i)).name;
end
base_dir                = '/home/hipp/projects/WavePain/results/spm/';
contrast_dir            = strjoin(contrast_names, '_and_');
save_dir                = fullfile(base_dir, contrast_dir);
if ~exist(save_dir, 'dir')
    mkdir(save_dir)
end

% Loop through results table
i               = 1;
vi              = 0; % voxel index
while vi <= voxels_to_plot    
    if ~isempty(results_table{i,3}) % black voxel in results table, we care about those
        
        % Get coordinates and label
        xyz_rd  = results_table{i,12};
        xyz     = SPM.xVol.iM(1:3,:)*[xyz_rd;ones(1,size(xyz_rd,2))]; 
        region  = spm_atlas('query', xA, xyz_rd);
        
        % Now loop through our contrasts
        figure('Name', 'template', 'Position', [0 0 1920 1080], 'Color', [1, 1, 1]);        
        if vi == 3
            fprintf('\n YES \n');
        end
        
        for j = 1:size(contrasts_to_plot,2)
            xG.spec.Ic              = contrasts_to_plot(j);
            [~, ~, ~, ~, data]      = spm_graph(SPM, xyz, xG);
            errorbar(data.contrast, data.standarderror);            
            hold on;            
        end
        
        % Customize figure
        legend(char(contrast_names), 'FontSize', 20)
        title(sprintf('Voxel coordinates: x=%1.1f y=%1.1f z=%1.1f aka %s',xyz_rd, region), 'FontSize', 20)
        ylim([-0.3 0.3]);        
                 
        % Save figure
        if do_save
            fname = sprintf('%02d_export_%s', vi,matlab.lang.makeValidName(region));
            print(fullfile(save_dir, fname),'-dpng','-r300') ;
        end
        
        close template; % close figure        
        vi      = vi+1; % as we just plotted voxel we care about
    end
    i           = i+1; % in any case go to the next one
end