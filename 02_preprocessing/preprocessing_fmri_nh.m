
function preprocessing_fmri_nh
	% to safely use parallel computing we first fill task specific batches (e.g. 4d_batch, slice_timing_batch...) with all subjects and then
	% pass them to run_spm_parallel back to back

hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 7;
	
    otherwise
           
        error('Only hosts noahs isn laptop or revelations accepted');
end

check          = 0;

do_4d          = 0;
do_del         = 0;
do_field       = 0;%1
do_slicetime   = 1;%1
do_realign     = 1;
do_real_unwarp = 0;%1
do_coreg       = 1;%1
do_seg         = 1;%1
do_skull       = 1;%1
do_sm_skull    = 1;%1
do_norm        = 1;%1
do_back        = 1;%1
do_warp        = 1;%1
do_avg_norm    = 0;%1


all_subs = [17 21 24 31 39 46 53];
%DEBUG
%all_subs    = [19 25 35]; %they have only 1 EPI session


TR           = 1.599;

sfunc_templ       = '^fPRISMA.*\.nii';
struc_templ       = '^sPRISMA.*\.nii';

fm_magn_1_templ   = '^sPRISMA.*\-01.*\.nii';
fm_magn_2_templ   = '^sPRISMA.*\-02.*\.nii';

fm_phase_templ    = '^sPRISMA.*\-02.*\.nii';


func_name         = 'fMRI.nii';
a_func_name       = 'afMRI.nii';
ra_func_name      = 'rafMRI.nii';

mean_func_name    = 'meanafMRI.nii';

skullstrip_name   = 'skull_strip.nii';

epi_folders       = {'run001/mrt','run002/mrt'};
run_folders      = {'run001/mrt', 'run002/mrt'};
dummies           = 0; %already taken care of at import



% Collect spm path
spm_path = fileparts(which('spm')); %get spm path
template_path = [spm_path filesep 'toolbox/cat12/templates_1.50mm' filesep]; % get newest toolbox
tpm_path = [spm_path filesep 'tpm' filesep];
if strcmp(hostname, 'revelations')
    tpm_path = '/projects/crunchie/hipp/wavepain/tpm/';
end


% Initialize batch indices
fourd_i 	= 1;
del_i 		= 1;
field_i 	= 1;
slicetime_i	= 1;
realign_i 	= 1;
coreg_i		= 1;
seg_i 		= 1;
skull_i 	= 1;
sm_skull_i 	= 1;
norm_i		= 1;
back_i 		= 1;
warp_i 		= 1;
    
