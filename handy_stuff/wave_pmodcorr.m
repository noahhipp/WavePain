function wave_pmodcorr
% Visualize cov matrix of pmods

load E:\wavepain\data\fmri_sample\fmri\second_Level\second_level_anovacanonical_pmodV6\pmod_struct.mat

HOST            = wave_ghost2('fmri'); %wave_gethost
FIG_DIR         = fullfile(HOST.results,...
    '2023', '10_canonical_pmodV6');
if ~exist(FIG_DIR, 'dir')
    mkdir(FIG_DIR);
end


% Obtain names
wm_names = pmod_struct.names(1:13);
online_names = pmod_struct.names(14:18);

% Loop through subs
subs = fieldnames(pmod_struct);
subs = subs(contains(subs,'sub'));

for i = 1:numel(subs)
    sub = subs{i};
    sub_data = pmod_struct.(sub);
    
    f = figure('WindowState', 'maximized');

    for j = 1:2 % sessions
        wm = array2table(sub_data.wm{j}(:,2:end), 'VariableNames', wm_names);
        online = array2table(sub_data.online{j}(:,[2 5 8 13 14]), 'VariableNames', online_names);
        
        subplot(2,2,1+(2*(j-1)));
        wavetablecorr(wm);
        title(sprintf("session %d: WM conditions", j));
        
        subplot(2,2,2+(2*(j-1)));
        wavetablecorr(online);
        title(sprintf("session %d: ONLINE conditions", j));
    end
    
    sgtitle(sub);
    
    fname = fullfile(FIG_DIR, sprintf("pmod_covmat_%s", sub));
    print(fname, '-dpng','-r300');
    fprintf("wrote %s.png\n", fname);
    
    close(f);
end


