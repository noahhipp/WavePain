function Second_Level_anova_nosub

hostname = char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'mahapralaya'
        base_dir          = 'd:\equinox\';
        n_proc            = 4;
    case 'REM'
        base_dir          = '';
        n_proc            = 2;
    otherwise
        error('Only hosts REM and mahapralaya accepted');
end


cov_int   = 8; %covariates of interest
con       = [1 0 0 0   0 0 0 0 ;...
    0 1 0 0   0 0 0 0 ;...
    0 0 1 0   0 0 0 0 ;...
    0 0 0 1   0 0 0 0 ;...
    0 0 0 0   1 0 0 0 ;...
    0 0 0 0   0 1 0 0 ;...
    0 0 0 0   0 0 1 0 ;...
    0 0 0 0   0 0 0 1 ];

contrasts    = [con; -con];

con_names = {'Pain',...
    'Pain_int',...
    'Pain_modPE',...
    'Pain_intPE',...
    'Sound',...
    'Sound_int',...
    'Sound_modPE',...
    'Sound_intPE',...
    'Neg_Pain',...
    'Neg_Pain_int',...
    'Neg_Pain_modPE',...
    'Neg_Pain_intPE',...
    'Neg_Sound',...
    'Neg_Sound_int',...
    'Neg_Sound_modPE',...
    'Neg_Sound_intPE'}; % second level contrasts


anadirname        = ['emp_model_PE'];
all_subs  = [1 2 3 4 5 6 7 8 9 10 12 15 16 17 18 20 21 22 23 24 26 27 28 29 30 31 32 33 34 36 37 38 39 40 41];  %they have 2 EPI sessions 28 log files missing

n_type            = 'w_dartelcon';

skern             = 6;
cond_use          = [2:9]; % only use those cons


do_model    = 1;
do_estimate = 1;
do_contrast = 1;


matlabbatch = [];
all_scans   = [];

g = 1;
out_dir           = [base_dir 'Second_Level' filesep sprintf('ANOVA_model_%1.0d',skern)];

%% --------------------- MODEL SPECIFICATION --------------------- %%
if do_model
    matlabbatch{g}.spm.stats.factorial_design.dir = {out_dir};
    
    
    for co = 1:size(cond_use,2)
        all_files = [];
        for f = 1:size(all_subs,2)
            name              = sprintf('Sub%02.2d',all_subs(f));
            swcon_templ       = sprintf(['s%1.0d' n_type '_%0.4d.nii'], skern, cond_use(co));
            all_files = strvcat(all_files,[base_dir name filesep anadirname filesep swcon_templ]);
        end
        matlabbatch{g}.spm.stats.factorial_design.des.anova.icell(co).scans = cellstr(all_files)
    end
    
    matlabbatch{g}.spm.stats.factorial_design.des.anova.dept = 1;
    matlabbatch{g}.spm.stats.factorial_design.des.anova.variance = 1;
    matlabbatch{g}.spm.stats.factorial_design.des.anova.gmsca = 0;
    matlabbatch{g}.spm.stats.factorial_design.des.anova.ancova = 0;
    
    matlabbatch{g}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{g}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{g}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{g}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{g}.spm.stats.factorial_design.masking.em = {[base_dir 'mask.nii,1']};
    matlabbatch{g}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{g}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{g}.spm.stats.factorial_design.globalm.glonorm = 1;
    g = g + 1;
end
%% --------------------- MODEL ESTIMATION --------------------- %%
if do_estimate
    matlabbatch{g}.spm.stats.fmri_est.spmmat = {[out_dir '\SPM.mat']};
    matlabbatch{g}.spm.stats.fmri_est.method.Classical = 1;
    g = g + 1;
end

%% --------------------- CONTRAST ESTIMATION --------------------- %%
if do_contrast
    %load([out_dir '\SPM.mat']);
    co = 1;
    matlabbatch{g}.spm.stats.con.delete = 1;
    matlabbatch{g}.spm.stats.con.spmmat = cellstr([out_dir '\SPM.mat']);
    matlabbatch{g}.spm.stats.con.consess{co}.fcon.name   = 'eff_of_int';
    %Fc = spm_FcUtil('Set','F_iXO_Test','F','iX0',[size(cond_use,2)+1:size(cond_use,2)+size(all_subs,2)],SPM.xX.X);
    %matlabbatch{g}.spm.stats.con.consess{co}.fcon.convec = {Fc.c'};
    matlabbatch{g}.spm.stats.con.consess{co}.fcon.convec = eye(size(cond_use,2));
    co = co + 1; %increment by 1
    
    for ai = 1:size(con_names,2)
        matlabbatch{g}.spm.stats.con.consess{co}.tcon.name    = con_names{ai};
        matlabbatch{g}.spm.stats.con.consess{co}.tcon.convec  = contrasts(ai,:);
        matlabbatch{g}.spm.stats.con.consess{co}.tcon.sessrep = 'none';
        co = co + 1; %increment by 1
    end
    g = g + 1;
end



spm_jobman('initcfg');
spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);
copyfile(which(mfilename),out_dir);