for g = 1:size(all_subs,2) 
	
        %-------------------------------
        %House keeping stuff        
        name = sprintf('sub%03d',all_subs(g));
        
        % Collect T1
        st_dir       = fullfile(base_dir, name,'run000/mrt/');
        struc_file   = spm_select('FPList', st_dir, struc_templ);      
        
        
        % Collect Field maps
        for i = 1:size(run_folders, 2)
            fm2_dir{i} = fullfile(base_dir, name, run_folders{i}, 'fm_2TE');
            fmd_dir{i} = fullfile(base_dir, name, run_folders{i}, 'fm_Diff');
            
            % get phase file
            phase_file{i}   = spm_select('FPList', fmd_dir{i}, struc_templ);
            
            % now get magnitude images
            magn_files     = spm_select('FPList', fm2_dir{i}, struc_templ);
            mag_info       = dis_fname(magn_files);
            mag_info_count = cat(2,mag_info.count);
            [small_mag,~]  = min(mag_info_count);
            [big_mag,~]    = max(mag_info_count);            
            magn_1_file{i}    = magn_files(small_mag,:);
            magn_2_file{i}    = magn_files(big_mag,:);
            
        end
        
        % Collect Epis
        for i=1:size(epi_folders,2)
            % already did 4D conversion and deleted 3D
            fourD   = fullfile(base_dir, name, epi_folders{i}, func_name);
            afourD  = fullfile(base_dir, name, epi_folders{i}, a_func_name);
            rafourD = fullfile(base_dir, name, epi_folders{i}, ra_func_name);
            
            epi_files{i} = spm_select('FPList', [base_dir filesep name filesep epi_folders{i}], sfunc_templ);
            
            if isempty(epi_files{i})
                if exist(fourD, 'file') 
                    epi_files{i} = cellstr(spm_select('expand',fourD));
                    fprintf('ra4D is here');
                elseif exist(afourD, 'file')
                    epi_files{i} = cellstr(spm_select('expand',afourD));
                elseif exist(rafourD, 'file')
                     epi_files{i} = cellstr(spm_select('expand',rafourD));
                end
            end
        end
        
        
        if check
            fprintf(['***Volunteer ' name '\n']);
            
            fprintf('Structural image: ');
            if isempty(struc_file)
                fprintf('missing\n')
            else
                fprintf('OK %d file(s)\n',size(struc_file,1))
            end
            
            fprintf('Phase image     : ');
            if isempty(phase_file)
                fprintf('missing\n')
            else
                fprintf('OK %d file(s)\n',size(phase_file,2))
            end
            
            fprintf('Magn image      : ');
            if isempty(magn_1_file)
                fprintf('missing\n')
            else
                fprintf('OK %d file(s)\n',size(magn_1_file,2))
            end
            
            fprintf('EPI images\n');
            for l=1:size(epi_folders,2)
                fprintf('S%d  : ',l);
                if isempty(epi_files{l})
                    fprintf('missing\n');
                else
                    fprintf('OK: %d volumes\n',size(epi_files{l},1));
                end
            end
            fprintf('\n')
            
          
            
        end
        
        if ~isempty(struc_file)
            m_dir        = [base_dir name filesep epi_folders{1}];
            mean_file    = [m_dir filesep mean_func_name];
            c1_file      = ins_letter(struc_file,'c1');
            c2_file      = ins_letter(struc_file,'c2');
            rc1_file     = ins_letter(struc_file,'rc1');
            rc2_file     = ins_letter(struc_file,'rc2');
            u_rc1_file   = ins_letter(struc_file,'u_rc1');
            strip_file   = fullfile(base_dir,name,'run000/mrt/',skullstrip_name);
        end
        if ~check
            fprintf(['Doing volunteer ' name '\n']);
        end
        %-------------------------------
        %Do 4D NIFTI conversion
        if do_4d
            for l=1:size(epi_folders,2)
                fourd_batch{fourd_i}.spm.util.cat.vols  = cellstr(epi_files{l}(dummies+1:end,:));
                fourd_batch{fourd_i}.spm.util.cat.name  = func_name;
                fourd_batch{fourd_i}.spm.util.cat.dtype = 0;
                fourd_batch{fourd_i}.spm.util.cat.RT    = TR; %???
                fourd_i = fourd_i + 1;                
                
                
            end
                    save('4D.mat','fourd_batch');

        end
        
        %-------------------------------
        % Get rid of 3D-niftis
        if do_del
            for l = 1:size(epi_folders,2)
                del_batch{del_i}.cfg_basicio.file_dir.file_ops.file_move.files = cellstr(epi_files{l});
                del_batch{del_i}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;
                del_i = del_i + 1;
            end
        end
        
        %-------------------------------
        %Do Fieldmap
        if do_field
            for j = 1:size(epi_folders,2)
                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = phase_file(j);

                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = magn_1_file(j);
                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsfile = fm_default_file(j);
                
                s_dir            = [base_dir name filesep epi_folders{j}];
                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.session.epi = create_func_files(s_dir,ra_func_name,1)';
                
                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.sessname = sprintf('session%d',j);
                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 1;
                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
                field_batch{field_i}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
                field_i = field_i + 1;
            end
        end
        
        
        %-------------------------------
        %Do Slice time correction
        if do_slicetime         
            for l=1:size(epi_files,2)                
                s_dir            = [base_dir name filesep epi_folders{l}];
                func_files{l}    = create_func_files(s_dir,func_name,size(epi_files{l},1))';
            end
            slicetime_batch{slicetime_i}.spm.temporal.st.scans = func_files;
            slicetime_batch{slicetime_i}.spm.temporal.st.nslices     = 66;
            slicetime_batch{slicetime_i}.spm.temporal.st.tr          = 1.599;
            slicetime_batch{slicetime_i}.spm.temporal.st.ta          = 0;
            slicetime_batch{slicetime_i}.spm.temporal.st.so          = repmat(linspace(1599 - 1599/(66/3),0,66/3),1,3);
            slicetime_batch{slicetime_i}.spm.temporal.st.refslice    = 800; 
            slicetime_batch{slicetime_i}.spm.temporal.st.prefix      = 'a';
            slicetime_i = slicetime_i + 1;
        end
       
        %-------------------------------
        %Do Realignment
        if do_realign
            
            for l=1:size(epi_files,2)
                s_dir            = [base_dir name filesep epi_folders{l}];
                func_files{l}    = create_func_files(s_dir,a_func_name,size(epi_files{l},1))';
            end
            
            realign_batch{realign_i}.spm.spatial.realign.estwrite.data             = func_files;
            realign_batch{realign_i}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
            realign_batch{realign_i}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
            realign_batch{realign_i}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
            realign_batch{realign_i}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
            realign_batch{realign_i}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
            realign_batch{realign_i}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
            realign_batch{realign_i}.spm.spatial.realign.estwrite.eoptions.weight  = '';
            realign_batch{realign_i}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
            realign_batch{realign_i}.spm.spatial.realign.estwrite.roptions.interp  = 4;
            realign_batch{realign_i}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
            realign_batch{realign_i}.spm.spatial.realign.estwrite.roptions.mask    = 1;
            realign_batch{realign_i}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';
            realign_i = realign_i + 1;
        end
        %save('realign.mat','skull_batch');
        
        %-------------------------------
        %Do Realignment and unwarp
        if do_real_unwarp
            for l=1:size(epi_folders,2)
                s_dir            = [base_dir name filesep epi_folders{l}];
                %skull_batch{seg_i}.spm.spatial.realignunwarp.data(l).scans =
                %create_func_files(s_dir,a_func_name,size(epi_files{l},1))';
                %use this for 1 session
                unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.data(l).pmscan = {ins_letter(phase_file,'vdm5_sc',['_session' num2str(l)])};
                unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.data(l).pmscan = {ins_letter(phase_file,'vdm5_sc')};
            end
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.eoptions.sep = 4;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.eoptions.rtm = 0;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.eoptions.einterp = 2;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.eoptions.weight = '';
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.jm = 0;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.sot = [];
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.rem = 1;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.noi = 5;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uweoptions.expround = 'First';
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uwroptions.mask = 1;
            unwarp_batch{unwarp_i}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
            unwarp_i = unwarp_i + 1;
            
        end
        %-------------------------------
        %Do Coreback_istration mean rfMRI to T1
        if do_coreg
            coreg_batch{coreg_i}.spm.spatial.coreg.estimate.source = cellstr(struc_file);
            coreg_batch{coreg_i}.spm.spatial.coreg.estimate.ref    = cellstr(mean_file);
            coreg_batch{coreg_i}.spm.spatial.coreg.estimate.other  = {''};
            coreg_batch{coreg_i}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            coreg_batch{coreg_i}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            coreg_batch{coreg_i}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            coreg_batch{coreg_i}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
            coreg_i = coreg_i + 1;
        end
        %-------------------------------
        %Do Segmentation
        if do_seg
            seg_batch{seg_i}.spm.spatial.preproc.channel.vols     = cellstr(struc_file);
            seg_batch{seg_i}.spm.spatial.preproc.channel.biasreg  = 0.001;
            seg_batch{seg_i}.spm.spatial.preproc.channel.biasfwhm = 60;
            seg_batch{seg_i}.spm.spatial.preproc.channel.write    = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(1).tpm    = {[tpm_path 'enhanced_TPM.nii,1']};
            seg_batch{seg_i}.spm.spatial.preproc.tissue(1).ngaus  = 2; %LOrio ... Draganski et al. NI2016
            seg_batch{seg_i}.spm.spatial.preproc.tissue(1).native = [1 1];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(1).warped = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(2).tpm    = {[tpm_path 'enhanced_TPM.nii,2']};
            seg_batch{seg_i}.spm.spatial.preproc.tissue(2).ngaus  = 1;
            seg_batch{seg_i}.spm.spatial.preproc.tissue(2).native = [1 1];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(2).warped = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(3).tpm    = {[tpm_path 'enhanced_TPM.nii,3']};
            seg_batch{seg_i}.spm.spatial.preproc.tissue(3).ngaus  = 2;
            seg_batch{seg_i}.spm.spatial.preproc.tissue(3).native = [1 1];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(3).warped = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(4).tpm    = {[tpm_path 'enhanced_TPM.nii,4']};
            seg_batch{seg_i}.spm.spatial.preproc.tissue(4).ngaus  = 3;
            seg_batch{seg_i}.spm.spatial.preproc.tissue(4).native = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(4).warped = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(5).tpm    = {[tpm_path 'enhanced_TPM.nii,5']};
            seg_batch{seg_i}.spm.spatial.preproc.tissue(5).ngaus  = 4;
            seg_batch{seg_i}.spm.spatial.preproc.tissue(5).native = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(5).warped = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(6).tpm    = {[tpm_path 'enhanced_TPM.nii,6']};
            seg_batch{seg_i}.spm.spatial.preproc.tissue(6).ngaus  = 2;
            seg_batch{seg_i}.spm.spatial.preproc.tissue(6).native = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.tissue(6).warped = [0 0];
            seg_batch{seg_i}.spm.spatial.preproc.warp.mrf         = 1;
            seg_batch{seg_i}.spm.spatial.preproc.warp.cleanup     = 1;
            seg_batch{seg_i}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
            seg_batch{seg_i}.spm.spatial.preproc.warp.affreg      = 'mni';
            seg_batch{seg_i}.spm.spatial.preproc.warp.fwhm        = 0;
            seg_batch{seg_i}.spm.spatial.preproc.warp.samp        = 3;
            seg_batch{seg_i}.spm.spatial.preproc.warp.write       = [0 0];
            seg_i = seg_i + 1;
        end
        
        %-------------------------------
        %Do skull strip
        if do_skull
            Vfnames      = strvcat(struc_file,c1_file,c2_file);
            skull_batch{skull_i}.spm.util.imcalc.input            = cellstr(Vfnames);
            skull_batch{skull_i}.spm.util.imcalc.output           = skullstrip_name;
            skull_batch{skull_i}.spm.util.imcalc.outdir           = {st_dir};
            skull_batch{skull_i}.spm.util.imcalc.expression       = 'i1.*((i2+i3)>0.2)';
            skull_batch{skull_i}.spm.util.imcalc.options.dmtx     = 0;
            skull_batch{skull_i}.spm.util.imcalc.options.mask     = 0;
            skull_batch{skull_i}.spm.util.imcalc.options.interp   = 1;
            skull_batch{skull_i}.spm.util.imcalc.options.dtype    = 4;
            skull_i = skull_i + 1;
        end
        %-------------------------------
        %Dartel norm to template
        if do_norm
            norm_batch{norm_i}.spm.tools.dartel.warp1.images = {cellstr(rc1_file),cellstr(rc2_file)};
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.rform = 0;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(1).its = 3;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(1).K = 0;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(1).template = {[template_path 'Template_1_IXI555_MNI152.nii']};
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(2).its = 3;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(2).K = 0;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(2).template = {[template_path 'Template_2_IXI555_MNI152.nii']};
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(3).its = 3;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(3).K = 1;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(3).template = {[template_path 'Template_3_IXI555_MNI152.nii']};
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(4).its = 3;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(4).K = 2;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(4).template = {[template_path 'Template_4_IXI555_MNI152.nii']};
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(5).its = 3;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(5).K = 4;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(5).template = {[template_path 'Template_5_IXI555_MNI152.nii']};
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(6).its = 3;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(6).K = 6;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.param(6).template = {[template_path 'Template_6_IXI555_MNI152.nii']};
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
            norm_batch{norm_i}.spm.tools.dartel.warp1.settings.optim.its = 3;
            norm_i = norm_i + 1;
        end
        %-------------------------------
        %Get backwards deformations
        if do_back
            back_batch{back_i}.spm.util.defs.comp{1}.dartel.flowfield = {u_rc1_file};
            back_batch{back_i}.spm.util.defs.comp{1}.dartel.times     = [1 0];
            back_batch{back_i}.spm.util.defs.comp{1}.dartel.K         = 6;
            back_batch{back_i}.spm.util.defs.comp{1}.dartel.template  = {''};
            back_batch{back_i}.spm.util.defs.out{1}.savedef.ofname    = 'backwards';
            back_batch{back_i}.spm.util.defs.out{1}.savedef.savedir.saveusr = {st_dir};
            back_i = back_i + 1;
        end
        
        %-------------------------------
        %Create warped T1 and mean EPI
        if do_warp
            warp_batch{warp_i}.spm.tools.dartel.crt_warped.flowfields = cellstr(strvcat(u_rc1_file,u_rc1_file,u_rc1_file,u_rc1_file));
            warp_batch{warp_i}.spm.tools.dartel.crt_warped.images = {cellstr(strvcat(mean_file,strip_file,c1_file,c2_file))};
            warp_batch{warp_i}.spm.tools.dartel.crt_warped.jactransf = 0;
            warp_batch{warp_i}.spm.tools.dartel.crt_warped.K = 6;
            warp_batch{warp_i}.spm.tools.dartel.crt_warped.interp = 1;
            warp_i = warp_i + 1;
        end
        %-------------------------------
        %Create smoothed skullstrip
        if do_sm_skull
            skern = 3;
            sm_skull_batch{sm_skull_i}.spm.spatial.smooth.data   = cellstr(strip_file);
            sm_skull_batch{sm_skull_i}.spm.spatial.smooth.fwhm   = repmat(skern,1,3);
            sm_skull_batch{sm_skull_i}.spm.spatial.smooth.prefix = ['s' num2str(skern)];
            sm_skull_i = sm_skull_i + 1;
        end
    end


