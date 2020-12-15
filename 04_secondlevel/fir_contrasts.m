function fir_contrasts
% Defines all the contrasts for 60*2s FIR analysis of wavepain mri data

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
do_plot = 0;
do_cons = 1;

% Housekeeping
skern               = 6;
addon               = 'anova';
anadirname         = 'fir';
out_dir             = [base_dir 'second_Level' filesep anadirname '_' addon '_' num2str(skern)];
parametric_contrasts    = plot_parametric_contrasts(0); % arithmetic for parametric contrasts is done in plot_parametric_contrasts


%%%%%%%%%%%%%%%%%%%%%%
fcon_i = 1;         %%
fconmat= [];        %% each fcon is a matrix!!!
%fconvec=[] % matrix doesnt work yet
%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
tcon_i = 1;         %%
tconvec= [];        %% each tcon is a row!!!
%%%%%%%%%%%%%%%%%%%%%%




% Eoi contrasts
eoi_names       = {'eoi_m21', 'eoi_m12', 'eoi_w21', 'eoi_w12', 'eoi_monline', 'eoi_wonline'};

fconeye = eye(60) - mean(eye(60));
fconmat(:,:,fcon_i) = [zeros(60,0), fconeye,   zeros(60,300)]; fcon_i = fcon_i+1; 
fconmat(:,:,fcon_i) = [zeros(60,60), fconeye,  zeros(60,240)]; fcon_i = fcon_i+1; 
fconmat(:,:,fcon_i) = [zeros(60,120), fconeye, zeros(60,180)]; fcon_i = fcon_i+1; 
fconmat(:,:,fcon_i) = [zeros(60,180), fconeye, zeros(60,120)]; fcon_i = fcon_i+1; 
fconmat(:,:,fcon_i) = [zeros(60,240), fconeye, zeros(60,60)]; fcon_i = fcon_i+1; 
fconmat(:,:,fcon_i) = [zeros(60,300), fconeye, zeros(60,0)]; fcon_i = fcon_i+1; 


% Online aka (baseline) difference contrasts
% baseline_difference_names = {'m21_vs_monline', 'm12_vs_monline', 'w21_vs_wonline', 'w12_vs_wonline',...
%                             'm21_vs_m12', 'w21_vs_w12'};                        
% fconmat(:,:,fcon_i) = [zeros(60,0),   eye(60), zeros(60,180), -eye(60), zeros(60,60)]; fcon_i = fcon_i +1;                       
% fconmat(:,:,fcon_i) = [zeros(60,60),  eye(60), zeros(60,120), -eye(60), zeros(60,60)]; fcon_i = fcon_i +1;                        
% fconmat(:,:,fcon_i) = [zeros(60,120), eye(60), zeros(60,120), -eye(60), zeros(60,0)]; fcon_i = fcon_i +1;                        
% fconmat(:,:,fcon_i) = [zeros(60,180), eye(60), zeros(60,60),  -eye(60), zeros(60,0)]; fcon_i = fcon_i +1;                        
% fconmat(:,:,fcon_i) = [zeros(60,0),   eye(60), zeros(60,0),   -eye(60), zeros(60,240)]; fcon_i = fcon_i +1;                        
% fconmat(:,:,fcon_i) = [zeros(60,120), eye(60), zeros(60,0),   -eye(60), zeros(60,120)]; fcon_i = fcon_i +1;                        

% Eoi contrasts V2
% eoi_names       = {'eoi_m21', 'eoi_m12', 'eoi_w21', 'eoi_w12', 'eoi_monline', 'eoi_wonline'};
% fconvec(fcon_i,:)    =         61:408 ; fcon_i = fcon_i + 1;
% fconvec(fcon_i,:)    = [1:60  121:408]; fcon_i = fcon_i + 1;
% fconvec(fcon_i,:)    = [1:120 181:408]; fcon_i = fcon_i + 1;
% fconvec(fcon_i,:)    = [1:180 241:408]; fcon_i = fcon_i + 1;
% fconvec(fcon_i,:)    = [1:240 301:408]; fcon_i = fcon_i + 1;
% fconvec(fcon_i,:)    = [1:300 361:408]; fcon_i = fcon_i + 1;


