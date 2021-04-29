function [c, lags] = neugecorr(x,y,varargin)
% Calculate true cross correlation.
% Mnemonic to remember what negative lag means:
% x is never shifted. y is shifted in relation to x.
% For negative lag y is shifted backwards. maxlag > 0 means y is lagging
% behind so we have to shift it forward to maximize correlation. maxlag < 0 means y is
% ahead so we have to shift it backwards to maximize correlation.

if numel(x) ~= numel(y)
    error('X and Y have to be the of the same length\n');
end

if nargin > 2
    max_lag = varargin{1};
else
    max_lag = numel(x)-2; % you at least need two values, 0--> nan, 1-->always 1
end


i = 1;
c       = nan(max_lag*2+1,1);
lags    = -max_lag:max_lag;

for lag = lags
    % negative lag
    if lag < 0
        C = corrcoef(x(1:end+lag),y(-lag+1:end));
   
    % positive lag
    elseif lag > 0
        C = corrcoef(x(lag+1:end),y(1:end-lag));
   
    % no lag
    else
        C = corrcoef(x,y);
    end 
   
    % append top right value of correlation matrix to correlation sequence   
    c(i) = C(1,2);
    i = i+1;
end

if sum(isnan(c)) > 0
    error('Something went wrong\n');
end