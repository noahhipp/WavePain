function wave_save_ylims(yl)
% saves ylims to binary file in wavepain plotting directory

fid = fopen('ylims.bin', 'w');
fwrite(fid, yl, 'double');
fclose(fid);