% Working memory contrasts
obtb            = parametric_contrasts.obtb;
tbob            = parametric_contrasts.tbob;
ob              = -ones(1,17);
tb              =  ones(1,17);
nb              = zeros(1,17);
lead_in         = zeros(1,11);
lead_out        = zeros(1,15);
working_memory_names = {'working_memory', 'working_memory_up_slope', 'working_memory_down_slope', ...
                        'working_memory_m', 'working_memory_w'};
tconvec(tcon_i, :) = [tbob obtb tbob obtb, zeros(1,120)]; tcon_i = tcon_i + 1;
tconvec(tcon_i, :) = [lead_in, nb, ob, lead_out, lead_in, nb, tb, lead_out, lead_in, tb, nb, lead_out, lead_in, ob, nb, lead_out, zeros(1,120) ]; tcon_i = tcon_i + 1;
tconvec(tcon_i, :) = [lead_in, tb, nb, lead_out, lead_in, ob, nb, lead_out, lead_in, nb, ob, lead_out, lead_in, nb, tb, lead_out, zeros(1,120) ]; tcon_i = tcon_i + 1;
tconvec(tcon_i, :) = [lead_in, tb, ob, lead_out, lead_in, ob, tb, lead_out, zeros(1,240) ]; tcon_i = tcon_i + 1;
tconvec(tcon_i, :) = [zeros(1,120), lead_in, tb, ob, lead_out, lead_in, ob, tb, lead_out, zeros(1,120)]; tcon_i = tcon_i + 1;


% Parametric heat contrasts
m                   = parametric_contrasts.m;
w                   = parametric_contrasts.w;
dm                  = parametric_contrasts.dm; % dm = m' aka the first temporal derivative of m
dw                  = parametric_contrasts.dw;
heat_names          = {'heat', 'dheat', 'dunsigned_heat'};
tconvec(tcon_i,:)   = [m, m, w, w, m, w]; tcon_i = tcon_i + 1;
tconvec(tcon_i,:)   = [dm, dm, dw, dw, dm, dw]; tcon_i = tcon_i + 1;
tconvec(tcon_i,:)   = zscore(abs([dm, dm, dw, dw, dm, dw])); tcon_i = tcon_i + 1;


% Interactions a_X_b
m21                 = parametric_contrasts.m21;
m12                 = parametric_contrasts.m12;
w21                 = parametric_contrasts.w21;
w12                 = parametric_contrasts.w12;
interaction_names   = {'m21','m12','w21','w12',...
                    'placebo','nocebo','placebo>nocebo','placebo<nocebo', ...
                    'heat_X_working_memory','heat_X_working_memory_flipped',...
                    'heat_X_working_memory2', 'heat_X_working_memory2_flipped',...
                    'heat_X_working_memory3', 'heat_X_working_memory3_flipped',...
                    'down_slope_2back_>_1back', 'down_slope_2back_<_1back',...
                    'down_slope_2back_>_1back2', 'down_slope_2back_<_1back2',... % contrasts shifted completely
                    'dheat_X_working_memory', 'dheat_X_working_memory_flipped',...
                    'down_slope_2back_>_1back3', 'down_slope_2back_<_1back3',...
                    'dheat_X_heat_working_memory', 'dheat_X_heat_working_memory_flipped'};% interaction: dheat_X_wm (not heat_X_wm as above)

                
tconvec(tcon_i,:)   = zscore([zeros(1,0), m21 zeros(1,300)]);   tcon_i = tcon_i + 1; % m21
tconvec(tcon_i,:)   = zscore([zeros(1,60), m12 zeros(1,240)]);  tcon_i = tcon_i + 1; % m12
tconvec(tcon_i,:)   = zscore([zeros(1,120), w21 zeros(1,180)]); tcon_i = tcon_i + 1; % w21
tconvec(tcon_i,:)   = zscore([zeros(1,180), w12 zeros(1,120)]); tcon_i = tcon_i + 1; % w12

