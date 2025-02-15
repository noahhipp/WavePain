function [M, M2] = wave_load_designmatrix(varargin)

% Loads standard wavepain designmatrix from binary file
M       = [];
fid     = fopen('designmatrix.bin', 'r');
temp    = fread(fid,'double');

% Check if M is the same size
if numel(temp) ~= 7*360
    warning('design matrix corrupt');
    return
end

% If its good reshape it and return it
M       = reshape(temp, 360, []);

% Construct M2
heat = M(:,1);
wm1 = M(:,2) == -1;
wm2 = M(:,2) == 1;
slope = M(:,3);

% diff heat
if nargin == 1 || strcmp(varargin{1}, 'diffheat')
    wm = M(:,2);
%     slope = zscore([0; diff(heat)]);
    slope = [0; diff(heat)];
    slope = slope./max(slope);
    M = [heat wm slope heat.*wm heat.*slope wm.*slope heat.*wm.*slope];
end

% wm1 = wm1 - mean(wm1);
% wm2 = wm2 - mean(wm2);

M2 = [heat wm1 wm2 slope heat.*wm1 heat.*wm2 heat.*slope...
    wm1.*slope wm2.*slope heat.*wm1.*slope heat.*wm2.*slope];





