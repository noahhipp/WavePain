function wave_updating
% used to change the title of fir_fig and pmod_fig to updating until data
% from new coordinates is plotted

global fir_fig;
global pmod_fig;
if ishandle(fir_fig)
    figure(fir_fig);
    sgtitle('Updating...');
end

if ishandle(pmod_fig)
    figure(pmod_fig);
    sgtitle('Updating...');
end