function eda_detrend
% Removes linear trend within session and/or within trial

within_session = 1;
within_trial   = 1;

% Housekeeping
eda_name_in        = 'all_eda_clean_downsampled.csv';
eda_name_out       = 'all_eda_clean_downsampled.csv';
[~,~,~,eda_dir] = wave_ghost;
eda_file_in       = fullfile(eda_dir, eda_name_in);
eda_file_out      = fullfile(eda_dir, eda_name_out);

check_name        = 'all_eda_clean_downsampled_has_zdtm_scl.bin';
check_file        = fullfile(eda_dir, check_name);

% Avoid double work or work without task
if exist(check_file, 'file') || (~within_session && ~within_trial)
    fprintf('\n To run this function again delete %s\n\n', ...
        check_file);
    return
end

% Read in data
data            = readtable(eda_file_in);

% Preallocate empty column
data.zdtm_scl  = nan(height(data),1);

% Loop over data
for i = unique(data.ID)'
    fprintf('\n===============\ndetrending sub%03d\n',i);
    for j = unique(data.session(data.ID == i))'        
        % Grab session
        session = data(data.ID == i & data.session == j,:);
        fprintf('grabbed session %d containing %d samples ',...
            j, height(session));
        
        
        % Manipulate it
        if within_session
            session.zdtm_scl = detrend(session.z_scl);
            fprintf('- detrended -\n');
        else
            session.zdtm_scl = session.z_scl;
        end
        
        for k = unique(session.trial)'
            
            % Grab trial
            trial = session(session.trial == k,:);
            fprintf('      grabbed trial %d containing %d samples ',...
                k, height(trial));
            
            % Manipulate it
            if within_trial
                trial.zdtm_scl = trial.zdtm_scl;
                fprintf(' - demeaned - ');
            end
            
            % Put trial back
            session(session.trial == k,:) = trial;
            fprintf('put back.\n');
        end
        
        % Put session back
        data(data.ID == i & data.session == j,:) = session;
        fprintf('put back.\n');
    end
    fprintf('\n');
end

% Write out file
writetable(data, eda_file_out);

% Write check file
fh = fopen(check_file, 'w');
fwrite(fh, 1, 'logical');
fclose(fh);
fprintf('Wrote %s \n', check_file);