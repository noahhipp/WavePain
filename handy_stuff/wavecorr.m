function opti_lag = wavecorr(x,y,varargin)
% Wrapper around xcorr. Do cross correlation of x and y and plot it.
% Optional arguments:
%               - f: sampling frequency in hz of x and y to correctly display max
%               lag. Defaults to 1 [hz].

if nargin > 2
    f = varargin{1};
else
    f = 1;
end

% do it
[c,lag_samples]     = xcorr(x,y,f*120);
lag_s               = lag_samples ./ f; % convert lags from samples to seconds for more convenient plotting

% plot it
figure('Name','wavecorr', 'Color', [1 1 1]);
plot(lag_s,c); 
ylabel('Correlation'); xlabel('Lag (seconds)');
vline(lag_s(find(c==max(c))),'k-', sprintf('Max corr at: %.1fs',lag_s(c == max(c))));
opti_lag = lag_s(c == max(c));