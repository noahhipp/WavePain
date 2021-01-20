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
    otherwise
        error('Only hosts noahs isn laptop accepted');
end

% Subs
all_subs = [5:12 14:53];

% Settings
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


% Prepare multiprocessing
if size(all_subs) < n_proc
    n_proc = size(all_subs,2);
end
subs              = splitvect(all_subs, n_proc);

for np = 1:size(subs,2) % core loop start
    matlabbatch = [];
    
    
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
        
        template.spm.stats.fmri_spec.volt             = 1;
        template.spm.stats.fmri_spec.mthresh          = -Inf;
        template.spm.stats.fmri_spec.global           = 'None';
        template.spm.stats.fmri_spec.mask             = cellstr([st_dir 's3skull_strip.nii']);
        template.spm.stats.fmri_spec.cvi              = 'None';
        
        for j = 1:ness % session loop start                       
            % <MUY IMPORTANTE por wavepain!!!!>
            template.spm.stats.fmri_spec.sess(l).hpf = 360;
            % </MUY IMPORTANTE por wavepain!!!!>
            
            s_dir           = fullfile(base_dir, name, epi_folders{j});                       
            epi_files       = spm_select('ExtFPList', s_dir, srfunc_file);
            fm              = spm_select('FPList', s_dir, realign_str);
            movement        = normalize(load(fm));                        
            all_nuis{j}     = movement;            
            n_nuis          = size(all_nuis{j},2);
            
            template.spm.stats.fmri_spec.sess(j).scans = cellstr(epi_files{j});
            template.spm.stats.fmri_spec.sess(j).multi = {''};
            template.spm.stats.fmri_spec.sess(j).multi_reg = {''};
            
            % Collect onsets and create conditions
            RES = sub_res{j};
            for conds = 1:numel(conditions) % condition loop start
                onset       = (RES{conds}.onset ./ TR) - 1;
                cond_name   = RES{conds}.name;
                [onsets, pmods] = wave_getpmod(onset, cond_name, stick_resolution);
                template.spm.stats.fmri_spec.sess(j).cond(conds).name     = RES{conds}.name;
                template.spm.stats.fmri_spec.sess(j).cond(conds).onset    = (RES{conds}.onset ./ TR) - 1;
                template.spm.stats.fmri_spec.sess(j).cond(conds).duration = 0;
                
                for pmod = 1:numel(pmod_names) % parametric modulator loop start
                    templatespm.stats.fmri_spec.sess.cond.tmod = 0;
                    matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod.name = 'wave';
                    matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod.poly = 1;

                    
                end % parametric modulator loop end
                template.spm.stats.fmri_spec.sess.cond.orth = 1;
            end % condition loop end            
            
            
            
            for nuis = 1:n_nuis
                template.spm.stats.fmri_spec.sess(j).regress(nuis) = struct('name', cellstr(num2str(nuis)), 'val', all_nuis{j}(:,nuis));
            end
            
        end % session loop end
        
        
    
    
    end % subject loop end
end % core loop end



















%==========================================================================
% FUNCTION varargout = spm_select_image(cmd, varargin)
%==========================================================================

