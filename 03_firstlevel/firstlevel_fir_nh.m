function firstlevel_nh

hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
       otherwise
        error('Only hosts noahs isn laptop accepted');
end



all_subs = [10 12 14 16 17];

TR = 1.599;

ana_dirname     = 'quick_firstlevel';

struc_templ       = '^sPRISMA.*\.nii';

func_file       = '^srafMRI.nii';
realign_str     =  '^rp_afMR.*\.txt';

epi_folders     = {'run001\mrt\', 'run002\mrt\'};
conditions      = {'M21', 'M12', 'W21', 'W12', 'M_Online', 'W_Online'};

n_sess          = size(epi_folders,2);
n_cond          = size(conditions,2);

spm_path          = fileparts(which('spm')); %get spm path
mat_name          = which(mfilename);
[~,mat_name,~]    = fileparts(mat_name);

% Prepare multiprocessing
if size(all_subs) < n_proc
    n_proc = size(all_subs,2);
end 
subs              = splitvect(all_subs, n_proc);
 
for np = 1:size(subs,2) % multiprocessing loop    
    matlabbatch = [];
    mbi = 1;
    
    for i = 1:size(subs{np},2)
        S = fsubject(subs{np}(i),1); % Instantiate subject object
        
        % --------------------------------
        %House keeping stuff        
        name = sprintf('sub%03d',subs{np}(i));
        fprintf(['Doing volunteer ' name '\n']);
        
        % Collect T1
        st_dir       = fullfile(base_dir, name,'run000\mrt\');
        struc_file   = spm_select('FPList', st_dir, struc_templ);      
        
        % Collect epis
        for j=1:n_sess
            epi_files{j} = spm_select('ExtFPList', fullfile(base_dir, name, epi_folders{j}), func_file,inf);
        end
        
        % Some struc file (?)
        u_rc1_file   = ins_letter(struc_file,'u_rc1');
        
        % Analysis directory
        a_dir    = [base_dir name filesep strcat(ana_dirname,name)];
        
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
        matlabbatch{mbi}.spm.stats.fmri_spec.mthresh          = .8;
        matlabbatch{mbi}.spm.stats.fmri_spec.global           = 'None';
        
        % Collect mask
        matlabbatch{mbi}.spm.stats.fmri_spec.cvi              = 'Fast';
        matlabbatch{mbi}.spm.stats.fmri_spec.mask             = cellstr('');
        
        for sess = 1:n_sess % Session loop
            s_dir    = [base_dir name filesep epi_folders{sess}];                       
            
            % Collect epis
            matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).scans = cellstr(epi_files{sess});
            matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).multi = {''};
            
            % Collect RES and create conditions
            RES = S.RES{sess};
            for conds = 1:numel(conditions)
                matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).cond(conds).name     = RES{conds}.name;
                matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).cond(conds).onset    = (RES{conds}.onset ./ TR) - 1;
                matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).cond(conds).duration = 0;
            end
            
            matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).multi_reg = {''};
            matlabbatch{mbi}.spm.stats.fmri_spec.sess(sess).hpf = 360;            
        end % session loop 
        
        % Specify destination directory
        mkdir(a_dir);
        copyfile(which(mfilename),a_dir);
        matlabbatch{mbi}.spm.stats.fmri_spec.dir = {[a_dir]};        
        mbi = mbi + 1;
        
        matlabbatch{mbi}.spm.stats.fmri_est.spmmat           = {[a_dir filesep 'SPM.mat']};
        matlabbatch{mbi}.spm.stats.fmri_est.method.Classical = 1;
        mbi = mbi +1;        
    end % subject loop
    
    % Run batches
    save([num2str(np) '_' mat_name],'matlabbatch');
    lo_cmd = ['clear matlabbatch;load(''' num2str(np) '_' mat_name ''');'];
    ex_cmd = ['addpath(''' spm_path ''');spm(''defaults'',''FMRI'');spm_jobman(''initcfg'');spm_jobman(''run'',matlabbatch);exit'];
    system(['start matlab.exe -nodesktop -nosplash  -logfile ' num2str(np) '_' mat_name '.log -r "' lo_cmd ex_cmd ';exit"']);
    
end % multiprocessing loop

%_______________________________________________________________
% Subfunctions
function chuckCell = splitvect(v, n)
% Splits a vector into number of n chunks of  the same size (if possible).
% In not possible the chunks are almost of equal size.
%
% based on http://code.activestate.com/recipes/425044/

chuckCell = {};

vectLength = numel(v);


splitsize = 1/n*vectLength;

for i = 1:n
    %newVector(end + 1) =
    idxs = [floor(round((i-1)*splitsize)):floor(round((i)*splitsize))-1]+1;
    chuckCell{end + 1} = v(idxs);
end

function out = ins_letter(pscan,letter)
for a=1:size(pscan,1)
    [p , f, e] = fileparts(pscan(a,:));
    out(a,:) = [p filesep letter f e];
end