tconvec(tcon_i,:)   = zscore([zeros(1,60), m12 w21 zeros(1,180)]); tcon_i = tcon_i + 1; % placebo aka down conditions
tconvec(tcon_i,:)   = zscore([zeros(1,0), m21 zeros(1,120) w12 zeros(1,120)]); tcon_i = tcon_i + 1; % nocebo aka up conditions                
tconvec(tcon_i,:)   = zscore([-m21 m12 w21 -w12 zeros(1,120)]); tcon_i = tcon_i + 1; % placebo>nocebo 
tconvec(tcon_i,:)   = zscore([m21 -m12 -w21 w12 zeros(1,120)]); tcon_i = tcon_i + 1; % placebo<nocebo
                
                
tconvec(tcon_i,:)   =  [m, m, w, w, m, w].*[tbob obtb tbob obtb, zeros(1,120)]; tcon_i = tcon_i + 1; % heat_X_working_memory
tconvec(tcon_i,:)   = -[m, m, w, w, m, w].*[tbob obtb tbob obtb, zeros(1,120)]; tcon_i = tcon_i + 1; % heat_X_working_memory_flipped

tconvec(tcon_i,:)   =  [m21(1:11), shiftup(m21(12:28)), shiftdown(m21(29:45)), m21(46:end),...
                        m12(1:11), shiftdown(m12(12:28)), shiftup(m12(29:45)), m12(46:end),...
                        w21(1:11), shiftup(w21(12:28)), shiftdown(w21(29:45)), w21(46:end),...
                        w12(1:11), shiftdown(w12(12:28)), shiftup(w12(29:45)), w12(46:end),...
                        zeros(1,120)]; tcon_i = tcon_i + 1; % heat_X_working_memory2

tconvec(tcon_i,:)   =  -[m21(1:11), shiftup(m21(12:28)), shiftdown(m21(29:45)), m21(46:end),...
                        m12(1:11), shiftdown(m12(12:28)), shiftup(m12(29:45)), m12(46:end),...
                        w21(1:11), shiftup(w21(12:28)), shiftdown(w21(29:45)), w21(46:end),...
                        w12(1:11), shiftdown(w12(12:28)), shiftup(w12(29:45)), w12(46:end),...
                        zeros(1,120)]; tcon_i = tcon_i + 1; % heat_X_working_memory2_flipped                                        
                    
tconvec(tcon_i,:)   =  [m21(1:11), -shiftup(m21(12:28)), shiftdown(m21(29:45)), m21(46:end),...
                        m12(1:11), -shiftdown(m12(12:28)), shiftup(m12(29:45)), m12(46:end),...
                        w21(1:11), shiftup(w21(12:28)), -shiftdown(w21(29:45)), w21(46:end),...
                        w12(1:11), shiftdown(w12(12:28)), -shiftup(w12(29:45)), w12(46:end),...
                        zeros(1,120)]; tcon_i = tcon_i + 1; % heat_X_working_memory3 % placebo slopes shifted above x axes, nocebo slopes shifted down
                    
tconvec(tcon_i,:)   =  -[m21(1:11), -shiftup(m21(12:28)), shiftdown(m21(29:45)), m21(46:end),...
                        m12(1:11), -shiftdown(m12(12:28)), shiftup(m12(29:45)), m12(46:end),...
                        w21(1:11), shiftup(w21(12:28)), -shiftdown(w21(29:45)), w21(46:end),...
                        w12(1:11), shiftdown(w12(12:28)), -shiftup(w12(29:45)), w12(46:end),...
                        zeros(1,120)]; tcon_i = tcon_i + 1; % heat_X_working_memory3_flipped % placebo slopes shifted below x axes, nocebo slopes shifted above                                        
                    
tconvec(tcon_i,:)   =  [m21(1:28), zeros(1,32),... % show areas where 2back > 1back
                        m12(1:28), zeros(1,32),...
                        zeros(1,28), w21(29:end),...
                        zeros(1,28), w12(29:end), zeros(1,120)]; tcon_i = tcon_i + 1;
