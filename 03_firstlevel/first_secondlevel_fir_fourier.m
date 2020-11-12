function first_secondlevel_fir_fourier

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
%all_subs = [5:8];

fourier           = 0;%if 1 hanning windowed fourier, else FIR
mean_epi          = 0; % if 1 we use mean_epi to get to normalized space, else t1 coreg

do_model    = 0;
do_cons     = 0;
do_warp     = 0;
do_smooth   = 0;
do_anova    = 0;
do_anovacon = 1;

TR                = 1.599;

epi_folders         = {'run001/mrt/', 'run002/mrt/'};
shift             = 0; %no onset shift
skern             = 6;
skernel           = repmat(skern,1,3);

to_warp             = 'con_%04.4d.nii'; %files to warp
% to_warp           = 'beta_%04.4d.nii'; %files to warp

if fourier
    fourier_window    = 120;
    fourier_order     = 5;  %estimate precisely!!!
    basis_order       = 1+fourier_order*2;
    cond_use          = [1:(1+fourier_order*2)*numel(epi_folders)]; %order*2(sin/cos)+1(hanning window)
    anadirname        = ['fourier'];
    addon             = 'anova'; %for second level
else
    fir_window        = 120; % seconds
    %fir_res           = 4;  % seconds
    fir_res           = 2;  % seconds
    fir_order         = fir_window/fir_res;
    basis_order       = fir_order;
    cond_use          = [1:fir_order*numel(epi_folders)];
    %anadirname        = ['20bin_FIR_physio_zan_mov'];
    anadirname        = ['fir'];
    addon             = 'anova'; %for second level
end

% Specify paths and directories
out_dir             = [base_dir 'second_Level' filesep anadirname '_' addon '_' num2str(skern)];
if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end
struc_templ         = '^sPRISMA.*\.nii';

rfunc_file          = '^rafMRI.nii';
realign_str         =  '^rp_afMR.*\.txt';

epi_folders         = {'run001/mrt/', 'run002/mrt/'};
conditions          = {'M21', 'M12', 'W21', 'W12', 'M_Online', 'W_Online'};
anova_conditions    = {'M21', 'M12', 'W21', 'W12', 'M_Online', 'W_Online'};

% SPM and accessory files
spm_path          = fileparts(which('spm')); %get spm path
mat_name          = which(mfilename);
[~,mat_name,~]    = fileparts(mat_name);

onset_file = fullfile(base_dir, 'all_onsets.mat');
load(onset_file, 'all_RES');

n_sess            = size(epi_folders,2);
n_cond            = size(conditions,2);
dummies           = 0;

%prepare for multiprocessing
if size(all_subs) < n_proc
    n_proc = size(all_subs,2);
end
subs              = splitvect(all_subs, n_proc);

i_sub = 0;

