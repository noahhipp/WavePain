function host = wave_ghost2(varargin)
% next version of wave_ghost to collect directories based on machine

% Listen for sample
sample = '';
if nargin
    if ismember(varargin{1}, ['behav','fmri', 'fMRI'])
        sample = varargin{1}; 
    else
        error("Provide correct argument ['','behav','fMRI']")
    end
end

% Get machine
hostname       =  char(getHostName(java.net.InetAddress.getLocalHost));
jdisp(sprintf('You are operating on %s. \nValidating... 2 1 ', hostname)); 

% Set machine specific variables
switch hostname
    case 'aranyani'
        jdisp('     --> valid machine! Enjoy the rest of your day! :)')
        
        dir         = strcat('E:\wavepain\data\',sample,'_sample\');
        results     = 'D:\OneDrive - Universität Hamburg\projects\wavepain\results\';
        
        n_proc      = 10; % N matlab instances used for parralel computing
        
end

% Set output struct
host.name       = hostname;
host.dir        = dir;
host.results    = results; 
host.n_proc     = n_proc;
