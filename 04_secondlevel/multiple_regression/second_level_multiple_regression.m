function second_level_multiple_regression

% Takes about 30min

hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 4;
    otherwise
        error('Only hosts revelations or noahs isn laptop accepted');
end

% Always run analysis from log directory
fallback = pwd;
cd('/home/hipp/projects/WavePain/code/matlab/fmri/04_secondlevel/multiple_regression/logs');



all_subs = [5:12 14:53];
shift    = 4; % shift contrats
do_debug = 0;
do_plot  = 0; % there are a few sanity plots throughout the script
do_model = 1;

skern = 6;
anadirname = 'mreg';
addon = 'anova';
old_ananame = 'fir'; % we need this to import files
file_filter = 's6w_t1con';
n_cons = nan(1,numel(all_subs));


out_dir             = [base_dir 'second_Level' filesep anadirname '_' addon '_'...
                       num2str(skern) '_shift' num2str(shift)];
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end


% Prepare images
con_images = {};
for i = 1:numel(all_subs)
    sname       = sprintf('sub%03d', all_subs(i)); fprintf('doing %s...\n', sname);    
    sdir        = fullfile(base_dir, sname, old_ananame);
    sfiles      = cellstr(spm_select('FPList',sdir,file_filter)); % use FPList for full path    
    
    n_cons(1,i)     = numel(sfiles); % to plot files per subject later 
    con_images      = vertcat(con_images, sfiles);
    
    % Debug
    if do_debug
        disp(sfiles); 
        prompt = 'Do you want more? y/n [y]: ';
        str = input(prompt,'s');
        if isempty(str)
            str = 'y';
        end

        if strcmp(str, 'n')
            fprintf('aborting\n\n');
            return
        elseif strcmp(str, 'y')
            fprintf('proceeding to next sub...\n\n');
        end                  
    end    
end

% Check if all have 360 cons
if do_plot
    figure();
    bar(all_subs, n_cons);
    title('CONS PER SUBJECT', 'FontWeight', 'bold', 'FontSize', 24);
    ylabel('Number of cons'); xlabel('Subject');
    ylim([0 400]); grid on;
end


% Prepare parametric regressors
parametric_contrasts = plot_parametric_contrasts(0); % arithmetic for parametric contrasts is done here
m = parametric_contrasts.m_unit;
w = parametric_contrasts.w_unit;
obtb = parametric_contrasts.obtb; 
tbob = parametric_contrasts.tbob; 
dsus = parametric_contrasts.dsus;
usds = parametric_contrasts.usds;

heat    = [m m w w m w];
wm      = [tbob obtb tbob obtb, zeros(1,120)]; % 2back->1, 1back->-1, noback->1
slope   = [dsus dsus usds usds, dsus, usds]; % down slope->-1, up slope->1 

cov_names = {'heat', 'wm', 'slope',...
                    'heat_X_wm', 'heat_X_slope','wm_X_slope',...
                    'heat_X_wm_slope'}; % regressor
                
covs = []; covi = 1;
covs(covi,:) = heat; covi=covi+1;
covs(covi,:) = wm; covi=covi+1;
covs(covi,:) = slope; covi=covi+1;
covs(covi,:) = heat.*wm; covi=covi+1;
covs(covi,:) = heat.*slope; covi=covi+1;
covs(covi,:) = wm.*slope; covi=covi+1;
covs(covi,:) = heat.*wm.*slope;                 

% Take care of shift
covs = circshift(covs, shift, 2);
cov_names = strcat(cov_names, sprintf('_shift%d', shift));

% plot each regressor *to be* before we repmat them
if do_plot
    for i = 1:numel(cov_names)
        figure;
        wave_tconplot(covs(i,:), cov_names{i});
    end
end
covs = repmat(covs', numel(all_subs), 1); % repmat 


% Assemble model
if do_model
    matlabbatch = [];
    matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = con_images;

    for i = 1:numel(cov_names)
        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(i).c = covs(:,i);
        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(i).cname = cov_names{i};
        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(i).iCC = 1;    
    end

    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {[base_dir 'AND_mask.nii']};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    % Estimate model
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(out_dir, 'SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    run_matlab(4, matlabbatch, 0);
    copyfile(which(mfilename),out_dir);
end

% go back to where we came from
cd(fallback);


%-------------------------FUCNTION: run_matlab-----------------------------
function run_matlab(np, matlabbatch, check)
% works both for windows and linux now thanks to noah hipp

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