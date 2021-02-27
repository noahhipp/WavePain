function [base_dir, n_proc, plot_dir] = wave_ghost
% Collects hostname and returns wavepain data base dir and number of
% MATLBAB instances to use for heavy computing
 
hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
plot_dir = 'sorry, this does not work on this machine';
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';        
        n_proc            = 8;
        plot_dir          = '/home/hipp/projects/WavePain/code/matlab/fmri/03_firstlevel/firstlevel_canonical_pmod/';
    case 'aranyani'
        base_dir          = 'E:\wavepain\data\fmri_sample\fmri';
        n_proc            = 8;
        plot_dir          = 'C:\projects\wavepain\code\fmri\03_firstlevel\firstlevel_canonical_pmod\';
    otherwise        
        error('Only hosts noahs isn laptop, revelations or aranyani accepted');
end