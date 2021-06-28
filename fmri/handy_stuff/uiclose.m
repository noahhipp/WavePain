function uiclose
% Closes all figs including ui figures
all_fig = findall(0, 'type', 'figure');
close(all_fig)