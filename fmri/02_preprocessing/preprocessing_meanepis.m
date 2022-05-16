function preprocessing_meanepis

% Take care of hosts
hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 4;
    otherwise
        error('Only hosts noahs isn laptop or revelations accepted');
end

% Settings
all_subs    = [5:12 14:53];
TR          = 1.599;

do_seg         = 0;
do_norm        = 0;
do_skull       = 0;
do_warp_skull  = 0;
do_back        = 0;
do_avg_norm    = 1;

mean_func_templ     = 'meanafMRI.nii'; % raw mean epi
mean_func_dir       = 'run001/mrt/'; % where to collect mean_epi
skullstrip_name     = 'skull_strip.nii';
dup_mean            = 'mean_epi';
struct_dir          = 'run000/mrt/'; % where to write it to

% Collect spm path
spm_path = fileparts(which('spm')); %get spm path
template_path = [spm_path filesep 'toolbox/cat12/templates_1.50mm' filesep]; % get newest toolbox
tpm_path = [spm_path filesep 'tpm' filesep];
if strcmp(hostname, 'revelations')
    tpm_path = '/projects/crunchie/hipp/wavepain/tpm/';
end



%%prepare for multiprocessing
subs    = splitvect(all_subs, n_proc);
%-------------------------------
% Create duplicate of meanfMRI.nii
if do_seg
    for g = 1:size(all_subs,2)
        name           = sprintf('sub%03d',all_subs(g));
        mkdir(fullfile(base_dir, name, struct_dir, dup_mean)); % put all the epis in seperate folder in struct dir
        copyfile(fullfile(base_dir, name, mean_func_dir, mean_func_templ),... % mean epi in old folder
            fullfile(base_dir, name, struct_dir, dup_mean)); % mean epi in new folder
    end
end