tconvec(tcon_i,:)   = -[m21(1:28), zeros(1,32),... % show areas where 2back < 1back
                        m12(1:28), zeros(1,32),...
                        zeros(1,28), w21(29:end),...
                        zeros(1,28), w12(29:end), zeros(1,120)]; tcon_i = tcon_i + 1;                    
                    
tconvec(tcon_i,:)   =   [m21(1:11),(m21(12:28) - min(m21(12:28))), zeros(1,32),... % 2back sections completely shifted above x axis. 1back sections shifted belowe
                        m12(1:11), (m12(12:28) - max(m12(12:28))), zeros(1,32),...
                        zeros(1,28), (w21(29:45)-max(w21(29:45))), w21(46:end),...
                        zeros(1,28), (w12(29:45)-min(w12(29:45))), w12(46:end), zeros(1,120)]; tcon_i = tcon_i + 1;                                                                                                                        
tconvec(tcon_i,:)   =   -[m21(1:11),(m21(12:28) - min(m21(12:28))), zeros(1,32),... % 2back sections completely shifted above x axis. 1back sections shifted belowe
                        m12(1:11), (m12(12:28) - max(m12(12:28))), zeros(1,32),...
                        zeros(1,28), (w21(29:45)-max(w21(29:45))), w21(46:end),...
                        zeros(1,28), (w12(29:45)-min(w12(29:45))), w12(46:end), zeros(1,120)]; tcon_i = tcon_i + 1;

dheat               = [dm, dm, dw, dw, dm, dw];                    
dheat_X_wm          = dheat.* [tbob obtb tbob obtb zeros(1,120)];
tconvec(tcon_i,:)    = dheat_X_wm; tcon_i = tcon_i + 1;  % dheat_X_working_memory
tconvec(tcon_i,:)    = -dheat_X_wm; tcon_i = tcon_i + 1; % dheat_X_working_memory_flipped

not_down_slope= logical([ones(1,11), zeros(1,17), ones(1,32), ones(1,11), zeros(1,17), ones(1,32), ones(1,28),zeros(1,17),ones(1,15), ones(1,28),zeros(1,17),ones(1,15), ones(1,11), zeros(1,17), ones(1,32), ones(1,28),zeros(1,17),ones(1,15)]);
dheat_X_wm_down_slope       = dheat_X_wm;
dheat_X_wm_down_slope(not_down_slope) = 0;
tconvec(tcon_i,:)   = dheat_X_wm_down_slope; tcon_i = tcon_i+1; % down_slope_2back_>_1back3
tconvec(tcon_i,:)   = -dheat_X_wm_down_slope; tcon_i = tcon_i+1; % down_slope_2back_<_1back3 

tconvec(tcon_i,:) = [dheat.*[m m w w m w] .* [tbob obtb tbob obtb zeros(1,120)]]; tcon_i = tcon_i +1; % dheat_X_heat_X_wm
tconvec(tcon_i,:) = -[dheat.*[m m w w m w] .* [tbob obtb tbob obtb zeros(1,120)]]; tcon_i = tcon_i +1; % dheat_X_heat_X_wm


% Now shift vector
tconvec1 = circshift(tconvec,1,2);
tconvec2 = circshift(tconvec,2,2);
tconvec3 = circshift(tconvec,3,2);
tconvec = vertcat(tconvec, tconvec1, tconvec2,tconvec3);





% SPM code
matlabbatch = [];
mbi = 1;

% Do F-Contrasts
fcon_names                          = [eoi_names];
matlabbatch{mbi}.spm.stats.con.spmmat = {fullfile(out_dir, 'SPM.mat')};
matlabbatch{mbi}.spm.stats.con.delete = 1; % we want a clean slate
for i = 1:numel(fcon_names)
    matlabbatch{mbi}.spm.stats.con.consess{i}.fcon.name       = fcon_names{i};
    matlabbatch{mbi}.spm.stats.con.consess{i}.fcon.convec     = fconmat(:,:,i);
    matlabbatch{mbi}.spm.stats.con.consess{i}.fcon.sessrep    = "none";
