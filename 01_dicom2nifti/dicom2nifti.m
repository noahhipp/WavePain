function dicom2nifti

base_dir          = '/projects/crunchie/hipp/wavepain';
%data_file         = 'C:\Users\hipp\projects\WavePain\code\matlab\fmri\cb_pipeline\data.mat';

check          = 1;

do_dcm_convert = 1;
do_move        = 1;

subs = [10:12, 14:53];

dummies           = 5;

n_runs = 2;
data_names = {'', 'fm_2TE', 'fm_Diff'};


for g = 1:size(subs,2)
    name = sprintf('sub%03d',subs(g));
    %-------------------------------
    %Do DICOM convert
    if do_dcm_convert      
        gi = 1;
        
        % Loop over runs (including epis and both fmaps)
        for run = 1:n_runs
            run_name = fullfile(sprintf('run%03d',run), 'mrt/');
            
            % Loop over datatypes
            for i = 1:numel(data_names)
                data_name = data_names{i};
                
                files = spm_select('FPList', fullfile(base_dir, name, run_name, data_name), '^MR');
                matlabbatch{gi}.spm.util.import.dicom.data = cellstr(files);
                matlabbatch{gi}.spm.util.import.dicom.outdir = {fullfile(base_dir, name, run_name, data_name)};
                
                matlabbatch{gi}.spm.util.import.dicom.root             = 'flat';
                matlabbatch{gi}.spm.util.import.dicom.protfilter       = '.*';
                matlabbatch{gi}.spm.util.import.dicom.convopts.format  = 'nii';
                matlabbatch{gi}.spm.util.import.dicom.convopts.meta    = 0;
                matlabbatch{gi}.spm.util.import.dicom.convopts.icedims = 0;
                gi = gi + 1;
                % and delete DICOMs
                matlabbatch{gi}.cfg_basicio.file_dir.file_ops.file_move.files         =  cellstr(files);
                matlabbatch{gi}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;
                gi = gi + 1;
            end % datatype loop
        end % run loop
        
        % T1
        if ~ismember(subs(g),[5,13])
            
            files = spm_select('FPList', fullfile(base_dir, name, 'run000/mrt/'), '^MR');
            matlabbatch{gi}.spm.util.import.dicom.data = cellstr(files);
            matlabbatch{gi}.spm.util.import.dicom.outdir = fullfile(base_dir, name, 'run000/mrt/');
            matlabbatch{gi}.spm.util.import.dicom.root             = 'flat';
            matlabbatch{gi}.spm.util.import.dicom.protfilter       = '.*';
            matlabbatch{gi}.spm.util.import.dicom.convopts.format  = 'nii';
            matlabbatch{gi}.spm.util.import.dicom.convopts.meta    = 0;
            matlabbatch{gi}.spm.util.import.dicom.convopts.icedims = 0;
            gi = gi + 1;
            %and delete DICOMs
            matlabbatch{gi}.cfg_basicio.file_dir.file_ops.file_move.files         =  cellstr(files);
            matlabbatch{gi}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;
            gi = gi + 1;
        end
        
        save matlabbatch matlabbatch
        spm_jobman('run',matlabbatch);
        clear matlabbatch;
        
    end
    
    %-------------------------------
    %Do move dummies
    if do_move
        gi = 1;
        for run = 1:n_runs
            run_name = fullfile(sprintf('run%03d',run), 'mrt');
            % and move dummy scans
            files = spm_select('FPList', fullfile(base_dir, name, run_name),'^fPRISMA.*\.nii');
            mkdir(fullfile(base_dir, name, run_name, 'dummy'));
            matlabbatch{gi}.cfg_basicio.file_dir.file_ops.file_move.files         = cellstr(files(1:dummies,:));
            matlabbatch{gi}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = {fullfile(base_dir, name, run_name,'dummy')};
            gi = gi + 1;
        end
        save matlabbatch matlabbatch
        spm_jobman('run',matlabbatch);
        clear matlabbatch;
    end
end % subject loop
