function eda_segment_by_slope
% Segments eda into segments by slope

% Housekeeping
[~,~,~,EDA_DIR] = wave_ghost();
EDA_NAME_IN     = 'all_eda_clean_downsampled10_shifted_collapsed.csv';
EDA_FILE_IN     = fullfile(EDA_DIR, EDA_NAME_IN);
EDA_NAME_OUT    = 'all_eda_clean_downsampled10_shifted_collapsed_segmented.csv';
EDA_FILE_OUT    = fullfile(EDA_DIR, EDA_NAME_OUT);

% Import data
DATA = readtable(EDA_FILE_IN);

% Corrections
DATA.wm = round(DATA.wm);
DATA.slope = round(DATA.slope);

% Loop through data
sub        = 0;
condition  = 0;
segment    = 0;

lines_read = 0;
lines_to_read = height(DATA);
data_out = table;
while lines_read < lines_to_read
    % Get index of slope
    start       = 1;
    
    try
        stops(1)    = find(diff(DATA.slope(start:end)),1); % until slope changes
    catch % for the last trial
        stops(1) = height(DATA);
    end
    
    try
        stops(2)    = find(diff(DATA.condition(start:end)),1); % until condition changes
    catch % we need this for when there is only one sb left to prevent empty assignment error
        stops(2) = nan;
    end
    stop        = min(stops); % so we do not take in next lead in when doing lead out            
    
    % Collect slice
    slope      = DATA(start:stop,:);
    DATA(start:stop,:) = []; % delete slice from cake
    height_slope = height(slope); % we need this later we slope is collapsed
    lines_read = lines_read + height_slope;
    
    if height_slope < 10 % drop artefacts
        continue
    end        
    
    % Collapse 
    slope = varfun(@nanmean, slope);        
    
    % Print information
    if slope.nanmean_ID ~= sub % then we have new subject
        sub = slope.nanmean_ID;
        fprintf('\n%d / %d lines read in\n', lines_read, lines_to_read);
        fprintf('\n\nsub%03d', sub);        
    end    
    if slope.nanmean_condition ~= condition % then we have new trial
        condition = slope.nanmean_condition;
        segment = 0; % Reset segment
        fprintf('\n    condition %02d:', condition);
    end
    segment = segment +1;
    fprintf(' %03d', height_slope);                                   
    
    % Append to output
    slope.segment  = segment;
    data_out        = vertcat(data_out, slope);
end

% Get rid of mean_ prefix
for i = 1:width(data_out)
    data_out.Properties.VariableNames{i} = strrep(data_out.Properties.VariableNames{i}, 'nanmean_','');
end

% Take care of sampling issues
data_out.wm = round(data_out.wm);
data_out.wm_X_slope = data_out.wm .* data_out.slope;

writetable(data_out, EDA_FILE_OUT);
fprintf('\n wrote %s\n', EDA_FILE_OUT);