end
mbi = mbi +1;

% % % Do F-Contrasts V2
% load(fullfile(out_dir, 'SPM.mat'), 'SPM');
% matlabbatch{mbi}.spm.stats.con.spmmat = {fullfile(out_dir, 'SPM.mat')};
% for i = 1:size(eoi_names,2)    
%     matlabbatch{mbi}.spm.stats.con.consess{i}.fcon.name = eoi_names{i};
% %     Fc = spm_FcUtil('Set','F_iXO_Test','F','c',fconvec(i,:),SPM.xX.X);
% 
%     matlabbatch{mbi}.spm.stats.con.consess{i}.fcon.iX0 = fconvec(i,:);
% end
% mbi = mbi + 1;


% Do t-Contrasts
tcon_names                          = [working_memory_names, heat_names, interaction_names];

% Make shift names and append to tcon
shift1_names = suffix(tcon_names, '_shift1');
shift2_names = suffix(tcon_names, '_shift2');
shift3_names = suffix(tcon_names, '_shift3');
tcon_names = [tcon_names, shift1_names, shift2_names, shift3_names];

matlabbatch{mbi}.spm.stats.con.spmmat = {fullfile(out_dir, 'SPM.mat')};
matlabbatch{mbi}.spm.stats.con.delete = 0; % already cleaned during fcon defitnion
for i = 1:size(tcon_names,2)
    matlabbatch{mbi}.spm.stats.con.consess{i}.tcon.name       = tcon_names{i};
    matlabbatch{mbi}.spm.stats.con.consess{i}.tcon.convec     = tconvec(i,:)';
    matlabbatch{mbi}.spm.stats.con.consess{i}.tcon.sessrep    = "none";
end
mbi = mbi +1;


if do_plot        
    % F Contrasts
    figure('Name','F-Contrasts', 'Color', [1 1 1]);
    sgtitle('F-CONTRASTS', 'FontSize', 24, 'FontWeight', 'bold');
    for i = 1:size(fcon_names,2)
        subplot(size(fcon_names,2), 1, i);       
        fcon_plot(fconmat(:,:,i));
        title(fcon_names{i}, 'interpreter','none')
    end
    
    % T Contrasts
    figure('Name','T-Contrasts', 'Color', [1 1 1]);
    sgtitle('T-CONTRASTS', 'FontSize', 24, 'FontWeight', 'bold');
    for i = 1:size(tcon_names,2)
        
        if ismember(i,[1,6])
            ajfafkl = 1;
        end
        
        
        subplot(size(tcon_names,2), 1, i);       
        tcon_plot(tconvec(i,:));
        title(tcon_names{i}, 'interpreter','none')
    end        
    
    % Check
    check = input('press y and enter to proceed, else just hit enter\n', 's');
    if ~strcmp(check,'y')
        close F-Contrasts T-Contrasts
        fprintf('ABORTING\n\n')
        return
    end
end

if do_cons
    spm_jobman('run', matlabbatch);
end

% Subfunctions
function fcon_plot(M)
% receives matrix and plots it as greyscaled image to current axis with
% some special wavepain customization
imagesc(M);
colormap(flipud(gray(256)));
cond_sep = vline(60:60:360, 'r-');
for i = 1:size(cond_sep,2)
    cond_sep(i).LineWidth = 2;
end
xticks(60:60:360);

function tcon_plot(v)
% receives vector and plots it to current axis wiht some special wavepain
% customization
plot(v, 'k-');
cond_sep = vline(60:60:360, 'r-');
for i = 1:size(cond_sep,2)
    cond_sep(i).LineWidth = 2;
end
xticks(60:60:360);

function v2 = shiftup(v)
% receives vector and shifts it above x axis that min(v) --> 0
v2 = v+abs(min(v));

function v2 = shiftdown(v)
% receives vector and shifts it below x axis that max(v) --> 0
v2 = v-abs(max(v)); 

function out = suffix(in, fix)
out = in
for i = 1:numel(in)
    out{i} = strcat(in{i}, fix);
end


