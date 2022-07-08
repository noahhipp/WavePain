function ds_data = eda_downsample
% create new file with sampling rate of 1hz as opposed to the 40hz we put
% in. according to björn there is no benefit of using that much information

% SETTINGS
SAMPLE   = 'behav'; % can be behav or fmri
F = 0.5; % sample frequency of output

% Housekeeping
HOST                = wave_ghost2(SAMPLE);
EDA_DIR             = fullfile(HOST.dir, 'eda');
EDA_TEMPLATE_IN     = 'all_eda.csv';
EDA_TEMPLATE_OUT    = 'all_eda_sampled-at-half-a-hertz.csv';

EDA_FILE_IN         = fullfile(EDA_DIR, EDA_TEMPLATE_IN);
EDA_FILE_OUT        = fullfile(EDA_DIR, EDA_TEMPLATE_OUT);


% Avoid double work
if exist(EDA_FILE_OUT, 'file')
    fprintf('\nTo run this function again copy and exeute the next line:\ndelete %s\n',EDA_FILE_OUT);
    return;
end

% Read in data
data            = readtable(EDA_FILE_IN);

% Delete cols that are cells
col_classes     = varfun(@class, data, 'OutputFormat', 'cell');
col_names       = data.Properties.VariableNames;
cell_col_idxs   = contains(col_classes, 'cell');
data(:, cell_col_idxs) = [];
fprintf('Deleted the following cols:\n');
disp(col_names(cell_col_idxs));

% Preallocate output
ds_data = table;
names   = data.Properties.VariableNames;

% Loop over subs
for i = unique(data.id)'
    fprintf('\n===========\nresampling sub%03d\n',i);
    for j = unique(data.trial(data.id == i))'
        fprintf('trial %02d: ',j);
        
        % Pick trial
        trial = data(data.id == i & data.trial == j,:);
        fprintf('%d samples --> ', height(trial));
        
        % Interpolate
        xq          = min(trial.time_within_trial):1/F:max(trial.time_within_trial);
        ds_trial    = interp1(trial.time_within_trial, trial{:,:}, xq);
        ds_trial    = array2table(ds_trial, 'VariableNames', names);
        ds_trial.index_within_trial = [1:1:height(ds_trial)]'; % we still want our index to be integers
        fprintf('%d samples ', numel(xq));
        
        % Concatenate output        
        ds_data = vertcat(ds_data,ds_trial);
        fprintf('done\n');
        
    end % trial loop end
end % subject loop end

% Round categoricals
ds_data.wm = round(ds_data.wm);
ds_data.slope = round(ds_data.slope);

% Write output
writetable(ds_data, EDA_FILE_OUT);