function firstlevel_canonical_pmod
% specify firstlevel pmod with parametrically modulated stick functions

hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 4;
        cd /home/hipp/projects/WavePain/code/matlab/fmri/03_firstlevel/firstlevel_canonical_pmod/logs
    otherwise
        error('Only hosts noahs isn laptop accepted');
end

% Subs
all_subs = [5:12 14:53];
%all_subs = 10;

% Settings
do_model            = 0;
do_cons             = 1;
TR                  = 1.599;
heat_duration       = 110; % seconds. this is verified in C:\Users\hipp\projects\WavePain\code\matlab\fmri\fsubject\onsets.mat
skern               = 6; % smoothing kernel
stick_resolution    = 1; % /seconds so many sticks we want for now
anadirname          = 'canonical_pmod';

% Each subject has two sessions. Sessions are also used to distinquish
% subjects --> conceputal distance between eg sub10 sess1 - sub10sess2 =
% conceptual distance sub10sess1 - sub53sess2. Each session is a seperate
% matlabbatch and evaluated seperately by matlabbatch

% Specify paths and files
struc_templ         = '^sPRISMA.*\.nii';
epi_folders         = {'run001/mrt/', 'run002/mrt/'};
realign_str         =  '^rp_afMR.*\.txt';
srfunc_file         = '^srafMRI.nii';
conditions          = {'M21', 'M12', 'W21', 'W12', 'M_Online', 'W_Online'};
pmod_names          = {'heat', 'wm', 'slope',...
    'heat_X_wm', 'heat_X_slope','wm_X_slope',...
    'heat_X_wm_X_slope'}; % regressor
mat_name          = which(mfilename);

n_sess            = size(epi_folders,2);
n_cond            = size(conditions,2);

% Load onset file
onset_file = fullfile(base_dir, 'all_onsets.mat');
load(onset_file, 'all_RES');

% Prepare multiprocessing
if size(all_subs) < n_proc
    n_proc = size(all_subs,2);
end
subs              = splitvect(all_subs, n_proc);

for np = 1:size(subs,2) % core loop start
    matlabbatch = [];
    mbi = 0;
    
    
    for i = 1:size(subs{np},2) % subject loop start
        
        % Housekeeping
        name            = sprintf('sub%03d',subs{np}(i));
        st_dir          = fullfile(base_dir, name,'run000/mrt/');
        sub_res         = all_RES.(name); % condition onsets
        struc_file      = spm_select('FPList', st_dir, struc_templ);
        u_rc1_file      = ins_letter(struc_file,'u_rc1');
        
        a_dir = fullfile(base_dir, name, anadirname);
        if ~exist(a_dir, 'dir')
            mkdir(a_dir)
        end
        
        % First level model generics
        template = [];
        template.spm.stats.fmri_spec.timing.units   = 'scans';
        template.spm.stats.fmri_spec.timing.RT      = TR;
        template.spm.stats.fmri_spec.timing.fmri_t  = 16;
        template.spm.stats.fmri_spec.timing.fmri_t0 = 8;
        template.spm.stats.fmri_spec.fact           = struct('name', {}, 'levels', {});
        
        template.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];        
        template.spm.stats.fmri_spec.volt             = 1;
        template.spm.stats.fmri_spec.mthresh          = -Inf;
        template.spm.stats.fmri_spec.global           = 'None';
        template.spm.stats.fmri_spec.mask             = cellstr([st_dir 's3skull_strip.nii']);
        template.spm.stats.fmri_spec.cvi              = 'None';
        
        for j = 1:n_sess % session loop start
            
            s_dir           = fullfile(base_dir, name, epi_folders{j});
            epi_files       = spm_select('ExtFPList', s_dir, srfunc_file);
            fm              = spm_select('FPList', s_dir, realign_str);
            movement        = normalize(load(fm));
            all_nuis{j}     = movement;
            n_nuis          = size(all_nuis{j},2);
            
            template.spm.stats.fmri_spec.sess(j).hpf = 360;
            template.spm.stats.fmri_spec.sess(j).scans = cellstr(epi_files);
            template.spm.stats.fmri_spec.sess(j).multi = {''};
            template.spm.stats.fmri_spec.sess(j).multi_reg = {''};
            
            % Collect onsets and create conditions
            RES = sub_res{j};
            
            for conds = 1:numel(conditions) % condition loop start
                onset       = RES{conds}.onset; % seconds  
                cond_name   = RES{conds}.name;
                [onsets, pmods] = wave_getpmods(onset, cond_name, stick_resolution); % onset and onsets still in seconds
                template.spm.stats.fmri_spec.sess(j).cond(conds).name     = cond_name;
                template.spm.stats.fmri_spec.sess(j).cond(conds).onset    = (onsets ./ TR) -1;
                template.spm.stats.fmri_spec.sess(j).cond(conds).duration = 0;
                template.spm.stats.fmri_spec.sess(j).cond(conds).orth = 1;
                template.spm.stats.fmri_spec.sess(j).cond(conds).tmod = 0;
                
                for pmod = 1:numel(pmod_names) % parametric modulator loop start
                    template.spm.stats.fmri_spec.sess(j).cond(conds).pmod(pmod).name = pmod_names{pmod};
                    template.spm.stats.fmri_spec.sess(j).cond(conds).pmod(pmod).param = pmods(:,pmod);
                    template.spm.stats.fmri_spec.sess(j).cond(conds).pmod(pmod).poly = 1;
                end % parametric modulator loop end
            end % condition loop end
            
            
            % Movement parameters black box
            movement        = normalize(load(fm));
            all_nuis{j}     = movement;
            n_nuis          = size(all_nuis{j},2);
            for nuis = 1:n_nuis % movement parameters loop start
                template.spm.stats.fmri_spec.sess(j).regress(nuis) = struct('name', cellstr(num2str(nuis)), 'val', all_nuis{j}(:,nuis));
            end % movement parameter loop end            
        end % session loop end        
        
        if do_model
            mbi = mbi + 1;
            matlabbatch{mbi} = template;                        
            copyfile(which(mfilename),a_dir);
            matlabbatch{mbi}.spm.stats.fmri_spec.dir = {a_dir};
            
            mbi = mbi + 1;
            matlabbatch{mbi}.spm.stats.fmri_est.spmmat           = {[a_dir filesep 'SPM.mat']};
            matlabbatch{mbi}.spm.stats.fmri_est.method.Classical = 1;
        end
        
        % Prepare con template              
        template                        = [];
        % only do this once
        if ~exist(contrasts, 'var')
            contrasts       = [];
            con_names       = [pmod_names, strcat('-', pmod_names)];           
            contrasts(1,:)  = repmat([repmat([0 1 0 0 0 0 0 0],1,n_cond), zeros(1,6)],1,n_sess); % heat
            contrasts(2,:)  = repmat([repmat([0 0 1 0 0 0 0 0],1,n_cond), zeros(1,6)],1,n_sess); % wm
            contrasts(3,:)  = repmat([repmat([0 0 0 1 0 0 0 0],1,n_cond), zeros(1,6)],1,n_sess); % slope
            contrasts(4,:)  = repmat([repmat([0 0 0 0 1 0 0 0],1,n_cond), zeros(1,6)],1,n_sess); % heat_X_wm
            contrasts(5,:)  = repmat([repmat([0 0 0 0 0 1 0 0],1,n_cond), zeros(1,6)],1,n_sess); % heat_X_slope
            contrasts(6,:)  = repmat([repmat([0 0 0 0 0 0 1 0],1,n_cond), zeros(1,6)],1,n_sess); % wm_X_slope
            contrasts(7,:)  = repmat([repmat([0 0 0 0 0 0 0 1],1,n_cond), zeros(1,6)],1,n_sess); % heat_X_wm_X_slope
            
            % set not estimatable regressors to 0 (background: wm,
            % heat_X_wm, wm_X_slope and heat_X_wm_X_slope are all 0 for
            % conditions 5 and 6)
            contrasts([2 4 6 7], [34 36 38 39    88 90 92 93]) = 0;            
        end        
        
        template.spm.stats.con.spmmat   = {[a_dir filesep 'SPM.mat']};
        template.spm.stats.con.delete   = 1;        
        for k = 1:numel(con_names) % contrast loop start
                template.spm.stats.con.consess{k}.tcon.name     = con_names{k};
                template.spm.stats.con.consess{k}.tcon.name     = contrasts(k,:);
                template.spm.stats.con.consess{k}.tcon.sessrep  = 'none';
        end % contrast loop end                
        
        % Pass con template to batch
        if do_cons
            mbi = mbi + 1;
            matlabbatch{mbi} = template; 
        end                
    end % subject loop end
    
    % hand over batch to core
    if ~isempty(matlabbatch)
        check = 0;
        run_matlab(np, matlabbatch, check);
    end    
