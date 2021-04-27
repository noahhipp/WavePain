function ds_data = eda_downsample
% create new file with sampling rate of 1hz as opposed to the 40hz we put
% in. according to björn there is no benefit of using that much information

% Housekeeping
eda_name_in        = 'all_eda_clean.csv';
eda_name_out       = 'all_eda_clean_downsampled.csv';
[~,~,~,eda_dir] = wave_ghost;
eda_file_in       = fullfile(eda_dir, eda_name_in);
eda_file_out      = fullfile(eda_dir, eda_name_out);

% Avoid double work
if exist(eda_file_out, 'file')
    fprintf('\nTo run this function again delete: %s\n',eda_file_out);
    return;
end

% Read in data
data            = readtable(eda_file_in);

% Preallocate output
ds_data = table;
names   = data.Properties.VariableNames;

% Loop over subs
for i = unique(data.ID)'
    fprintf('\n===========\nresampling sub%03d\n',i);
    for j = unique(data.trial(data.ID == i))'
        fprintf('trial %02d: ',j);
        
        % Pick trial
        trial = data(data.ID == i & data.trial == j,:);
        fprintf('%d samples --> ', height(trial));
        
        % Interpolate
        xq          = min(trial.time_within_trial):1:max(trial.time_within_trial);
        ds_trial    = interp1(trial.time_within_trial, trial{:,:}, xq);
        ds_trial    = array2table(ds_trial, 'VariableNames', names);
        ds_trial.index_within_trial = [1:1:height(ds_trial)]'; % we still want our index to be integers
        fprintf('%d samples ', numel(xq));
        
        % Concatenate output        
        ds_data = vertcat(ds_data,ds_trial);
        fprintf('done\n');
        
    end % trial loop end
end % subject loop end

% Write output
writetable(ds_data, eda_file_out);