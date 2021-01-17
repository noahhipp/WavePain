function second_level_multiple_regression

% My scans have to look like this
% {'/projects/crunchie/hipp/wavepain/sub053/fir/s6w_t1con_0347.nii'}
%     {'/projects/crunchie/hipp/wavepain/sub053/fir/s6w_t1con_0348.nii'}
%     {'/projects/crunchie/hipp/wavepain/sub053/fir/s6w_t1con_0349.nii'}
%     {'/projects/crunchie/hipp/wavepain/sub053/fir/s6w_t1con_0350.nii'}
%     {'/projects/crunchie/hipp/wavepain/sub053/fir/s6w_t1con_0351.nii'}

hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 4;
    otherwise
        error('Only hosts revelations or noahs isn laptop accepted');
end


all_subs = [5:12 14:53];
do_debug = 0;
do_plot  = 1; % there are a few sanity plots throughout the script
do_model = 1;

skern = 6;
anadirname = 'mreg';
addon = 'anova';
old_ananame = 'fir'; % we need this to import files
file_filter = 's6w_t1con';
n_cons = nan(1,numel(all_subs));

out_dir             = [base_dir 'second_Level' filesep anadirname '_' addon '_' num2str(skern)];


% Prepare images
con_images = {};
for i = 1:numel(all_subs)
    sname       = sprintf('sub%03d', all_subs(i)); fprintf('doing %s...\n', sname);    
    sdir        = fullfile(base_dir, sname, old_ananame);
    sfiles      = cellstr(spm_select('FPList',sdir,file_filter)); % use FPList for full path    
    
    n_cons(1,i)     = numel(sfiles); % to plot files per subject later 
    con_images      = vertcat(con_images, sfiles);
    
    % Debug
    if do_debug
        disp(sfiles); 
        prompt = 'Do you want more? y/n [y]: ';
        str = input(prompt,'s');
        if isempty(str)
            str = 'y';
        end

        if strcmp(str, 'n')
            fprintf('aborting\n\n');
            return
        elseif strcmp(str, 'y')
            fprintf('proceeding to next sub...\n\n');
        end                  
    end    
end

% Check if all have 360 cons
if do_plot
    figure();
    bar(all_subs, n_cons);
    title('CONS PER SUBJECT', 'FontWeight', 'bold', 'FontSize', 24);
    ylabel('Number of cons'); xlabel('Subject');
    ylim([0 400]); grid on;
end


% Prepare parametric regressors
parametric_contrasts = plot_parametric_contrasts(0); % arithmetic for parametric contrasts is done here
m = parametric_contrasts.m;
w = parametric_contrasts.w;
obtb = parametric_contrasts.obtb; 
tbob = parametric_contrasts.tbob; 
dsus = parametric_contrasts.dsus;
usds = parametric_contrasts.usds;

heat    = [m m w w m w];
wm      = [tbob obtb tbob obtb, zeros(1,120)]; % 2back->1, 1back->-1, noback->1
slope   = [dsus dsus usds usds]; % down slope->-1, up slope->1 

cov_names = {'heat', 'wm', 'slope',...
                    'heat_X_wm', 'heat_X_slope','wm_X_slope',...
                    'heat_X_wm_slope'}; % regressor
                
A = vertcat(heat,wm,slope)'; % 360*3
B = [1 0 0 1 1 0 1;...
     0 1 0 1 0 1 1;...
     0 0 1 0 1 1 1]; % 3*7;

covs = A*B; % 360*7: our final regressors are all possible nonzero linear combinations of the base regressors 

% plot each con before we repmat them
if do_plot
    for i = 1:numel(cov_names)
        figure;
        wave_tconplot(covs(:,i), cov_names{i});
    end
end

covs = repmat(covs, numel(all_subs), 1);



