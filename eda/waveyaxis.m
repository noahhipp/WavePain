function waveyaxis(t, lims)
% Sets y axis as we need it for most wavepain plots

ylim(lims);
ylabel(t, 'FontWeight','bold');
grid on;
ax = gca;
ax.YAxis.FontSize = 14;