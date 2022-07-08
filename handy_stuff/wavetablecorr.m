function wavetablecorr(d)

col_names = strrep(d.Properties.VariableNames, '_',' ');

figure; imagesc(corrcoef(d{:,:}));
xticks(1:width(d));
yticks(1:width(d));
xticklabels(col_names);
xtickangle(45);
yticklabels(col_names);
colorbar;