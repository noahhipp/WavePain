function aggregate_masks

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
        error('Only hosts noahs isn laptop accepted');
end

% Settings
all_subs    = [5:12 14:53];

mean_epi    = 0;

check       = 0;
do_warp     = 0;
do_agg      = 1;

% Specify folders
anadirname          = 'fir';
struc_templ         = '^sPRISMA.*\.nii';
all_wfl_masks       = [];

% Prepare multiprocessing
if size(all_subs) < n_proc
    n_proc = size(all_subs,2);
end
subs              = splitvect(all_subs, n_proc);

i_sub = 0;

% MP Loop
% Subject loop
for np = 1:size(subs,2)
    matlabbatch = [];
    mbi   = 0;
    
    for g = 1:size(subs{np},2)
        %-------------------------------
        %House keeping stuff
        i_sub           = i_sub + 1;
        name            = sprintf('sub%03d',subs{np}(g));
        st_dir          = fullfile(base_dir, name,'run000/mrt/');
        struc_file      = spm_select('FPList', st_dir, struc_templ);
        u_rc1_file      = ins_letter(struc_file,'u_rc1');
        a_dir           = [base_dir name filesep anadirname];
        
        % Subject spefific paths
        
        
        
        % Make warp template
        template    = [];
        fl_mask     = '';
        
        fl_mask     = fullfile(a_dir, 'mask.nii');
        
        
        dartel_prefix       = 'w_t1';
        if mean_epi
            st_dir          = fullfile(st_dir, 'mean_epi');
            u_rcl_file      = fullfile(st_dir, 'u_rc1meanafMRI.nii');
            dartel_prefix   = 'w_epi';
        end
        
        
        wfl_mask             = ins_letter(fl_mask,'w');
        wfl_dartel_files     = ins_letter(fl_mask, dartel_prefix); % or w_epi % same files as above but when moving later might as well specify normalization kind
        
        wfl_mask             = chng_path(wfl_mask, st_dir);    %wcon files still in t1 dir
        
        wfl_dartel_files      = chng_path(wfl_dartel_files, st_dir); %wcon files still in t1 dir
        wfl_dartel_files2     = chng_path(wfl_dartel_files, a_dir);  %wcon files still in ana dir
        
        
        template.spm.tools.dartel.crt_warped.flowfields = cellstr(repmat(u_rc1_file,size(fl_mask,1),1)); % either use u_rcl from t1 or from epis
        template.spm.tools.dartel.crt_warped.images = {cellstr(strvcat(fl_mask))};
        template.spm.tools.dartel.crt_warped.jactransf = 0;
        template.spm.tools.dartel.crt_warped.K = 6;
        template.spm.tools.dartel.crt_warped.interp = 1;
        
        
        
        if do_warp
            mbi = mbi + 1;
            matlabbatch{mbi} = template;
            
            mbi = mbi + 1;
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.files = cellstr(wfl_mask);
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.moveto = cellstr(a_dir);
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.pattern = 'w';
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.repl    = dartel_prefix;
            matlabbatch{mbi}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.unique         = false;
        end
        
        if do_agg
            all_wfl_masks = char(all_wfl_masks, wfl_dartel_files2); % Collect them for later
        end
        % loop end
        % loop end
        
    end
    if ~isempty(matlabbatch)
        run_matlab(np, matlabbatch, check)
    end
end

if do_agg
    aggbatch = [];    
    
    aggbatch{1}.spm.util.imcalc.input = cellstr(all_wfl_masks);
    aggbatch{1}.spm.util.imcalc.output = 'AND_mask';
    aggbatch{1}.spm.util.imcalc.outdir = cellstr(base_dir);
    aggbatch{1}.spm.util.imcalc.expression = 'all(X)';
    aggbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    aggbatch{1}.spm.util.imcalc.options.dmtx = 1;
    aggbatch{1}.spm.util.imcalc.options.mask = 0;
    aggbatch{1}.spm.util.imcalc.options.interp = 1;
    aggbatch{1}.spm.util.imcalc.options.dtype = 4;
    
    
    run_matlab(1, aggbatch, 0)
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
if check
    fprintf('\ncheck ON --> run_matlab() returned control to invoking function\n');
    return
end

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
