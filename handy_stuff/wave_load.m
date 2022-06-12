function data = wave_load(name, dims)
% load dims(1) X dims(2) double from binary file name.bin

data = [];
fname = sprintf('%s.bin', name);
fid = fopen(fname, 'r');
temp = fread(fid, 'double');

if numel(temp) ~= prod(dims)
    warning('data read has wrong dimensions. aborting');
    return
end

data = reshape(temp, dims(1), []);
