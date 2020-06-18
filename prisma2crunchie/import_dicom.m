% Collect mapping
mapping = readtable('mapping.csv');

% Set constants
folder_string = 'dicq --exam=PRISMA_%d --folders | grep -P "Series:[\\s]+%d" | grep -oP "/[^\\s]+$"';
copy_string = 'scp -r %s %s';
destination = '/projects/crunchie/hipp/wavepain/';
% mapping_names = mapping.Properties.VariableNames; % change here to change folder structure
mapping_names = {'','',...
    'run001/mrt/fm_2TE','run001/mrt/fm_Diff','run001/mrt/',...
    'run002/mrt/fm_2TE','run002/mrt/fm_Diff','run002/mrt/',...
    'run000/mrt/'
    };

% map series to ids
% each column corresponds to one

% Loop through subjects
for i = 1:height(mapping)
    subject = mapping.subject(i);
    prisma = mapping.prisma_id(i);
    
    % mkdir for subject
    subdir = fullfile(destination, sprintf('sub%03d',subject));
    mkdir(subdir);            
    
    % Loop through series
    for j = 3:width(mapping)                
        series = mapping{i,j};
        
        if isnan(series)
            continue
        end
        
        % Construct directory string
        destination_folder = fullfile(subdir,mapping_names{j});
        if ~exist(destination_folder,'dir')
            mkdir(destination_folder);
        end
        
        % Retrieve folder                
        [out, folder] = unix(sprintf(folder_string, prisma, series));
        folder = strtrim(erase(folder, 'Database: prisma'));                      
        
        if out
            fprintf('something went wrong! Subject %d, Series %d\n', subject, series);
            continue
        end
        
        % Just for checking
        fprintf('SUBJECT %d ___%s___ is at %s\n', subject, mapping_names{j}, folder);
        
       out = unix(sprintf(copy_string, folder, destination_folder));
        if out
            fprintf('some error\nn');
        end
            
        % Copy file to revelations
        % scp -r folder sub06/antomical
        
        
        
    end 
end
