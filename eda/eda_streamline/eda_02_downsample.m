function eda_02_downsample
% Use interp1 to reduce sampling rate of EDA data

TARGET_HZ = 10;

EDA_NAME_IN     = 'all_eda_behav.csv';
[~,~,~,EDA_DIR] = wave_ghost('behav');
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);
[~,NAME, SUFFIX]= fileparts(EDA_FILE_IN);

DOWNSAMPLING_STR=...
    sprintf('_downsampled%02d',TARGET_HZ);
EDA_NAME_OUT    = [NAME, DOWNSAMPLING_STR, SUFFIX];
EDA_FILE_OUT    = fullfile(EDA_DIR, EDA_NAME_OUT);

if exist(EDA_FILE_OUT, 'file')
    fprintf('\n To run this function again\n delete %s\n', EDA_FILE_OUT);
    return
end

DATA = readtable(EDA_FILE_IN);
F    = TARGET_HZ;

% Preallocate output
ds_data = table;
variable_names = DATA.Properties.VariableNames;

% Loop over subs and resample
for i = unique(DATA.ID)'
    fprintf('\nresampling sub%03d\n',i);
    
    for j = unique(DATA.trial(DATA.ID == i))'
        fprintf('  trial %02d: ',j);
        
        % Pick trial
        trial = DATA(DATA.ID == i & DATA.trial == j,:);
        fprintf('%d samples --> ', height(trial));
        
        % Interpolate
        xq          = min(trial.time_within_trial):1/F:max(trial.time_within_trial);
        ds_trial    = interp1(trial.time_within_trial, trial{:,:}, xq);
        ds_trial    = array2table(ds_trial, 'VariableNames',...
            variable_names);
        ds_trial.index_within_trial = [1:1:height(ds_trial)]'; % we still want our index to be integers
        fprintf('%d samples ', numel(xq));
        
        % Concatenate output        
        ds_data = vertcat(ds_data,ds_trial);
        fprintf('✓\n');                
    end % trial loop end
end % sub loop end

% Write output
writetable(ds_data, EDA_FILE_OUT);
fprintf('\n Wrote %s\n with %d lines\n--> Reduction of lines by factor %f\n',...
    EDA_FILE_OUT, height(ds_data), height(DATA)./height(ds_data));

  
    


