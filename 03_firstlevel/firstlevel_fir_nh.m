function firstlevel_fir_nh

hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 1;
    otherwise
        error('Only hosts noahs isn laptop accepted');
end


% Settings

do_specify      = 1;
do_estimate     = 1;

subs = 10;
%subs = [5:12 14:53];

TR = 1.599;

ana_dirname     = 'fir_firstlevel';

struc_templ       = '^sPRISMA.*\.nii';

func_file       = '^rafMRI.nii';
realign_str     =  'rp_afMRI.txt';

epi_folders     = {'run001/mrt/', 'run002/mrt/'};
conditions      = {'M21', 'M12', 'W21', 'W12', 'M_Online', 'W_Online'};

n_sess          = size(epi_folders,2);
n_cond          = size(conditions,2);

spm_path          = fileparts(which('spm')); %get spm path
mat_name          = which(mfilename);
[~,mat_name,~]    = fileparts(mat_name);

% Collect onsets
onset_file = fullfile(base_dir, 'all_onsets.mat');
load(onset_file, 'all_RES');

% Preallocate two batches to pass to run_spm_parallel later
matlabbatch = []; % one for specifying the model
mbi = 1;
estimationbatch = []; % one for estimation
ebi = 1;

for i = 1:numel(subs)        
    % --------------------------------
    %House keeping stuff
    name = sprintf('sub%03d',subs(i));
    fprintf(['Doing volunteer ' name '\n']);
    sub_res = all_RES.(name); % condition onsets
    
    % Collect T1
    st_dir       = fullfile(base_dir, name,'run000/mrt/');
    struc_file   = spm_select('FPList', st_dir, struc_templ);
    skull_file   = spm_select('FPList', st_dir, '^skull_strip.nii');
    
    % Collect epis
    for j=1:n_sess
    
        epi_files{j} = spm_select('ExtFPList', fullfile(base_dir, name, epi_folders{j}), func_file);
        fprintf('session %d: %d smoothed epis found\n', j, size(epi_files{j},1));
    end    
    
    % Some struc file (?)
    u_rc1_file   = ins_letter(struc_file,'u_rc1');
    
    % Analysis directory
    a_dir    = fullfile(base_dir, name, ana_dirname);
    
    % --------------------------------
    
    % --------------------------------
    % Fill matlabbatch
    matlabbatch{mbi}.spm.stats.fmri_spec.timing.units   = 'scans';
    matlabbatch{mbi}.spm.stats.fmri_spec.timing.RT      = TR;
    matlabbatch{mbi}.spm.stats.fmri_spec.timing.fmri_t  = 16;% n_slices; %?
    matlabbatch{mbi}.spm.stats.fmri_spec.timing.fmri_t0 =  8; % n_slices / 2;
    
    matlabbatch{mbi}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
    matlabbatch{mbi}.spm.stats.fmri_spec.bases.fir.length = 120;
    matlabbatch{mbi}.spm.stats.fmri_spec.bases.fir.order  = 60;
    matlabbatch{mbi}.spm.stats.fmri_spec.volt             = 1;
    
    matlabbatch{mbi}.spm.stats.fmri_spec.global           = 'None';
    
    % CB FRAGEN !!!
    matlabbatch{mbi}.spm.stats.fmri_spec.cvi              = 'None';
    
    % Collect mask oder so
    unsmoothed = 1;
    if unsmoothed
        matlabbatch{mbi}.spm.stats.fmri_spec.mask             = cellstr(skull_file);
        matlabbatch{mbi}.spm.stats.fmri_spec.mthresh          = -inf;
    else
        matlabbatch{mbi}.spm.stats.fmri_spec.mask             = cellstr('');
        matlabbatch{mbi}.spm.stats.fmri_spec.mthresh          = .8;
    end
    
    for sess = 1:n_sess % Session loop
        s_dir    = [base_dir name filesep epi_folders{sess}];
        
        % Collect epis
        matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).scans = cellstr(epi_files{sess});
        matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).multi = {''};
        
        
        % Collect RES and create conditions
        RES = sub_res{sess};
        for conds = 1:numel(conditions)
            matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).cond(conds).name     = RES{conds}.name;
            matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).cond(conds).onset    = (RES{conds}.onset ./ TR) - 1;
            matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).cond(conds).duration = 0;
        end
        
        % Collect movement parameters        
        realign_file = fullfile(s_dir, realign_str);
        if exist(realign_file, 'file'); fprintf('movement parameters found\n\n');
        else; warning('no movement file\n\n'); end
        
        matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).multi_reg = {realign_file};
        matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).hpf = 360;                

    end % session loop
    
    % Specify destination directory
    mkdir(a_dir);
    copyfile(which(mfilename),a_dir);
    matlabbatch{mbi}.spm.stats.fmri_spec.dir = {[a_dir]};
    mbi = mbi + 1;
    
    estimationbatch{ebi}.spm.stats.fmri_est.spmmat           = {[a_dir filesep 'SPM.mat']};
    estimationbatch{ebi}.spm.stats.fmri_est.method.Classical = 1;
    ebi = ebi +1;
end % subject loop

% Run batches
parallel = 0;
if parallel
    if do_specify; run_spm_parallel(matlabbatch, n_proc); end
    if do_estimate; run_spm_parallel(estimationbatch, n_proc); end
else
    spm_jobman('run', matlabbatch);
    spm_jobman('run', estimationbatch);
end


%_______________________________________________________________
% Subfunctions
function out = ins_letter(pscan,letter)
for a=1:size(pscan,1)
    [p , f, e] = fileparts(pscan(a,:));
    out(a,:) = [p filesep letter f e];
end