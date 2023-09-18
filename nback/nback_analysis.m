function nback_analysis
% Settings
SAMPLE   = 'fmri';

% Housekeeping
host        = wave_ghost2(SAMPLE);
DATA_DIR                    = host.dir;
NBACK_DIR                   = fullfile(DATA_DIR, 'nback');
RAW_TEMPLATE                = 'all_nback.csv';
SLOPE_COLLAPSED_TEMPLATE    = 'all_nback_slope_collapsed.csv';
SLOPE_COLLAPSED_COLLAPSED_TEMPLATE = 'all_nback_slope_collapsed_collapsed.csv'; % 4 values/sub: ob | tb X up | down
SLOPE_COLLAPSED_COLLAPSED_C_TEMPLATE = 'all_nback_slope_collapsed_collapsed_c.csv'; % 2 values/sub: ob tb

RAW_FILE                    = fullfile(NBACK_DIR, RAW_TEMPLATE);
SLOPE_COLLAPSED_FILE        = fullfile(NBACK_DIR, SLOPE_COLLAPSED_TEMPLATE);
SLOPE_COLLAPSED_COLLAPSED_FILE = fullfile(NBACK_DIR, SLOPE_COLLAPSED_COLLAPSED_TEMPLATE);
SLOPE_COLLAPSED_COLLAPSED_C_FILE = fullfile(NBACK_DIR, SLOPE_COLLAPSED_COLLAPSED_C_TEMPLATE);

% Check if files are available
if ~exist(RAW_FILE, 'file') % then we cannot do anything
    fprintf('Source file (%s) is missing. Aborting.\n', RAW_FILE)
    return
end

% =========================================================================
% COLLAPSE SLOPES
% =========================================================================
if ~exist(SLOPE_COLLAPSED_FILE, 'file')
    fprintf('Collapsed file (%s) is missing. Initalizing collapse.\n', SLOPE_COLLAPSED_FILE)
    
    % Collapsing slopes so that one row corresponds to one slope (or one
    % round of nback or 21 letters)
    
    % Get data
    raw_data = readtable(RAW_FILE);
    
    % Preallocate new data
    slope_collapsed_data = [];
    
    % Loop through raw_data    
    for i = unique(raw_data.ID)' % subject loop start
        fprintf('\nsub%03d',i);
        
        for j = unique(raw_data.trialNumber(raw_data.ID == i))' % trial loop start
            fprintf('\n    trial %02d',j)
            
            for k = unique(raw_data.taskType(raw_data.ID == i...
                    & raw_data.trialNumber == j))' % sequence loop start
                fprintf(' %d', k);
                
                task_data = raw_data(raw_data.ID == i...
                    & raw_data.trialNumber == j...
                    & raw_data.taskType == k,:);
                
                % Transfer to output (by hand for increased comprehensability)
                new_row             = table;
                
                % Position of sequence
                new_row.ID          = task_data.ID(1);
                new_row.session     = task_data.session(1);
                new_row.microblock  = task_data.microblock(1);
                new_row.trial       = task_data.trialNumber(1);
                new_row.condition   = task_data.condition(1);
%                 new_row.sequence    = task_data.seq(1);
                new_row.shape       = task_data.wave(1);
                new_row.slope       = task_data.slope(1);
                new_row.task        = task_data.taskType(1);
%                 new_row.seen_before = task_data.seen_before(1);
                
                % Performance of sequence
                new_row.signals    = sum(task_data.target);
                new_row.noises     = sum(task_data.target==0);
                new_row.hits        = sum(task_data.response==task_data.target & task_data.target==1);
                new_row.false_alarms= sum(task_data.false_alarm);
                new_row.hr          = new_row.hits / new_row.signals;
                new_row.far         = new_row.false_alarms / new_row.noises;
                
                % to avoid problems with calculation for d prime with
                % extreme values of p a loglinear approach as proposed by
                % Hautus 1995 is employed
                new_row.hr_ll       = (new_row.hits + 0.5) / (new_row.signals +1);
                new_row.far_ll      = (new_row.false_alarms + 0.5) / (new_row.noises +1);
                new_row.d           = dprime(new_row.hr_ll, new_row.far_ll);                             
                
                % Reaction times
                new_row.rt          = nanmean(task_data.rt);
                
                % Append row to output
                slope_collapsed_data = vertcat(slope_collapsed_data,...
                    new_row);
            end % sequence loop end
        end % trial loop end
    end % subject loop end
   
    % Save file
    writetable(slope_collapsed_data, SLOPE_COLLAPSED_FILE);
    fprintf('\nwrote %s', SLOPE_COLLAPSED_FILE);
end