for np = 1:size(subs,2)
    matlabbatch = [];
    mbi   = 0;
    
    for g = 1:size(subs{np},2)
        %-------------------------------
        %House keeping stuff
        i_sub           = i_sub + 1;
        name            = sprintf('sub%03d',subs{np}(g));
        st_dir          = fullfile(base_dir, name,'run000/mrt/');
        sub_res         = all_RES.(name); % condition onsets 
        struc_file      = spm_select('FPList', st_dir, struc_templ);
        u_rc1_file      = ins_letter(struc_file,'u_rc1');
        
        %reorder sessions here so that we have the same order cond
        %(CS+/CS-) and test (CS+/CS-)
        
        % not necessary
        %         s_order = block_UR(subjects_P==subs{np}(g));
        %         for l=1:n_sess      %l is session index for SPM, but s_order(l) is where we get our data from TAKE care!!!
        %             l_shuffle       = s_order(l);
        %             ind             = find((subjects_P==subs{np}(g)) & (block_P==l_shuffle));
        %             final_image     = image_count(ind);
        %             dummies         = dummy_count(ind);
        %             all_images      = 1:(final_image-dummies);
        %             epi_files{l}    = spm_select('ExtFPList', [base_dir filesep name filesep 'fmri\epi\' epi_folders{l_shuffle}], rfunc_file,all_images);
        %         end
        
        a_dir    = [base_dir name filesep anadirname];
        template = [];
        template.spm.stats.fmri_spec.timing.units   = 'scans';
        template.spm.stats.fmri_spec.timing.RT      = TR;
        template.spm.stats.fmri_spec.timing.fmri_t  = 16;
        template.spm.stats.fmri_spec.timing.fmri_t0 = 8;
        
        template.spm.stats.fmri_spec.fact           = struct('name', {}, 'levels', {});
        
        if fourier
            template.spm.stats.fmri_spec.bases.fourier.length = fourier_window;
            template.spm.stats.fmri_spec.bases.fourier.order  = fourier_order;
        else
            template.spm.stats.fmri_spec.bases.fir.length = fir_window;
            template.spm.stats.fmri_spec.bases.fir.order  = fir_order;
        end
        template.spm.stats.fmri_spec.volt             = 1;
        template.spm.stats.fmri_spec.mthresh          = -Inf;
        template.spm.stats.fmri_spec.global           = 'None';
        template.spm.stats.fmri_spec.mask             = cellstr([st_dir 's3skull_strip.nii']);
        template.spm.stats.fmri_spec.cvi              = 'None';
        
        for l = 1:n_sess
            %             l_shuffle = s_order(l);
            s_dir           =  [base_dir name filesep epi_folders{l}];
            epi_files{l}    = spm_select('ExtFPList', s_dir, rfunc_file);
            fm              = spm_select('FPList', s_dir, realign_str);
            movement        = normalize(load(fm));                        
            
            %movement = [];
            all_nuis{l} = [movement];            
            n_nuis         = size(all_nuis{l},2);
            
            %n_nuis         = 0;
            
            % Loop through as 2 sess!
            z{l}        = zeros(1,n_nuis); %handy for contrast def
            
            template.spm.stats.fmri_spec.sess(l).scans = cellstr(epi_files{l}); %epi files are already reordered
            %template.spm.stats.fmri_spec.sess(sess).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
            template.spm.stats.fmri_spec.sess(l).multi = {''};
            
            
            % Collect RES and create conditions
            RES = sub_res{l};
            for conds = 1:numel(conditions)
                template.spm.stats.fmri_spec.sess(l).cond(conds).name     = RES{conds}.name;
                template.spm.stats.fmri_spec.sess(l).cond(conds).onset    = (RES{conds}.onset ./ TR) - 1;
                template.spm.stats.fmri_spec.sess(l).cond(conds).duration = 0;
            end            
            
            template.spm.stats.fmri_spec.sess(l).multi_reg = {''};
            template.spm.stats.fmri_spec.sess(l).hpf = 360;
            for nuis = 1:n_nuis
                template.spm.stats.fmri_spec.sess(l).regress(nuis) = struct('name', cellstr(num2str(nuis)), 'val', all_nuis{l}(:,nuis));
            end
        end
        
        
        
        if do_model
            mbi = mbi + 1;
            matlabbatch{mbi} = template;
            mkdir(a_dir);
            copyfile(which(mfilename),a_dir);
            matlabbatch{mbi}.spm.stats.fmri_spec.dir = {a_dir};
            
            mbi = mbi + 1;
            matlabbatch{mbi}.spm.stats.fmri_est.spmmat           = {[a_dir filesep 'SPM.mat']};
            matlabbatch{mbi}.spm.stats.fmri_est.method.Classical = 1;
        end
        
        
        %%template for contrasts
        template = [];
        template.spm.stats.con.spmmat = {[a_dir filesep 'SPM.mat']};
        
        fco = 0;template.spm.stats.con.delete = 1;
%         fco = fco + 1; %counter for f-contrasts
%         template.spm.stats.con.consess{fco}.fcon.name   = 'eff_of_int';
%         
%         eoi_mat = [repmat([repmat([eye(basis_order)],1,n_cond) zeros(basis_order,n_nuis)],1,n_sess) zeros(basis_order,n_sess)];
%         eoi_vec = sum(eoi_mat);
%         eoi_ind = find(eoi_vec);
%         template.spm.stats.con.consess{fco}.fcon.convec = {eoi_mat};        
        co_i = 0;
        for co = 1:n_cond
            for i_fir = 1:basis_order
                tpl        = zeros(1,basis_order);
                tpl(i_fir) = 1;
                tpl        = [zeros(1,(co-1)*basis_order) tpl zeros(1,(n_cond-co)*basis_order)];
                convec = [];
                for i_sess = 1:n_sess
                    convec = [convec tpl z{i_sess}];
                end
                co_i = co_i + 1;
                template.spm.stats.con.consess{co_i+fco}.tcon.name    = [conditions{co} '_' num2str(i_fir)];
                template.spm.stats.con.consess{co_i+fco}.tcon.convec  = [convec zeros(1,size(epi_folders,2))];
                template.spm.stats.con.consess{co_i+fco}.tcon.sessrep = 'none';
            end            
        end
        
        
        if do_cons
            mbi = mbi + 1;
            matlabbatch{mbi} = template; %now add constrasts
        end
        
        
        % Prepare_warp
        
        % For mean_epi normalization change reference to log 
        
        template    = [];
        con_files   = '';
        
        all_warp = 1:(n_cond * basis_order);
        eoi_ind  = all_warp; % used a iterator for selecting cons for anova later
%         if all_warp(1) == 1
%             all_warp(1) = []; % kill the first one as it doesnt exist
%         end 
        
        for co = 1:numel(all_warp) %only those we need
            con_files(co,:) = [a_dir filesep sprintf(to_warp,all_warp(co))];
        end
        
        dartel_prefix       = 'w_t1';
        if mean_epi
            st_dir          = fullfile(st_dir, 'mean_epi');
            u_rcl_file      = fullfile(st_dir, 'u_rc1meanafMRI.nii');
            dartel_prefix   = 'w_epi';
        end
        
        
        wcon_files             = ins_letter(con_files,'w');
        wcon_dartel_files      = ins_letter(con_files, dartel_prefix); % or w_epi % same files as above but when moving later might as well specify normalization kind
        
        wcon_files             = chng_path(wcon_files, st_dir);    %wcon files still in t1 dir
        
        wcon_dartel_files      = chng_path(wcon_dartel_files, st_dir); %wcon files still in t1 dir
        wcon_dartel_files2     = chng_path(wcon_dartel_files, a_dir);  %wcon files still in ana dir
        
        
        template.spm.tools.dartel.crt_warped.flowfields = cellstr(repmat(u_rc1_file,size(con_files,1),1)); % either use u_rcl from t1 or from epis
        template.spm.tools.dartel.crt_warped.images = {cellstr(strvcat(con_files))};
        template.spm.tools.dartel.crt_warped.jactransf = 0;
        template.spm.tools.dartel.crt_warped.K = 6;
        template.spm.tools.dartel.crt_warped.interp = 1;
        
        
        if do_warp
            %T1 based dartel
            mbi = mbi + 1;
            matlabbatch{mbi} = template; %now add T1 dartel warp
            
            mbi = mbi + 1;
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.files = cellstr(wcon_files);
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.moveto = cellstr(a_dir);
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.pattern = 'w';
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.repl    = dartel_prefix;
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.unique         = false;
            
        end
        
        if do_smooth
            mbi = mbi + 1;
            matlabbatch{mbi}.spm.spatial.smooth.data = cellstr(wcon_dartel_files2);
            matlabbatch{mbi}.spm.spatial.smooth.fwhm = skernel;
            matlabbatch{mbi}.spm.spatial.smooth.prefix = ['s' num2str(skern)];
        end
        
        if do_anova
            all_files = [];assemb_cons = [];
            for co = 1:size(eoi_ind,2)
                if skern == 0
                    sw_templ      = sprintf('%s%0.4d.nii', dartel_prefix, eoi_ind(co));
                else
                    sw_templ      = sprintf('s%d%scon_%0.4d.nii', skern, dartel_prefix , eoi_ind(co));
                end
                all_files = strvcat(all_files,[base_dir name filesep anadirname filesep sw_templ]);
                %assemb_cons = [assemb_cons eoi_ind(co)];
                assemb_cons = [assemb_cons co];
            end
            anovabatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i_sub).scans = cellstr(all_files);
            anovabatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i_sub).conds = assemb_cons;
        end
    end
    if ~isempty(matlabbatch)
        check = 0;
        run_matlab(np, matlabbatch, check);
    end
