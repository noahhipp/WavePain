function nback_repeated_sequences
% adds regressor seen_before to nback that is 1 whenever a participant has seen a
% sequence before

% read data
FNAME = "E:\wavepain\data\fmri_sample\nback\all_nback.csv";
data = readtable(FNAME);


% Loop through
data.seen_before = nan(height(data),1);
for i = unique(data.ID)' % sub loop start
    sub_data    = data(data.ID == i, :);
    ob_seen     = []; % ob sequences seen
    tb_seen     = []; % tb sequences seen
    
    for j = unique(sub_data.trialNumber)' % trial loop start
        trial_data = sub_data(sub_data.trialNumber == j,:);
        
        for k = unique(trial_data.taskType)' % task loop start
            task_data = trial_data(trial_data.taskType == k,:);
            if k == 1 % 1back
                if ismember(task_data.seq(1), ob_seen) % if sub saw this sequence before
                    task_data.seen_before = ones(height(task_data),1);
                    fprintf('\nsub%03d trial%02d %d-back sequence %02d: seen before',...
                        i,j,k, task_data.seq(1));
                else
                    ob_seen = vertcat(ob_seen, task_data.seq(1)); % if sub did not see it before
                    task_data.seen_before = zeros(height(task_data),1);
                end
            elseif k == 2 % 2back
                if ismember(task_data.seq(1), tb_seen) % if sub saw this sequence before
                    task_data.seen_before = ones(height(task_data),1);
                    fprintf('\nsub%03d trial%02d %d-back sequence %02d: seen before',...
                        i,j,k, task_data.seq(1));
                else
                    tb_seen = vertcat(tb_seen, task_data.seq(1)); % if sub did not see it before
                    task_data.seen_before = zeros(height(task_data),1);
                end
            end
            
            % Put task data back
            trial_data(trial_data.taskType == k,:) = task_data;
        end % task loop end
        % Put trial data back
        sub_data(sub_data.trialNumber == j,:) = trial_data;
    end % trial loop end
    
    % Put sub data back
    data(data.ID == i, :) = sub_data;
end % sub loop end

writetable(data, FNAME);




