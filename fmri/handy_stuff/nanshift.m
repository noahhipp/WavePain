function vout = nanshift(vin,s)
% like circshift, but padds with nans instead of shifted values

% Shift data
vout = circshift(vin,s);

% Change leaked values to nans
if s > 0 % we shifted forward so
    vout(1:s) = nan;
elseif s < 0 % we shifted backwards so
    vout(end+s+1:end) = nan; % s is negative so we have to add it
end
% s = 0 handles itself