end
if do_anova
    
    anovabatch{1}.spm.stats.factorial_design.dir = {out_dir};
    anovabatch{1}.spm.stats.factorial_design.des.anovaw.dept = 0;
    anovabatch{1}.spm.stats.factorial_design.des.anovaw.variance = 0;
    anovabatch{1}.spm.stats.factorial_design.des.anovaw.gmsca = 0;
    anovabatch{1}.spm.stats.factorial_design.des.anovaw.ancova = 0;
    anovabatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    anovabatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    anovabatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    anovabatch{1}.spm.stats.factorial_design.masking.im = 1;
    anovabatch{1}.spm.stats.factorial_design.masking.em = {[base_dir 'AND_mask.nii']};
    anovabatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    anovabatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    anovabatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    %% --------------------- MODEL ESTIMATION --------------------- %
    anovabatch{2}.spm.stats.fmri_est.spmmat = {fullfile(out_dir, 'SPM.mat')};
    anovabatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    %need to estimate first, than load SPM.mat to use FcUtil!!!
    
    %matlabbatch = anovabatch;
    %save('anovabatch','matlabbatch')
    
    run_matlab(1, anovabatch, 0);
    copyfile(which(mfilename),out_dir);
end

if do_anovacon
    anovabatch = [];
    
    sub_weights = repmat(1/numel(all_subs),1,numel(all_subs)) ;
    
    sub_const = [size(cond_use,2)+1:size(cond_use,2)+size(all_subs,2)]; % sub_const --> subject constante 
    clear SPM; load(fullfile(out_dir, 'SPM.mat')); %should exist by now
    anovabatch{1}.spm.stats.con.spmmat = {fullfile(out_dir, 'SPM.mat')};
    anovabatch{1}.spm.stats.con.delete = 1;
    
    co = 1;
