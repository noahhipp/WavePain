function wave_tconplot(x, ylims)

if numel(x) ~= 360
    error('Wrong length')
end


subplot(2,2,1); waveplot(x(1:60), 'M21'); wavexaxis; title('M21'); ylim(ylims);
subplot(2,2,3); waveplot(x(61:120), 'M12'); wavexaxis; title('M12'); ylim(ylims);
subplot(2,2,2); waveplot(x(121:180), 'W21'); wavexaxis; title('W21'); ylim(ylims);
subplot(2,2,4); waveplot(x(181:240), 'W12'); wavexaxis; title('W12'); ylim(ylims);