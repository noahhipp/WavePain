function M = wave_load_designmatrix
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



