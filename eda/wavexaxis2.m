function wavexaxis2(varargin)
% Customize x axis for plots

if nargin
    xlims = [0,varargin{1}];
else
    xlims = [0,110];
end


[~,ticks] = getBinBarPos(110);
xlim(xlims);
xticks([0 ticks(2:2:6) 110]);
xticklabels({'0','22','55','88', '110'});
xlabel('Time (s)', 'FontWeight','bold');
grid on;
ax = gca;
ax.XAxis.FontSize = 14;
