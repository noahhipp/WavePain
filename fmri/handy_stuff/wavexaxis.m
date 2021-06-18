function wavexaxis(varargin)
% Customizes x axis as we often need it for wavepain plot

if nargin
    xlims = [0,varargin{1}];
else
    xlims = [0,110];
end


[~,ticks] = getBinBarPos(110);
xlim(xlims);
xticks([0 ticks([1 2:2:6]) 110]);
xticklabels({'0','5','22','55','88','110'});
xlabel('Time [s]', 'FontWeight','bold');
grid on;
ax = gca;
ax.FontSize = 14;
