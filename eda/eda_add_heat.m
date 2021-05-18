function eda_add_heat
% Adds heat regressor to eda file of choice

EDA_NAME_IN     = 'all_eda_behav_downsampled01_collapsed.csv';
[~,~,~,EDA_DIR] = wave_ghost('behav');
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);
[~,NAME, SUFFIX]= fileparts(EDA_FILE_IN);
EDA_FILE_OUT    = EDA_FILE_IN;

CHECK_NAME = [NAME, '_has_temps.bin'];
CHECK_FILE = fullfile(EDA_DIR, CHECK_NAME);

TEMP_FILE = "E:\wavepain\data\behav_sample\threshholding\behav_temps.csv";

% Avoid double work
if exist(CHECK_FILE,'file')
    fprintf('to run this function again\ndelete %s\n',CHECK_FILE);
    return
end

% Collect data
DATA  = readtable(EDA_FILE_IN);
TEMPS = readtable(TEMP_FILE);

% Preallocate new cols
cols_to_transfer = {'vas0','vas30','vas60'};
empty_cols = nan(height(DATA),numel(cols_to_transfer));
DATA{:,cols_to_transfer} = empty_cols;

for i = 1:numel(TEMPS.ID)
    sub = TEMPS.ID(i);
    sub_idx = DATA.ID == sub;
    
    DATA.vas0(sub_idx) = TEMPS.vas0(TEMPS.ID == sub);
    DATA.vas30(sub_idx) = TEMPS.vas30(TEMPS.ID == sub);
    DATA.vas60(sub_idx) = TEMPS.vas60(TEMPS.ID == sub);
end

% Write output
writetable(DATA,EDA_FILE_OUT);
fprintf('Rewrote %s\nnow with temps!',EDA_FILE_OUT);

% Write checkfile
f = fopen(CHECK_FILE, 'w');
fclose(f);
fprintf('Wrote %s\n', CHECK_FILE);

