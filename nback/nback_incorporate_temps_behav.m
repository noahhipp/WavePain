function nback = nback_incorporate_temps_behav
% add heat and temperature column to nback data

% Settings
SAMPLE   = 'behav';

% Housekeeping
host        = wave_ghost2(SAMPLE);
DATA_DIR                    = host.dir;
NBACK_DIR                   = fullfile(DATA_DIR, 'nback');
EDA_DIR                     = fullfile(DATA_DIR, 'eda');
RAW_TEMPLATE                = 'all_nback.csv';
TEMP_TEMPLATE               = 'temps.csv';
EDA_TEMPLATE                = 'all_eda_behav_downsampled10.csv';

RAW_FILE                    = fullfile(NBACK_DIR, RAW_TEMPLATE);
TEMP_FILE                   = fullfile(NBACK_DIR, TEMP_TEMPLATE);
EDA_FILE                    = fullfile(EDA_DIR, EDA_TEMPLATE);

FMRI_NBACK                  = "E:\wavepain\data\fmri_sample\nback\all_nback.csv"; % to copy segments from

fnb = readtable(FMRI_NBACK);
nback = readtable(RAW_FILE);
temps = readtable(TEMP_FILE);
eda   = readtable(EDA_FILE);

% Collect wave segments from fmri nback
m_heat = fnb.heat(fnb.ID == 5 & fnb.trialNumber == 3);
w_heat = fnb.heat(fnb.ID == 5 & fnb.trialNumber == 4);


% Preallocate cols
nancol = nan(height(nback),1);
nback.heat = nancol; % -1 to 1
nback.temp = nancol; % VAS0 to VAS60
nback.amplitude = nancol;
nback.vas30 = nancol;

% Loop throuhg subs
subs = unique(nback.ID);
for i = 1:numel(subs)
    sub = subs(i);
    
    % Write amplitude and vas30
    nback.amplitude(nback.ID==sub) = temps.amplitude(temps.id == sub);
    nback.vas30(nback.ID==sub) = temps.vas30(temps.id == sub);    
    
    trials = unique(nback.trialNumber(nback.ID == sub));
    for j = 1:numel(trials)
        trial = trials(j);
        fprintf("sub%03d trial%02d...",sub, trial);
        
        trial_table = nback(nback.trialNumber == trial & nback.ID == sub,:);
%         trial_table_eda = eda(eda.trial == trial & eda.ID == sub,:);
       
        
        if ismember(mean(trial_table.condition), [1 2]) % M
            trial_table.heat = m_heat; fprintf("M...");
        elseif ismember(mean(trial_table.condition), [3 4]) % W
            trial_table.heat = w_heat; fprintf("W...");
        else
            error('somethings wrong with the conditions');
        end
        
        % Put back trial table
         nback(nback.trialNumber == trial & nback.ID == sub,:) = trial_table;
         fprintf("done.\n");
        
    end
end

% Populate temp column
nback.temp = nback.vas30 + nback.amplitude .* nback.heat;
    
    



