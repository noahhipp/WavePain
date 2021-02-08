function xyz = wave_load_coordinates
% loads coordinates from simple binary file in current directory

[fid, errmsg] = fopen('coordinates.bin', 'r');
if ~isempty(errmsg)
    warning('something wrong with coordinates');
    return;
end
xyz = fread(fid, 'double');
fclose(fid);

