function smooth_nh
hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 4;
        
        case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 4;
	
       otherwise
        error('Only hosts noahs isn laptop accepted');
end

check = 0;

subs = [5:12, 14:53];

ra_func_name      = 'rafMRI.nii';

epi_folders       = {'run001/mrt','run002/mrt'};

spm_path = fileparts(which('spm')); %get spm path
template_path = [spm_path filesep 'toolbox\cat12\templates_1.50mm' filesep]; % get newest toolbox
tpm_path = [spm_path filesep 'tpm' filesep];
if strcmp(hostname, 'revelations')
    tpm_path = '/projects/crunchie/hipp/wavepain/tpm/';
end


matlabbatch = [];
gi = 1;
    
    for g = 1:numel(subs)
        name = sprintf('sub%03d',subs(g));
        fprintf('Doing volunteer %s\n', name);
        
        % collect epis
        for i=1:size(epi_folders,2)
            % already did 4D conversion and deleted 3D                        
            rafourD = fullfile(base_dir, name, epi_folders{i}, ra_func_name);            
            if exist(rafourD, 'file')                
                 epi_files{i} = cellstr(spm_select('expand',rafourD));
                 fprintf('sess%d: %d epis found', i, numel(epi_files{i}));
            else
                error('epis missing');
            end            
        end % epi folder loop
        fprintf('\n\n');
        
        % Smooth
        for i = 1:size(epi_folders,2)
            matlabbatch{gi}.spm.spatial.smooth.data = cellstr(epi_files{i});
            matlabbatch{gi}.spm.spatial.smooth.fwhm = [6 6 6];
            matlabbatch{gi}.spm.spatial.smooth.dtype = 0;
            matlabbatch{gi}.spm.spatial.smooth.im = 0;
            matlabbatch{gi}.spm.spatial.smooth.prefix = 's';
            gi = gi + 1;
        end
    
    end % subject loop
    if ~isempty(matlabbatch)
        run_spm_parallel(matlabbatch, n_proc);
    end





% Subfunctions
function run_matlab(np, matlabbatch, check) 

spm_path          = fileparts(which('spm')); %get spm path
mat_name          = which(mfilename);
[~,mat_name,~]    = fileparts(mat_name);


fname = [num2str(np) '_' mat_name '.mat'];

save([num2str(np) '_' mat_name],'matlabbatch');
lo_cmd  = ['clear matlabbatch;load(''' fname ''');'];
ex_cmd  = ['addpath(''' spm_path ''');spm(''defaults'',''FMRI'');spm_jobman(''initcfg'');spm_jobman(''run'',matlabbatch);'];
end_cmd = ['delete(''' fname ''');'];
if ~check
    system(['start matlab.exe -nodesktop -nosplash  -logfile ' num2str(np) '_' mat_name '.log -r "' lo_cmd ex_cmd end_cmd 'exit"']);
end

function chuckCell = splitvect(v, n)
% Splits a vector into number of n chunks of  the same size (if possible).
% In not possible the chunks are almost of equal size.
%
% based on http://code.activestate.com/recipes/425044/
chuckCell  = {};
vectLength = numel(v);
splitsize  = 1/n*vectLength;
for i = 1:n
    idxs = [floor(round((i-1)*splitsize)):floor(round((i)*splitsize))-1]+1;
    chuckCell{end + 1} = v(idxs);
end