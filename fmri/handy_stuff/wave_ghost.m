function [base_dir, n_proc, plot_dir, eda_dir, cloud_dir] = wave_ghost(varargin)
% Collects hostname and returns wavepain data base dir and number of
% MATLBAB instances to use for heavy computing
 
hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
plot_dir = 'sorry, this does not work on this machine';
eda_dir = 'sorry, this does not work on this machine';
cloud_dir = 'sorry, this does not work on this machine';
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
        if ~nargin
            eda_dir           = 'C:\Users\hipp\projects\WavePain\data\fmri_sample\eda';
        elseif strcmp(varargin{1}, 'behav')
            eda_dir           = 'C:\Users\hipp\projects\WavePain\data\behav_sample\eda\';
        end             
        
        cloud_dir         = 'C:\Users\hipp\OneDrive - Universität Hamburg\projects\wavepain\results';
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';        
        n_proc            = 8;
        plot_dir          = '/home/hipp/projects/WavePain/code/matlab/fmri/03_firstlevel/firstlevel_canonical_pmod/';
    case 'aranyani'
        base_dir          = 'E:\wavepain\data\fmri_sample\fmri';
        n_proc            = 8;
        plot_dir          = 'C:\projects\wavepain\code\fmri\03_firstlevel\firstlevel_canonical_pmod\';        
        if ~nargin
            eda_dir           = 'E:wavepain\data\fmri_sample\eda\';
        elseif strcmp(varargin{1}, 'behav')
            eda_dir           = 'E:wavepain\data\behav_sample\eda\';
        end            
    otherwise        
        error('Only hosts noahs isn laptop, revelations or aranyani accepted');
end