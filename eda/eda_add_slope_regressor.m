function eda_add_slope_regressor
% Adds slope regressor to eda


data_file               = 'E:wavepain\data\fmri_sample\eda\all_eda_clean.csv';
[data_folder, data_name]= fileparts(data_file);

% Check if this has been done
check_name = strcat(fullfile(data_folder,data_name),'_has_slope.bin');
if exist(check_name, 'file')
    fprintf('\n To run this function again delete %s\n\n', ...
        check_name);
    return
end

% Read in data
data                = readtable(data_file);

% Prepare regressor: A positive diff (n+1 > n) indicates a positive slope,
% negative diff (n+1 < n) indicates negative slope. numel(diff(V)) -
% numel(V) = -1 so have to prepend a 0. 
slope               = vertcat(0, diff(data.heat)); 

% Binarize it
slope(slope > 0)    = 1;
slope(slope < 0)    = -1;

% Put it in
data.slope          = slope;
data                = movevars(data, 'slope', 'After','wm');
writetable(data,data_file);

% Log it by creating a check file
fid = fopen(check_name, 'w');
fwrite(fid, 1, 'logical');
fclose(fid);


