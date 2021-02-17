function [line, legend_labels] = waveplot(y, condition, varargin)
% Takes time series and wavepain condition and plots it colored according
% to tasks to current axes. Condition must be specified with capital letter first.


% optional arguments:
%           - varargin{1} specifies error must be of the same length as y.
%           defaults to zeros(numel(y), 1);           
%           - varargin{2} specifies number of samples taken into account for
%           calculation of bins. This stems from first FIR being 120s long
%           but wave calulation only being applied to 120s.
%           Defaults to numel(y).

index_test = 0;

% E.g. waveplot(1:110, ones(1,110), 'M21')
n_wave      = numel(y);
n           = n_wave;
error       = zeros(n, 1);
if nargin > 2
    error  =varargin{1};
    n_wave  =varargin{2}; 
end

% No task, 1back, 2back
c = wave_load_colors;

colors = [0 0 0;... % no task
          c(2,:);... % 1back         
          c(1,:);... % 2back
          0 1 1;... % 2back-1back   
          1 1 0;...   % 1back-2back
          c(5,:)];
      
    
[~,ticks] = getBinBarPos(n_wave);

x               = linspace(1,119,n); % each bin is 
xx              = 1:n; % indices of x, used for constructing index table
ind             = table;
ind.pre_task    = xx <= ticks(2) + 1;
ind.task1       = xx >= ticks(2) & xx <= ticks(4) +1 ;
ind.task2       = xx >= ticks(4) & xx <= ticks(6)+1;
ind.post_task   = xx >= ticks(6);

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
        legend_labels = {'FIR (no task)', 'FIR (FIR (2back))', 'FIR (FIR (1back))'};
    case 'M12'
        cs = [1, 2, 3, 1];
        legend_labels = {'FIR (no task)', 'FIR (1back)', 'FIR (2back)'};
    case 'M21vsM12'
        cs = [1, 4, 5, 1];
        legend_labels = {'FIR (no task)', 'FIR (2back)-FIR (1back)', 'FIR (1back)-FIR (2back)'};
    case 'W21'
        cs = [1, 3, 2, 1];
        legend_labels = {'FIR (no task)', 'FIR (2back)', 'FIR (1back)'};
    case 'W12'
        cs = [1, 2, 3, 1];        
        legend_labels = {'FIR (no task)', 'FIR (2back)', 'FIR (1back)'};
    case 'W21vsW12'
        cs = [1, 4, 5, 1];
        legend_labels = {'FIR (no task)', 'FIR (2back)-FIR (1back)', 'FIR (1back)-FIR (2back)'};
    case 'Monline'
        cs = ones(1,4).*6;
        legend_labels = {'FIR (no task)'};
    case 'Wonline'
        cs = ones(1,4).*6;
        legend_labels = {'FIR (no task)'};
end

% Plot lines and shades
for i = 1:4    
    [line(i), shade(i)] = boundedline(x(ind{:,i}), y(ind{:,i}), error(ind{:,i}),'k-*', 'cmap', colors(cs(i),:), 'alpha');
    line(i).LineWidth = 4;            
end    