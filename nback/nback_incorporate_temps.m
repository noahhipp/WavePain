function nback = nback_incorporate_temps
% add heat and temperature column to nback data

% Settings
SAMPLE   = 'fmri';

% Housekeeping
host        = wave_ghost2(SAMPLE);
DATA_DIR                    = host.dir;
NBACK_DIR                   = fullfile(DATA_DIR, 'nback');
EDA_DIR                     = fullfile(DATA_DIR, 'eda');
RAW_TEMPLATE                = 'all_nback.csv';
TEMP_TEMPLATE               = 'temps.csv';
EDA_TEMPLATE                = 'all_eda_clean_downsampled10.csv';

RAW_FILE                    = fullfile(NBACK_DIR, RAW_TEMPLATE);
TEMP_FILE                   = fullfile(NBACK_DIR, TEMP_TEMPLATE);
EDA_FILE                    = fullfile(EDA_DIR, EDA_TEMPLATE);

nback = readtable(RAW_FILE);
temps = readtable(TEMP_FILE);
eda   = readtable(EDA_FILE);

% Discard irrelevant eda cols
eda = eda(:,{'ID','trial','condition','time','heat'});


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
    
    if ismember(sub, [7 15 18 19 20]) % corrupted stamps or no SCL --> add later manually
        continue
    end
    
    trials = unique(nback.trialNumber(nback.ID == sub));
    for j = 1:numel(trials)
        trial = trials(j);
        fprintf("sub%03d trial%02d...",sub, trial);
        
        trial_table = nback(nback.trialNumber == trial & nback.ID == sub,:);
        trial_table_eda = eda(eda.trial == trial & eda.ID == sub,:);
       
        
        % Now for each row find the heat value with the closest stamp
        for k = 1:height(trial_table)
            target = trial_table.stamp(k);
            
            % Find index of closest value
            [c, index] = min(abs(trial_table_eda.time-target));
            
            % Write heat from that index to nback table
            try
                trial_table.heat(k) = trial_table_eda.heat(index);
            catch
                fprintf("oooooops...");
            end
        end
        
        % Put back trial table
         nback(nback.trialNumber == trial & nback.ID == sub,:) = trial_table;
         fprintf("done.\n");
        
    end
end

% Extract heat segments for conditions from the first microblock of sub005
stamps = nan(42,4);
stamps(:,1) = nback.heat(nback.ID == 5 & nback.trialNumber < 7 & nback.condition == 1);
stamps(:,2) = nback.heat(nback.ID == 5 & nback.trialNumber < 7 & nback.condition == 2);
stamps(:,3) = nback.heat(nback.ID == 5 & nback.trialNumber < 7 & nback.condition == 3);
stamps(:,4) = nback.heat(nback.ID == 5 & nback.trialNumber < 7 & nback.condition == 4);

if size(stamps,1) ~= 42
    error('bad stamps');
end

% Now fix the conditions
for i = 1:size(stamps,2)
    % How many we need to replace
    idx = isnan(nback.heat) & (nback.condition == i);
    n = sum(idx) / 42;
    
    nback.heat(idx) = repmat(stamps(:,i),[n 1]);
end

% Populate temp column
nback.temp = nback.vas30 + nback.amplitude .* nback.heat;
    
    



