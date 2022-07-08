function d = wavereadtable(file)
% wrapper around readtable that takes care of the fact that .csv stores
% categoricals as cells

MAX_NUMBER_OF_CATEGORIES = 10;
d = readtable(file);

col_names = d.Properties.VariableNames;
potential_cat_cols = find(contains(varfun(@class, d, 'OutputFormat', 'cell'),...
    'cell'));

for i = 1:numel(potential_cat_cols)
    idx = potential_cat_cols(i);
    if numel(unique(d{:,idx})) <= MAX_NUMBER_OF_CATEGORIES
        d{:,idx} = categorical(d{:,idx});
        fprintf('Column %s now a categorical (again).\n',col_names{idx});
    end
end
    