%-------------------------------
%Do mean EPI Segmentation
for np = 1:size(subs,2)
    
    matlabbatch = [];
    mbi = 0;
    for g = 1:size(subs{np},2)
        name            = sprintf('sub%03d',subs{np}(g));
        st_dir          = fullfile(base_dir, name, struct_dir, dup_mean);
        struc_file      = fullfile(st_dir, mean_func_templ);
        c1_file         = ins_letter(struc_file,'c1');
        c2_file         = ins_letter(struc_file,'c2');
        c3_file         = ins_letter(struc_file,'c3');
        rc1_file        = ins_letter(struc_file,'rc1');
        rc2_file        = ins_letter(struc_file,'rc2');
        u_rc1_file      = ins_letter(struc_file,'u_rc1');        
        strip_file      = fullfile(st_dir, skullstrip_name);
        
        if do_seg
            mbi = mbi + 1;
            matlabbatch{mbi}.spm.spatial.preproc.channel.vols     = cellstr(struc_file);
            matlabbatch{mbi}.spm.spatial.preproc.channel.biasreg  = 0.001;
            matlabbatch{mbi}.spm.spatial.preproc.channel.biasfwhm = 60;
            matlabbatch{mbi}.spm.spatial.preproc.channel.write    = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(1).tpm    = {[tpm_path 'enhanced_TPM.nii,1']};
            matlabbatch{mbi}.spm.spatial.preproc.tissue(1).ngaus  = 1;
            matlabbatch{mbi}.spm.spatial.preproc.tissue(1).native = [1 1];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(1).warped = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(2).tpm    = {[tpm_path 'enhanced_TPM.nii,2']};
            matlabbatch{mbi}.spm.spatial.preproc.tissue(2).ngaus  = 1;
            matlabbatch{mbi}.spm.spatial.preproc.tissue(2).native = [1 1];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(2).warped = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(3).tpm    = {[tpm_path 'enhanced_TPM.nii,3']};
            matlabbatch{mbi}.spm.spatial.preproc.tissue(3).ngaus  = 2;
            matlabbatch{mbi}.spm.spatial.preproc.tissue(3).native = [1 1];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(3).warped = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(4).tpm    = {[tpm_path 'enhanced_TPM.nii,4']};
            matlabbatch{mbi}.spm.spatial.preproc.tissue(4).ngaus  = 3;
            matlabbatch{mbi}.spm.spatial.preproc.tissue(4).native = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(4).warped = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(5).tpm    = {[tpm_path 'enhanced_TPM.nii,5']};
            matlabbatch{mbi}.spm.spatial.preproc.tissue(5).ngaus  = 4;
            matlabbatch{mbi}.spm.spatial.preproc.tissue(5).native = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(5).warped = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(6).tpm    = {[tpm_path 'enhanced_TPM.nii,6']};
            matlabbatch{mbi}.spm.spatial.preproc.tissue(6).ngaus  = 2;
            matlabbatch{mbi}.spm.spatial.preproc.tissue(6).native = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.tissue(6).warped = [0 0];
            matlabbatch{mbi}.spm.spatial.preproc.warp.mrf         = 1;
            matlabbatch{mbi}.spm.spatial.preproc.warp.cleanup     = 1;
            matlabbatch{mbi}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
            matlabbatch{mbi}.spm.spatial.preproc.warp.affreg      = 'mni';
            matlabbatch{mbi}.spm.spatial.preproc.warp.fwhm        = 0;
            matlabbatch{mbi}.spm.spatial.preproc.warp.samp        = 3;
            matlabbatch{mbi}.spm.spatial.preproc.warp.write       = [1 1];
        end
        
        %-------------------------------
        %Do skull strip
        if do_skull
            mbi = mbi + 1;
            Vfnames      = char(struc_file,c1_file,c2_file,c3_file);
            matlabbatch{mbi}.spm.util.imcalc.input            = cellstr(Vfnames);
            matlabbatch{mbi}.spm.util.imcalc.output           = skullstrip_name;
            matlabbatch{mbi}.spm.util.imcalc.outdir           = {st_dir};
            matlabbatch{mbi}.spm.util.imcalc.expression       = 'i1.*((i2+i3+i4)>0.2)';
            matlabbatch{mbi}.spm.util.imcalc.options.dmtx     = 0;
            matlabbatch{mbi}.spm.util.imcalc.options.mask     = 0;
            matlabbatch{mbi}.spm.util.imcalc.options.interp   = 1;
            matlabbatch{mbi}.spm.util.imcalc.options.dtype    = 4;
            
            mbi = mbi + 1;
            skern = 3;
            matlabbatch{mbi}.spm.spatial.smooth.data   = cellstr(strip_file);
            matlabbatch{mbi}.spm.spatial.smooth.fwhm   = repmat(skern,1,3);
            matlabbatch{mbi}.spm.spatial.smooth.prefix = ['s' num2str(skern)];            
        end
        
        %
        %-------------------------------
        %Dartel norm to template
        if do_norm
            mbi         = mbi + 1;            
            
            
            matlabbatch{mbi}.spm.tools.dartel.warp1.images = {cellstr(rc1_file),cellstr(rc2_file)};
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.rform = 0;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(1).its = 3;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(1).K = 0;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(1).template = {[template_path 'Template_1_IXI555_MNI152.nii']};
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(2).its = 3;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(2).K = 0;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(2).template = {[template_path 'Template_2_IXI555_MNI152.nii']};
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(3).its = 3;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(3).K = 1;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(3).template = {[template_path 'Template_3_IXI555_MNI152.nii']};
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(4).its = 3;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(4).K = 2;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(4).template = {[template_path 'Template_4_IXI555_MNI152.nii']};
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(5).its = 3;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(5).K = 4;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(5).template = {[template_path 'Template_5_IXI555_MNI152.nii']};
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(6).its = 3;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(6).K = 6;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.param(6).template = {[template_path 'Template_6_IXI555_MNI152.nii']};
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
            matlabbatch{mbi}.spm.tools.dartel.warp1.settings.optim.its = 3;
            
            
            %-------------------------------
            %Create warped mean EPI
            mbi = mbi + 1;                                      
            
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.flowfields = cellstr(u_rc1_file);
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.images = {cellstr(struc_file)};
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.jactransf = 0;
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.K = 6;
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.interp = 1;
        end
        if do_back
            mbi = mbi + 1;
            matlabbatch{mbi}.spm.util.defs.comp{1}.dartel.flowfield = {u_rc1_file};
            matlabbatch{mbi}.spm.util.defs.comp{1}.dartel.times     = [1 0];
            matlabbatch{mbi}.spm.util.defs.comp{1}.dartel.K         = 6;
            matlabbatch{mbi}.spm.util.defs.comp{1}.dartel.template  = {''};
            matlabbatch{mbi}.spm.util.defs.out{1}.savedef.ofname    = 'backwards';
            matlabbatch{mbi}.spm.util.defs.out{1}.savedef.savedir.saveusr = {st_dir};
        end
        
    if do_warp_skull
            mbi = mbi + 1;            
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.flowfields = cellstr(u_rc1_file);
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.images = {cellstr(strip_file)};
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.jactransf = 0;
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.K = 6;
            matlabbatch{mbi}.spm.tools.dartel.crt_warped.interp = 1;
            
    end    
        
    end
    
    if ~isempty(matlabbatch)
        check = 0;
        run_matlab(np, matlabbatch, check);
    end

