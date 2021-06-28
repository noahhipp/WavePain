function nii_infos = wave_summarise
% wrapper around spm_summarise to display information about nii

[base_dir] = wave_ghost;

% Settings
all_subs            = [5:12];
anadirname          = 'canonical_pmodV4'; 
file_templ          = 's6w*.nii';


% Collect data
nii_infos = [];
niis = {};

for i = 1:numel(all_subs)
    name        = sprintf('sub%03d',all_subs(i));
    sub_dir     = fullfile(base_dir, name, anadirname);
    sub_files   = dir(fullfile(sub_dir, file_templ));
    
    for j = 1:numel(sub_files)
        nii = fullfile(sub_files(j).folder, sub_files(j).name);                
        niis = [niis nii]; 
        % Check if it exists
        if ~exist(nii, 'file')
            error('%s does not exist', nii);
        end
        
        % Collect information and append to output
        nii_info    = get_nii_info(nii);
        nii_infos   = vertcat(nii_infos,...
            [j all_subs(i), nii_info]);                                                                        
    end
end

nii_infos = array2table([nii_infos [1:height(nii_infos)]'] , 'VariableNames',...
    {'n','id','mean','min','max','idx'});
nii_infos = sortrows(nii_infos,'n','ascend');

idx = nii_infos.idx;
nii_infos.idx =  [];

ax = imagesc_nii_infos(nii_infos);
ax.YAxis.TickValues = 1:height(nii_infos);
ax.YAxis.TickLabels = niis(idx);
    
    


% =====================SUBFUNCTIONS========================================
% get_nii_info
% get return mean, min, max of nii
function out = get_nii_info(nii)
fprintf('\nsummarising %s...', nii);
nii_mean    = spm_summarise(nii, 'all',@mean);
nii_min     = spm_summarise(nii, 'all',@min);
nii_max     = spm_summarise(nii, 'all',@max);
out         = [nii_mean, nii_min, nii_max];
fprintf('✓');


% imagesc_img_info
% visualize img_info using imagesc
function ax = imagesc_nii_infos(nii_infos)
figure;
im = imagesc(nii_infos{:,3:end});
ax = im.Parent;
colorbar;
xticks([1:3]);
xticklabels({'mean','min','max'});       
% ====================SUBFUNCTIONS END=====================================