% % Plot performance over time
% data = readtable(SLOPE_COLLAPSED_FILE);
% figure; 
% for i = unique(data.ID)'
%     sub_data = data(data.ID == i,:);    
%     scatter(sub_data.trial, sub_data.d);
%     hold on;
% end

% =========================================================================
% Collapse trials --> 4 values for each sub
% =========================================================================
if ~exist(SLOPE_COLLAPSED_COLLAPSED_FILE, 'file')   
    fprintf('Collapsed file (%s) is missing. Initalizing collapse.\n', SLOPE_COLLAPSED_COLLAPSED_FILE)
    
    data_in = readtable(SLOPE_COLLAPSED_FILE);
    
    % Convert variables to correct types
    nancol          = nan(height(data_in),1);
    shape2   = nancol;
    slope2  = nancol;
    
    shape2(strcmp(data_in.shape, 'M')) = 1;
    shape2(strcmp(data_in.shape, 'W')) = 2;
    data_in.shape = shape2;
    
    slope2(strcmp(data_in.slope, 'down')) = -1;
    slope2(strcmp(data_in.slope, 'up')) = 1;
    data_in.slope = slope2;    
    
    % Collapse everything but ID, and slope and task
    grouping_variables = {'ID', 'task', 'slope'};
    mean_data = varfun(@mean, data_in, 'GroupingVariables', grouping_variables);
    sem_data = varfun(@sem, data_in, 'GroupingVariables', grouping_variables);
    fprintf('Height of original DATA: %10d\n', height(data_in));
    fprintf('Height of mean DATA: %10d\n', height(mean_data));
    fprintf('Reduction factor: %f\n', height(data_in) / height(mean_data));
    
    % Get rid of mean_ prefix
    for i = 1:width(mean_data)
        mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'mean_','');
    end
    
    % Transfer interesting sem columns to mean DATA
    idx = strcmp(sem_data.Properties.VariableNames, 'd');
    cols_to_transfer = sem_data.Properties.VariableNames(idx);
    for i = 1:numel(cols_to_transfer)
        mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});
    end            
    
    % Write output
    data_out = mean_data;
    writetable(data_out, SLOPE_COLLAPSED_COLLAPSED_FILE);    
end

% =========================================================================
% Collapse up/down slopes --> 2 values for each sub
% =========================================================================
if ~exist(SLOPE_COLLAPSED_COLLAPSED_C_FILE, 'file')   
    fprintf('Collapsed file (%s) is missing. Initalizing collapse.\n', SLOPE_COLLAPSED_COLLAPSED_C_FILE)
    
    data_in = readtable(SLOPE_COLLAPSED_FILE);
    
    % Convert variables to correct types
    nancol          = nan(height(data_in),1);
    shape2   = nancol;    
    
    shape2(strcmp(data_in.shape, 'M')) = 1;
    shape2(strcmp(data_in.shape, 'W')) = 2;
    data_in.shape = shape2;       
    
    % Get rid of slope
    data_in.slope = [];
    
    % Collapse everything but ID, and slope and task
    grouping_variables = {'ID', 'task'};
    mean_data = varfun(@mean, data_in, 'GroupingVariables', grouping_variables);
    sem_data = varfun(@sem, data_in, 'GroupingVariables', grouping_variables);
    fprintf('Height of original DATA: %10d\n', height(data_in));
    fprintf('Height of mean DATA: %10d\n', height(mean_data));
    fprintf('Reduction factor: %f\n', height(data_in) / height(mean_data));
    
    % Get rid of mean_ prefix
    for i = 1:width(mean_data)
        mean_data.Properties.VariableNames{i} = strrep(mean_data.Properties.VariableNames{i}, 'mean_','');
    end
    
    % Transfer interesting sem columns to mean DATA
    idx = strcmp(sem_data.Properties.VariableNames, 'd');
    cols_to_transfer = sem_data.Properties.VariableNames(idx);
    for i = 1:numel(cols_to_transfer)
        mean_data(:,cols_to_transfer{i}) = sem_data(:,cols_to_transfer{i});
    end            
    
    % Write output
    data_out = mean_data;
    writetable(data_out, SLOPE_COLLAPSED_COLLAPSED_C_FILE);    
end


% =========================================================================
% Calculate lme for d'
% =========================================================================
data = readtable(SLOPE_COLLAPSED_FILE);

% Cast IVs to categorical
data.slope_c1 = categorical(data.slope);
data.task_c1 = categorical(data.task, [1, 2], {'1back', '2back'});

lme_form = 'd ~ slope_c1*task_c1 + (1|ID)';
lme = fitlme(data,lme_form)


% =========================================================================
% Calculate lme for rt
% =========================================================================
data = readtable(RAW_FILE);

