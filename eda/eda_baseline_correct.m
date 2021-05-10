function eda_baseline_correct

eda_name_in       = 'all_eda_clean_downsampled10_collapsed.csv';
eda_name_out      = 'all_eda_clean_downsampled10_collapsed.csv';
[~,~,~,eda_dir] = wave_ghost();
eda_file_in       = fullfile(eda_dir, eda_name_in);
eda_file_out      = fullfile(eda_dir, eda_name_out);

check_name        = 'all_eda_clean_downsampled10_collapsed_has_baseline_corrected_zdt_scl.bin';
check_file        = fullfile(eda_dir, check_name);

% Avoid double work or work without task
if exist(check_file, 'file') 
    fprintf('\n To run this function again delete %s\n\n', ...
        check_file);
    return
end

data = readtable(eda_file_in);


cols_to_base = 'scl';
new_col         = strcat(cols_to_base, '_bl');
data{:,new_col} = nan(height(data),1);


for i = unique(data.ID)'
    % Pick subject
    sub = data(data.ID == i,:);
    
    if i < 15 % then we have no online scl to use for basing
        continue
    end
    
    % Pick baseline
    m = sub{sub.condition == 5, cols_to_base};
    w = sub{sub.condition == 6, cols_to_base};
    
    % Get indices for correct cols
    ms = ismember(sub.condition, [1 2 5]);
    ws = ~ms;
    
    sub{ms, new_col} = sub{ms, cols_to_base} - repmat(m,[3,1]);
    sub{ws, new_col} = sub{ws, cols_to_base} - repmat(w,[3,1]);
    
    % Put subject back
    data(data.ID == i,:)=sub;
end

writetable(data,eda_file_out);

fh=fopen(check_file, 'w');
fwrite(fh, 1, 'logical');
fclose(fh);