end

if do_avg_norm
    matlabbatch = [];
    all_wskull_files = [];    
    
    
    % Collect all warped brains
    for g = 1:size(all_subs,2)
        name                = sprintf('sub%03d',all_subs(g));        
        st_dir              = fullfile(base_dir, name, struct_dir, dup_mean);       
        
        strip_file          = fullfile(st_dir, skullstrip_name);
        wskull_file         = ins_letter(strip_file,'w');               
        
        all_wskull_files    = char(all_wskull_files, wskull_file);
    end
    
    all_epi_dir         = fullfile(base_dir, 'all_meanepis');        
    cmd = sprintf('mkdir %s', all_epi_dir); system(cmd);    
    
    matlabbatch{1}.spm.util.imcalc.input            = cellstr(all_wskull_files);
    matlabbatch{1}.spm.util.imcalc.output           = 'meanepi_mean_wskull';  
    matlabbatch{1}.spm.util.imcalc.outdir           = cellstr(all_epi_dir);
    matlabbatch{1}.spm.util.imcalc.expression       = 'mean(X)';
    matlabbatch{1}.spm.util.imcalc.var              = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx     = 1;
    matlabbatch{1}.spm.util.imcalc.options.mask     = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp   = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype    = 4;
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end


end

function chuckCell = splitvect(v, n)
% Splits a vector into number of n chunks of  the same size (if possible).
% In not possible the chunks are almost of equal size.
%
% based on http://code.activestate.com/recipes/425044/
chuckCell = {};
vectLength = numel(v);
if n>vectLength
    n = vectLength;
end
splitsize = 1/n*vectLength;
for i = 1:n
    %newVector(end + 1) =
    idxs = [floor(round((i-1)*splitsize)):floor(round((i)*splitsize))-1]+1;
    chuckCell{end + 1} = v(idxs);
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


fname = [mat_name '_'  num2str(np) '.mat'];

save(fname,'matlabbatch');
lo_cmd  = ['clear matlabbatch;load(''' fname ''');'];
ex_cmd  = ['addpath(''' spm_path ''');spm(''defaults'',''FMRI'');spm_jobman(''initcfg'');spm_jobman(''run'',matlabbatch);'];
end_cmd = ['delete(''' fname ''');'];

% Because matlab from bash can only execute one statement upon startup we
% have to detour via a function
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

if ~check
    cmd = sprintf('matlab -nodesktop -nosplash  -logfile %s -r "%s" &', log_name, name_stem); 
    system(cmd);
end
end