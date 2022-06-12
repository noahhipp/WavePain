function wave_save(data, name)
% save matlab array data to binary file "fname"

fname = sprintf('%s.bin',name);
fid = fopen(fname, 'w');
fwrite(fid, data, 'double');
fclose(fid);