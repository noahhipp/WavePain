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
do_model = 1;

skern = 6;
anadirname = 'mreg';
addon = 'anova';
old_ananame = 'fir'; % we need this to import files
file_filter = 's6w_t1con';
n_cons = nan(1,numel(all_subs));

out_dir             = [base_dir 'second_Level' filesep anadirname '_' addon '_' num2str(skern)];


% Get con images from first level
for i = 1:numel(all_subs)
    sname = sprintf('sub%03d', all_subs(i));
    fprintf('doing %s...\n', sname);
    sdir = fullfile(base_dir, sname, old_ananame);
    sfiles = cellstr(spm_select('FPList',sdir,file_filter)); % use FPList for full path    
    
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
    n_cons(1,i) = numel(sfiles); % to plot files per subject later 
end

% Check if all have 360 cons
figure();
bar(all_subs, n_cons);
title('CONS PER SUBJECT', 'FontWeight', 'bold', 'FontSize', 24);
ylabel('Number of cons'); xlabel('Subject');
ylim([0 400]); grid on;
