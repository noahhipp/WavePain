function [line, legend_labels] = waveplot2(y, condition,varargin)
% Takes time series and wavepain condition and plots it colored according
% to tasks to current axes. Condition must be specified with capital letter first.


% optional arguments:
%           - varargin{1} specifies error must be of the same length as y.
%           defaults to zeros(numel(y), 1);           
%           - varargin{2} specifies number of samples taken into account for
%           calculation of bins. This stems from first FIR being 120s long
%           but wave calulation only being applied to 120s.
%           Defaults to numel(y).

n = numel(y);

% only want 2 optional inputs at most
numvarargs = length(varargin);
if numvarargs > 3
    error('waveplot2 requires at most 2 optional inputs');
end

% set defaults for optional inputs
optargs = {zeros(n,1) n, 0};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
optargs(1:numvarargs) = varargin;

% Place optional args in memorable variable names
[sem, n_wave, lag] = optargs{:};

index_test = 0;


% No task, 1back, 2back
colors = [0 0 0;... % no task
          0 0 1;... % 1back         
          1 0 0;... % 2back
          0 1 1;... % 2back-1back   
          1 1 0];   % 1back-2back
    
[~,ticks_samples] = getBinBarPos(n_wave); 


f                       = n_wave / 110; % sampling frequency of y
x_seconds               = linspace(0,110+((n-n_wave) / f),n); % seconds
x_seconds = x_seconds + lag;
x_samples               = x_seconds * f; 


ind             = table;
ind.pre_task    = x_samples < ticks_samples(2);
ind.task1       = x_samples >= ticks_samples(2) & x_samples < ticks_samples(4);
ind.task2       = x_samples >= ticks_samples(4) & x_samples < ticks_samples(6);
ind.post_task   = x_samples >= ticks_samples(6);

% Extend at the end to prevent holes in graph
ind.pre_task(find(ind.pre_task,1,'last')+1) = 1;
ind.task1(find(ind.task1,1,'last')+1) = 1;
ind.task2(find(ind.task2,1,'last')+1) = 1;
ind.task2(find(ind.task2,1,'last')+1) = 1;
ind.post_task(find(ind.post_task,1,'first')) = 0;


if index_test
    figure;
    for i = 1:4        
        plot(ind{:,i});
        hold on;
        ylim([-1.5,1.5]);
    end
end
     


% Specify color sequence according to condition
switch condition
    case 'M21'
        cs = [1, 3, 2, 1];
        legend_labels = {'no task', '2back', '1back'};
    case 'M12'
        cs = [1, 2, 3, 1];
        legend_labels = {'no task', '1back', '2back'};
    case 'M21vsM12'
        cs = [1, 4, 5, 1];
        legend_labels = {'no task', '2back-1back', '1back-2back'};
    case 'W21'
        cs = [1, 3, 2, 1];
        legend_labels = {'no task', '2back', '1back'};
    case 'W12'
        cs = [1, 2, 3, 1];        
        legend_labels = {'no task', '2back', '1back'};
    case 'W21vsW12'
        cs = [1, 4, 5, 1];
        legend_labels = {'no task', '2back-1back', '1back-2back'};
    case 'Monline'
        cs = ones(1,4);
        legend_labels = {'no task'};
    case 'Wonline'
        cs = ones(1,4);
        legend_labels = {'no task'};
end

% Plot lines and shades
for i = 1:4    
    [line(i), shade(i)] = boundedline(x_seconds(ind{:,i}), y(ind{:,i}), sem(ind{:,i}),'k-*', 'cmap', colors(cs(i),:), 'alpha');
    line(i).LineWidth = 4;            
end  
