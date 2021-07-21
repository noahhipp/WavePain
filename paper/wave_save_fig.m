function wave_save_fig(varargin)
% saves figure to paper path 

if ~nargin
    fname = 'noname';
else
    fname = varargin{1};
end

[~,~,~,~,cloud_dir] = wave_ghost;
save_dir            = fullfile(cloud_dir, 'paper','figures');
save_file = fullfile(save_dir, fname);

print(save_file,'-r300', '-dpdf');