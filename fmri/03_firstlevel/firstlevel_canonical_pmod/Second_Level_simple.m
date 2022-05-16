function Second_Level_simple

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

anadirname        = ['emp_model_PE'];
subs  = [1 2 3 4 5 6 7 8 9 10 12 15 16 17 18 20 21 22 23 24 26 27 28 29 30 31 32 33 34 36 37 38 39 40 41];  %they have 2 EPI sessions 28 log files missing





n_type            = 'w_dartelcon';
%n_type            = 'w_epi_dartelcon';
%n_type            = 'w_epicon';
skern             = 6;
all_con           = [2:17];
addon             = ['_big_mask_' n_type];

for cons = 1:size(all_con,2)
    con_no = all_con(cons);
    out_dir           = [base_dir 'Second_Level' filesep anadirname '_' addon sprintf('s%1.0dcon%0.4d',skern,con_no)];
    go = 1; %
    
    matlabbatch = []
    all_scans   = [];
    %% --------------------- MODEL SPECIFICATION --------------------- %%
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};
    
    for g=1:size(subs,2)
        name        = sprintf('Sub%02.2d',subs(g));
        a_dir       = [base_dir filesep name filesep anadirname];
        
        swcon_templ = sprintf(['s%1.0d' n_type '_%0.4d.nii'], skern, con_no);
        swcon_file  = spm_select('FPList', a_dir, swcon_templ);
        
        all_scans = strvcat(all_scans, swcon_file);
    end

    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(all_scans);
    
    matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca  = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;

    
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    %matlabbatch{1}.spm.stats.factorial_design.masking.em = {[base_dir 'mask.nii,1']};
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {[base_dir 'all_meanepis/meanepi_mean_wskull.nii']};   
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    %% --------------------- MODEL ESTIMATION --------------------- %%
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {[out_dir '\SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    % --------------------- CONTRASTS --------------------- %%
    matlabbatch{3}.spm.stats.con.spmmat = {[out_dir '\SPM.mat']};
    matlabbatch{3}.spm.stats.con.delete = 1;
    
    co = 1;

    matlabbatch{3}.spm.stats.con.consess{co}.tcon.name    = 'pos';
    matlabbatch{3}.spm.stats.con.consess{co}.tcon.convec  = [1];
    matlabbatch{3}.spm.stats.con.consess{co}.tcon.sessrep = 'none';
    co = co + 1; %increment by 1
    
    matlabbatch{3}.spm.stats.con.consess{co}.tcon.name    = 'neg';
    matlabbatch{3}.spm.stats.con.consess{co}.tcon.convec  = [-1];
    matlabbatch{3}.spm.stats.con.consess{co}.tcon.sessrep = 'none';
    co = co + 1; %increment by 1
    
    spm_jobman('initcfg');
    spm('defaults', 'FMRI');
    spm_jobman('run',matlabbatch);
    copyfile(which(mfilename),out_dir);
end

