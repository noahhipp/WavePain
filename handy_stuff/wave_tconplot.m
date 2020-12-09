function wave_tconplot(x, varargin)

numvarargs = length(varargin);
if numvarargs > 2
    error('requires at most 2 optional arguments')
end
    
optargs = {'DEFAULT TITLE', [-2,2]};
optargs(1:numvarargs) = varargin;
[t, ylims] = optargs{:};

if numel(x) ~= 360
    error('Wrong length contrast')
end


subplot(2,2,1); [line, legendlabels] = waveplot2(x(1:60), 'M21',zeros(1,60), 55); wavexaxis(120); title('M21'); ylim(ylims);
legend(line(1:3), legendlabels, 'FontSize', 14);
subplot(2,2,3); waveplot2(x(61:120), 'M12',zeros(1,60), 55); wavexaxis(120); title('M12'); ylim(ylims);
subplot(2,2,2); waveplot2(x(121:180), 'W21',zeros(1,60), 55); wavexaxis(120); title('W21'); ylim(ylims);
subplot(2,2,4); waveplot2(x(181:240), 'W12',zeros(1,60), 55); wavexaxis(120); title('W12'); ylim(ylims);
sgtitle(t, 'FontSize', 30, 'FontWeight','bold', 'Interpreter','none');