% Start batches
if do_4d;run_spm_parallel(fourd_batch, n_proc); end
if do_del;run_spm_parallel(del_batch, n_proc);end
if do_slicetime; run_spm_parallel(slicetime_batch, n_proc); end
if do_realign; run_spm_parallel(realign_batch, n_proc); end
if do_coreg; run_spm_parallel(coreg_batch, n_proc); end
if do_seg; run_spm_parallel(seg_batch, n_proc); end
if do_skull; run_spm_parallel(skull_batch, n_proc); end
if do_sm_skull; run_spm_parallel(sm_skull_batch, n_proc); end
if do_norm; run_spm_parallel(norm_batch, n_proc); end
if do_back; run_spm_parallel(back_batch, n_proc); end
if do_warp; run_spm_parallel(warp_batch, n_proc); end


if do_avg_norm
    matlabbatch = [];
    all_wskull_files = [];
    all_wmean_files  = [];
    all_wc1_files    = [];
    
    for g = 1:size(all_subs,2)
        name = sprintf('sub%03d',all_subs(g));
        strip_file        = fullfile(base_dir, name,'run000/mrt/',skullstrip_name);
        wskull_file       = ins_letter(strip_file,'w');
        
        mean_file        = fullfile(base_dir, name, 'run000/mrt/', mean_func_name);
        wmean_file       = ins_letter(mean_file,'w');
        
        st_dir       = fullfile(base_dir, name, 'run000/mrt/');
        struc_file   = spm_select('FPList', st_dir, struc_templ);
        wc1_file     = ins_letter(struc_file,'wc1');
        
        all_wskull_files  = strvcat(all_wskull_files,wskull_file);
        all_wmean_files   = strvcat(all_wmean_files,wmean_file);
        all_wc1_files     = strvcat(all_wc1_files,wc1_file);
    end
    
    matlabbatch{1}.spm.util.imcalc.input = cellstr(all_wskull_files);
    matlabbatch{1}.spm.util.imcalc.output = 'mean_wskull';
    matlabbatch{1}.spm.util.imcalc.outdir = cellstr(base_dir);
    matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    
    matlabbatch{2} = matlabbatch{1};
    matlabbatch{2}.spm.util.imcalc.input = cellstr(all_wmean_files);
    matlabbatch{2}.spm.util.imcalc.output = 'mean_wmean';
    
    matlabbatch{3} = matlabbatch{1};
    matlabbatch{3}.spm.util.imcalc.input = cellstr(all_wc1_files);
    matlabbatch{3}.spm.util.imcalc.output = 'mean_wc1';
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end
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

end

function f_files = create_func_files(s_dir,f_templ,n_files)
for i=1:n_files
    f_files{i} = [s_dir filesep f_templ ',' num2str(i)];
end
end


function out = ins_letter(pscan,letter_start,letter_end)
if nargin <3
    letter_end = [];
end
for a=1:size(pscan,1)
    [p , f, e] = fileparts(pscan(a,:));
    out(a,:) = [p filesep letter_start f letter_end e];
end
end

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
end

function out = dis_fname(pfname)

for i = 1:size(pfname,1)
    [p, fname, ext] = fileparts(pfname(i,:));
    
    
    us = strfind(fname,'_');
    hy = strfind(fname,'-');
    
    out(i).path   = p;
    out(i).pre    = fname(1:us-1);
    out(i).sub    = str2num(fname(us+1:hy(1)-1));
    out(i).series = str2num(fname(hy(1)+1:hy(2)-1));
    out(i).ind1   = str2num(fname(hy(2)+1:hy(3)-1));
    out(i).ind2   = str2num(fname(hy(3)+1:hy(4)-1));
    out(i).count  = str2num(fname(hy(4)+1:end));
    out(i).ext    = ext;
end
end