end % core loop end

%==========================================================================
% FUNCTION chuckCell = splitvect(v, n)
%==========================================================================
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

%==========================================================================
% FUNCTION out = ins_letter(pscan,letter)
%==========================================================================
function out = ins_letter(pscan,letter)
for a=1:size(pscan,1)
    [p , f, e] = fileparts(pscan(a,:));
    out(a,:) = [p filesep letter f e];
end

%==========================================================================
% FUNCTION out = chng_path(pscan,pa)
%==========================================================================
function out = chng_path(pscan,pa)
for a=1:size(pscan,1)
    [p , f, e] = fileparts(pscan(a,:));
    out(a,:) = [pa filesep f e];
end

%==========================================================================
% FUNCTION run_matlab(np, matlabbatch, check)
%==========================================================================
function run_matlab(np, matlabbatch, check)

spm_path          = fileparts(which('spm')); %get spm path
mat_name          = which(mfilename);
[~,mat_name,~]    = fileparts(mat_name);


fname = [mat_name '_'  num2str(np) '.mat'];

save(fname,'matlabbatch');
lo_cmd  = ['clear matlabbatch;load(''' fname ''');'];
ex_cmd  = ['addpath(''' spm_path ''');spm(''defaults'',''FMRI'');spm_jobman(''initcfg'');spm_jobman(''run'',matlabbatch);'];
end_cmd = ['delete(''' fname ''');'];

% Because matlab from bash can only execute one statement upon startup we
% have to detour via a function
if isunix    
    str                 = strcat(lo_cmd, ex_cmd, end_cmd, 'exit');
    [~, name_stem]      = fileparts(fname); 
    function_name       = strcat(name_stem, '.m');  
    log_name            = strcat(name_stem, '.log');
    fh                  = fopen(function_name, 'w');
                      fprintf(fh, 'function %s\n', name_stem); % write header                        
    nbytes              = fprintf(fh, '%s', str); % write commands
    if ~nbytes
        warning('Nothing written to %s', function_name)
    else
        fprintf('\n%d bytes written to %s \n', function_name);
    end
    fclose(fh);
    cmd = sprintf('matlab -nodesktop -nosplash  -logfile %s -r "%s" &', log_name, name_stem); 
end

if ispc
    cmd = ['start matlab.exe -nodesktop -nosplash  -logfile ' num2str(np) '_' mat_name '.log -r "' lo_cmd ex_cmd ';exit"'];
end

if ~check    
    system(cmd);
end
