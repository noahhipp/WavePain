function parametric_contrasts
% Makes 3 Parametric contrasts for second_level_anova of wavepain:
% 1. "heat": z_scored waveit2 wave for each stimulus [M M W W M W]
% 2. "working_memory": box car function encoding wm_task (1 --> 2back aka
% high wm load, -1--> 1 back aka low wm load)
% 3. "heat_x_wm" --> interaction of the two


% House keeping
hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 4;
    otherwise
        error('Only hosts noahs isn laptop accepted');
end

% Settings
do_plot = 1;
do_cons = 1;
con_names = {'heat', 'working_memory', 'heat_X_working_memory','heat_X_working_memory_flipped', 'down_slope_2back_vs_1back'};

skern               = 6;
addon               = 'anova';
anadirname         = 'fir';
out_dir             = [base_dir 'second_Level' filesep anadirname '_' addon '_' num2str(skern)];


% Unpack parametric contrasts
parametric_contrasts    = plot_parametric_contrasts(0);
m                       = parametric_contrasts.m;
w                       = parametric_contrasts.w;

obtb                    = parametric_contrasts.obtb;
tbob                    = parametric_contrasts.tbob;

m21                     = parametric_contrasts.m21;
m12                     = parametric_contrasts.m12;
w21                     = parametric_contrasts.w21;
w12                     = parametric_contrasts.w12;

% Construct convectors
convec(1,:) = [m m w w m w]; % heat
convec(2,:) = [tbob obtb tbob obtb, zeros(1,120)]; % working memory
convec(3,:) = convec(1,:).*convec(2,:); % interaction
convec(4,:) = -convec(3,:); % interaction flipped


convec(5,:) = [m21(1:28), zeros(1,32),... % task effect on down slope
              m12(1:28), zeros(1,32),...
              zeros(1,28), w21(29:end),...
              zeros(1,28), w12(29:end), zeros(1,120)];




% SPM code
matlabbatch                                                 = [];
matlabbatch{1}.spm.stats.con.spmmat = {fullfile(out_dir, 'SPM.mat')};
matlabbatch{1}.spm.stats.con.delete = 0; % we want to append contrasts

for i = 1:size(con_names,2)
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.name       = con_names{i};
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.convec     = convec(i,:);
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.sessrep    = "none";
end

if do_plot
    name = 'check';
    figure('Name',name, 'Color', [1 1 1]);
    for i = 1:size(con_names,2)
        subplot(3,1,i);
        plot(convec(i,:));
        ylim([-2 2]);        
        vline([60:60:360],'k-');
        vline([55:60:355], 'k--');
        xlim([0,360]);        
        title(con_names{i}, 'interpreter','none');        
    end
    check = input('press y and enter to proceed, else just hit enter\n', 's');
    if ~strcmp(check,'y')
        close(name);
        fprintf('ABORTING\n\n')
        return
    end
end

if do_cons
    spm_jobman('run', matlabbatch);
end