%     anovabatch{1}.spm.stats.con.consess{co}.fcon.name   = 'eff_of_int';
%     Fc = spm_FcUtil('Set','F_iXO_Test','F','iX0',sub_const,SPM.xX.X);
%     anovabatch{1}.spm.stats.con.consess{co}.fcon.convec = {Fc.c'};
%     co = co + 1; %increment by 1
    
    
%     for con_i =1:size(anova_conditions,2)
%         anovabatch{1}.spm.stats.con.consess{co}.fcon.name   = anova_conditions{con_i};
%         all = 1:size(anova_conditions,2)*basis_order;
%         all((con_i-1)*basis_order+1:con_i*basis_order) = [];
%         Fc = spm_FcUtil('Set','F_iXO_Test','F','iX0',[all sub_const],SPM.xX.X);
%         anovabatch{1}.spm.stats.con.consess{co}.fcon.convec = {Fc.c'};
%         Fcc{con_i} = Fc.c';
%         co = co + 1; %increment by 1
%     end

for c = 1:size(anova_conditions,2)

    for f = 1:fir_order
        NBin = (c-1)*fir_order+f;

        anovabatch{1}.spm.stats.con.consess{co}.tcon.name       = [anova_conditions{c} '_' num2str(f)];
        anovabatch{1}.spm.stats.con.consess{co}.tcon.convec     = [zeros(1,NBin-1) 1 zeros(1,size(anova_conditions,2)*fir_order-NBin) sub_weights];
        anovabatch{1}.spm.stats.con.consess{co}.tcon.sessrep    = "none";
        co = co +1;
    end

end 

    
%     %diff_con = [1 2; 3 4];
%     diff_con = [2 1; 4 3; 3 1; 4 2];
%     
%     for con_i =1:size(diff_con,1)
%         anovabatch{1}.spm.stats.con.consess{co}.fcon.name   = [anova_conditions{diff_con(con_i,1)} '-' anova_conditions{diff_con(con_i,2)}];
%         anovabatch{1}.spm.stats.con.consess{co}.fcon.convec = round(Fcc{diff_con(con_i,1)} - Fcc{diff_con(con_i,2)}); %dirty hack with round()
%         co = co + 1; %increment by 1
%     end
%     
    
    spm_jobman('run', anovabatch);
%     run_matlab(1 ,anovabatch, 0);
end

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

function out = chng_path(pscan,pa)
for a=1:size(pscan,1)
    [p , f, e] = fileparts(pscan(a,:));
    out(a,:) = [pa filesep f e];
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










