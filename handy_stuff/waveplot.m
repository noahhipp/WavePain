function line = waveplot(y, condition, varargin)
% Takes time series and wavepain condition and plots it accordingly
% to current axes. Condition must be specified with capital letter first.


% optional arguments:
%           - varargin{1} specifies error must be of the same length as y.
%           defaults to zeros(numel(y), 1);           
%           - varargin{2} specifies number of samples taken into account for wave
%           calculation otherwise defaults to numel(y)

% E.g. waveplot(1:110, ones(1,110), 'M21')
n_wave      = numel(y);
n           = n_wave;
error       = zeros(n, 1);
if nargin > 2
    error  =varargin{1};
    n_wave  =varargin{2}; 
end

% No task, 1back, 2back
colors = [0 0 0;...
          0 0 1;...
          1 0 0]; % replace with fancy seaborn colors later
    
[~,ticks] = getBinBarPos(n_wave);

x               = linspace(0,120,n); % used for plotting
xx              = 1:n; % indices of x, used for constructing index table
ind             = table;
ind.pre_task    = xx < ticks(2);
ind.task1       = xx >= ticks(2) & xx < ticks(4);
ind.task2       = xx >= ticks(4) & xx < ticks(6);
ind.post_task   = xx >= ticks(6);

% Specify color sequence according to condition
switch condition
    case 'M21'
        cs = [1, 3, 2, 1];
        legend_labels = {'no task', '2back', '1back'};
    case 'M12'
        cs = [1, 2, 3, 1];
        legend_labels = {'no task', '1back', '2back'};
    case 'W21'
        cs = [1, 3, 2, 1];
        legend_labels = {'no task', '2back', '1back'};
    case 'W12'
        cs = [1, 2, 3, 1];        
        legend_labels = ['no task', '2back', '1back'];
    case 'Monline'
        cs = ones(1,4);
        legend_labels = {'no task'};
    case 'Wonline'
        cs = ones(1,4);
        legend_labels = {'no task'};
end

% Plot lines and shades
for i = 1:4    
    [line(i), shade(i)] = boundedline(x(ind{:,i}), y(ind{:,i}), error(ind{:,i}), 'cmap', colors(cs(i),:), 'alpha');
    line(i).LineWidth = 4;            
end

% Customize graph
legend(line(1:numel(legend_labels)), legend_labels, 'FontSize', 14);






    


