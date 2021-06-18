function waveyaxis(t, lims)
% Sets y axis as we need it for most wavepain plots

ylim(lims);
ylabel(t, 'FontWeight','bold');
grid on;
ax = gca;
ax.YAxis.FontSize = 12;
if isequal(lims, [0 100])
    ax.YTick = [0 30 60 100]
end