function eda_01_add_regressors_and_variables
% 1. Generates the following columns for EDA Data:
% - diffheat: first order derivative
% - zt_scl: within trial zscored scl
% - zt_dtt_scl: wtihin trial zscored --> within trial detrended scl

% - shifted version of all scl/eda cols

% Constants
[~,~,~,EDA_DIR] = wave_ghost('behav');
EDA_NAME_IN     = 'all_eda_behav.csv';
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);
EDA_FILE_OUT    = EDA_FILE_IN;
SHIFT_NAME      = 'eda_bestshifts.csv';
SHIFT_FILE      = fullfile(EDA_DIR, SHIFT_NAME);
CHECK_NAME      = 'all_eda_behav_has_shifted_cols.bin';
CHECK_FILE      = fullfile(EDA_DIR, CHECK_NAME);
F               = 25;

shift_prefix = 's_';

if exist(CHECK_FILE, 'file')
    fprintf('To run this again\n delete %s\n', CHECK_FILE);
end

do_shift = 1;

% Read in data
DATA = readtable(EDA_FILE_IN);
SHIFT = readtable(SHIFT_FILE);

% Preallocate new cols
empty_col       = nan(height(DATA),1);
DATA.diffheat   = empty_col;
DATA.zt_scl     = empty_col;
DATA.zt_dtt_scl = empty_col;

if do_shift
    cols_to_shift   = DATA.Properties.VariableNames(...
        contains(DATA.Properties.VariableNames,{'scl','eda'}));
    
    % prevent double shifting in case we ever want to run this again
    cols_to_shift   = cols_to_shift(~contains(cols_to_shift, shift_prefix));
    for i = 1:numel(cols_to_shift)
        col_to_shift = cols_to_shift{i};        
        % copy column to be shifted and prepend s_
        DATA{:,strcat(shift_prefix,col_to_shift)} = empty_col;
    end
end

% Fill new cols in
DATA.diffheat = vertcat(0, diff(DATA.heat));
DATA.diffheat = DATA.diffheat ./ max(DATA.diffheat); % correct range to -1 1
fprintf('DATA.diffheat range is now: %f - %f\n', min(DATA.diffheat), max(DATA.diffheat));

for i = unique(DATA.ID)'
    fprintf('\nsub%03d',i);
    
    for j = unique(DATA.trial(DATA.ID ==i))'
        fprintf('\n    trial %02d',j);
        
        % Select trial
        trial = DATA(DATA.trial ==j & DATA.ID ==i,:);
        
        % Modify cols
        trial.zt_scl        = zscore(trial.native_scl);
        trial.zt_dtt_scl    = detrend(trial.zt_scl);
        
        if mean(trial.condition < 5)
            shift = SHIFT.behav_wm;
        else
            shift = SHIFT.behav_online;
        end
        
        % Loop through columns to be shifted
        if do_shift
            for k = 1:numel(cols_to_shift)                
                % We write data from this column...
                col_to_shift = cols_to_shift{k}; 
                
                % ... to this one.
                shifted_col  = strcat(shift_prefix, cols_to_shift{k});
                fprintf('%s ', col_to_shift);
                
                % But before we have to shift it
                trial{:, shifted_col} = ...
                    nanshift(trial{:, col_to_shift}, shift*F);
            end
        end
        % Put trial back
        DATA(DATA.trial ==j & DATA.ID ==i,:) = trial;
    end
end

DATA = movevars(DATA,'diffheat','After', 'slope');

writetable(DATA,EDA_FILE_OUT);
fprintf('Rewrote %s\n', EDA_FILE_OUT);



