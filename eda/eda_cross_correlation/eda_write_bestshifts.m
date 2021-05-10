function eda_write_bestshifts
% Writes best shifts as obtained by wavecorr to table for later access

% Constants
[~,~,~,EDA_DIR] = wave_ghost;
NAME_OUT        = 'eda_bestshifts.csv';
FILE_OUT        = fullfile(EDA_DIR, NAME_OUT);

% 
shift = table;
shift.fmri_all = -7.9;
shift.fmri_wm = -7.4;
shift.fmri_online = -8.6;

shift.behav_all = -4.6;
shift.behav_wm = -5.0;
shift.behav_online = -3.9;

writetable(shift,FILE_OUT);
fprintf('best shifts written to %s\n', FILE_OUT);

