% subtract online signal from corresponding wm conditions

behav = 1;
% CONSTANTS
BASE_STR = '_bl';


EDA_NAME_IN     = 'all_eda_behav_downsampled01_collapsed.csv';
[~,~,~,EDA_DIR] = wave_ghost('behav');
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);
[~,NAME, SUFFIX]= fileparts(EDA_FILE_IN);
EDA_FILE_OUT    = EDA_FILE_IN;

CHECK_NAME = [NAME, '_has_baseline_corrected_cols_scl.bin'];
CHECK_FILE = fullfile(EDA_DIR, CHECK_NAME);

% Avoid double work
if exist(CHECK_FILE,'file')
    fprintf('to run this function again\ndelete %s\n',CHECK_FILE);
    return
end

% Collect data
DATA = readtable(EDA_FILE_IN);

% Prepare new cols
cols_to_base        = {'s_zt_dtt_scl', 's_native_scl','s_zt_scl'};
based_cols          = strcat(cols_to_base, BASE_STR);
n_cols_to_base      = numel(cols_to_base);
DATA{:,based_cols}  = nan(height(DATA),n_cols_to_base);


for i = unique(DATA.ID)'
    fprintf('\nsub%03d',i);
    % Pick subject
    sub = DATA(DATA.ID == i,:);
    
    if behav
        if i < 15 % then we have no online scl to use for basing
            continue
        end
    end
    
    % Pick baseline
    m = sub{sub.condition == 5, cols_to_base};
    w = sub{sub.condition == 6, cols_to_base};
    
    % Get indices for correct cols
    ms = ismember(sub.condition, [1 2 5]);
    ws = ~ms;
    
    sub{ms, based_cols} = sub{ms, cols_to_base} - repmat(m,[3,1]);
    sub{ws, based_cols} = sub{ws, cols_to_base} - repmat(w,[3,1]);
    
    % Put subject back
    DATA(DATA.ID == i,:)=sub;
    fprintf(' ✓'); 
end

% Write output
writetable(DATA,EDA_FILE_OUT);
fprintf('\nRewrote %s\nwith %d added baseline columns\n', ...
    EDA_FILE_OUT, n_cols_to_base);

% Write check file
fh=fopen(CHECK_FILE, 'w');
fwrite(fh, 1, 'logical');
fclose(fh);