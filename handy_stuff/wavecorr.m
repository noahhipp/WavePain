function [opti_lag, line] = wavecorr(x,y,varargin)
% Wrapper around xcorr. Do cross correlation of x and y and plot it to current axes.
% Optional arguments:
%               - f: sampling frequency in hz of x and y to correctly display max
%               lag. Defaults to 1 [hz].
%               - max_shift: how far to compute the cross correlation.
%               Defaults to 120s ~1 Stimulus
f = 1;
max_shift = 120;
if nargin > 2
    f = varargin{1};
end

if nargin > 3
    max_shift = varargin{2};
end

% do it
[c,lag_samples]     = xcorr(x,y,f*max_shift);
 lag_s               = lag_samples ./ f; % convert lags from samples to seconds for more convenient plotting

% plot it
% figure('Name','wavecorr', 'Color', [1 1 1]);
line = plot(lag_s,c); 
ylabel('Correlation'); xlabel('Lag (seconds)');
vline(lag_s(find(c==max(c))),'k-', sprintf('Max corr at: %.1fs',lag_s(c == max(c))));
opti_lag = lag_s(c == max(c));