% Cast IVs to categorical
data.slope_c1 = categorical(data.slope);
data.task_c1 = categorical(data.taskType, [1 2], {'1back', '2back'});

lme_form = 'rt ~slope_c1*task_c1 + (1|ID)';
lme = fitlme(data(data.hit == 1,:), lme_form) % for hit trials
lme = fitlme(data(data.false_alarm == 1,:), lme_form) % for false alarm trials


% =========================================================================
% Plot d'
% =========================================================================
data = readtable(SLOPE_COLLAPSED_COLLAPSED_FILE);

cb = wave_load_colors;

figure('Color','white','Name','make it rain d');
titles = ...
    {'Task performance on up slopes', 'Task performance on down slopes'};

for i = 1:2    
    subplot(2,1,i);
    if i == 1
        d{1} = data.d(data.task == 2 & data.slope==1);
        d{2} = data.d(data.task == 1 & data.slope==1);
    else
        d{1} = data.d(data.task == 2 & data.slope == -1);
        d{2} = data.d(data.task == 1 & data.slope == -1);
    end
    
    % driver code    
    h1 = raincloud_plot(d{1}, 'box_on', 1, 'color', cb(1,:), 'alpha', 0.5,...
        'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .35,...
        'box_col_match', 1);
    h2 = raincloud_plot(d{2}, 'box_on', 1, 'color', cb(2,:), 'alpha', 0.5,...
        'box_dodge', 1, 'box_dodge_amount', .55, 'dot_dodge_amount', .75,...
        'box_col_match', 1);
    l =legend([h1{1} h2{1}], {'2back', '1back'}, 'Location','northwest');
    l.Title.String = 'Task:';
    title(['N=25: ', titles{i}], 'FontWeight','bold');
    box off
    
    % customize it
    % xlim([0 100]);
    xlabel("task performance (d')",'FontWeight', 'bold');
    ax = gca;
    ax.YAxis.TickValues = [];
    ylim([-.8, 3.5]);    
    xlim([0 4]);
end

% =========================================================================
% Plot reaction times
% =========================================================================
data = readtable(RAW_FILE);
cb = wave_load_colors;

figure('Color','white','Name','make it rain d');
titles = ...
    {'Reaction times on up slopes', 'Reaction times on down slopes'};

for i = 1:2    
    subplot(2,1,i);
    if i == 1
        d{1} = data.rt(data.taskType == 2 & strcmp(data.slope, 'up'));
        d{2} = data.rt(data.taskType == 1 & strcmp(data.slope, 'up'));
    else
        d{1} = data.rt(data.taskType == 2 & strcmp(data.slope, 'down'));
        d{2} = data.rt(data.taskType == 1 & strcmp(data.slope, 'down'));
    end
    
    % driver code    
    h1 = raincloud_plot(d{1}, 'box_on', 1, 'color', cb(1,:), 'alpha', 0.5,...
        'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .35,...
        'box_col_match', 1);
    h2 = raincloud_plot(d{2}, 'box_on', 1, 'color', cb(2,:), 'alpha', 0.5,...
        'box_dodge', 1, 'box_dodge_amount', .55, 'dot_dodge_amount', .75,...
        'box_col_match', 1);
    l =legend([h1{1} h2{1}], {'2back', '1back'}, 'Location','northwest');
    l.Title.String = 'Task:';
    title(['N=25: ', titles{i}], 'FontWeight','bold');
    box off
    
    % customize it
    % xlim([0 100]);
    xlabel("reaction time (s)",'FontWeight', 'bold');
    ax = gca;
    ax.YAxis.TickValues = [];
    ylim([-1.5, 3.5]);    
end

% =========================================================================
% check if seen_before has an effect on d'
% =========================================================================
% data = readtable(SLOPE_COLLAPSED_FILE);

%data.seen_before_c1 = categorical(data.seen_before);
data.task_c1 = categorical(data.task, [1 2], {'1back', '2back'});

% lme_form = 'd ~ task_c1 * seen_before_c1 + (1|ID)';
% fitlme(data, lme_form)

% =========================================================================
% check if seen_before has an effect on rt
% =========================================================================
% data = readtable(RAW_FILE);

% data.seen_before_c1 = categorical(data.seen_before);
% data.task_c1 = categorical(data.taskType, [1 2], {'1back', '2back'});
% lme_form = 'rt ~ task_c1 * seen_before_c1 + (1|ID)';
% fitlme(data, lme_form)


% =========================
% dprime(hr,far)
% =========================
% calculate d_prime as specified in Stanislaw and Todorov, 1999
function d = dprime(hr, far)
d = norminv(hr) - norminv(far);

% =========================
% Sem function
% ========================
function out = sem(in)
out = nanstd(in)./sum(~isnan(in));






    
    


