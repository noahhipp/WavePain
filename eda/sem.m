function s = sem(v)
% takes vector and returns standard error of the mean
% sem = std(v)/sqrt(numel(v))


s = nanstd(v)/sqrt(numel(v));