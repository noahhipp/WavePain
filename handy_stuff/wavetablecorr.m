function wavetablecorr(d)

col_names = strrep(d.Properties.VariableNames, '_',' ');

% delete cols of type cell
col_types = varfun(@class, d, 'OutputFormat', 'cell');
cols_of_type_cell = contains(col_types, 'cell');
d(:,cols_of_type_cell) = [];



imagesc(corrcoef(d{:,:}));
xticks(1:width(d));
yticks(1:width(d));
xticklabels(col_names);
xtickangle(45);
yticklabels(col_names);
colorbar;