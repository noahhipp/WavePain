function Second_Level_ANOVA

hostname = char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'mahapralaya'
        base_dir          = 'd:\offhum_cb\';
    case 'REM'
        base_dir          = 'c:\Users\buechel\Data\noah\';
    otherwise
        error('Only hosts REM and mahapralaya accepted');
end

%user specified variables
all_subs    = [10 12 14 16 17];


do_estimate = 1;
do_con      = 1;

anadirname        = ['fir'];


conditions        = {'M21','M12','W21','W12','M_Online','W_Online'};

fir_order         = 60;

cond_use          = [1:fir_order*size(conditions,2)]; 

skern             = 6;
addon             = 'anova';

out_dir           = [base_dir 'second_Level' filesep anadirname '_' addon num2str(skern)];

matlabbatch = []

for g = 1:size(all_subs,2)
    name   = sprintf('Sub%03.3d',all_subs(g));
    all_files = [];assemb_cons = [];
    for co = 1:size(cond_use,2)
        if skern == 0
            sw_templ      = sprintf('w_dartelcon_%0.4d.nii', cond_use(co));
        else
            sw_templ      = sprintf('s%dw_dartelcon_%0.4d.nii', skern, cond_use(co));
        end
        all_files = strvcat(all_files,[base_dir name filesep anadirname filesep sw_templ]);
        assemb_cons = [assemb_cons cond_use(co)];
    end
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(g).scans = cellstr(all_files);
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(g).conds = assemb_cons;
end

%% --------------------- MODEL SPECIFICATION --------------------- %%

matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};

matlabbatch{1}.spm.stats.factorial_design.des.anovaw.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {[base_dir 'mean_wskull.nii']};
%matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

%% --------------------- MODEL ESTIMATION --------------------- %%

matlabbatch{2}.spm.stats.fmri_est.spmmat = {[out_dir '\SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

if do_estimate
    %need to estimate first, than load SPM.mat to use FcUtil!!!
    spm_jobman('initcfg');
    spm('defaults', 'FMRI');
    spm_jobman('run',matlabbatch);
    copyfile(which(mfilename),out_dir);
end

% --------------------- CONTRASTS --------------------- %%
if do_con

    
    matlabbatch = []
    
    sub_const = [size(cond_use,2)+1:size(cond_use,2)+size(all_subs,2)];
    clear SPM; load([out_dir '\SPM.mat']); %should exist by now
    matlabbatch{1}.spm.stats.con.spmmat = {[out_dir '\SPM.mat']};
    matlabbatch{1}.spm.stats.con.delete = 1;
    
    co = 1;
    matlabbatch{1}.spm.stats.con.consess{co}.fcon.name   = 'eff_of_int';
    Fc = spm_FcUtil('Set','F_iXO_Test','F','iX0',sub_const,SPM.xX.X);
    matlabbatch{1}.spm.stats.con.consess{co}.fcon.convec = {Fc.c'};
    co = co + 1; %increment by 1
    
    
    for con_i =1:size(conditions,2)
        matlabbatch{1}.spm.stats.con.consess{co}.fcon.name   = conditions{con_i};
        all = 1:size(conditions,2)*fir_order;
        all((con_i-1)*fir_order+1:con_i*fir_order) = [];
        Fc = spm_FcUtil('Set','F_iXO_Test','F','iX0',[all sub_const],SPM.xX.X);
        matlabbatch{1}.spm.stats.con.consess{co}.fcon.convec = {Fc.c'};
        co = co + 1; %increment by 1
    end
    
    
    
    
    spm_jobman('run',matlabbatch);
end
