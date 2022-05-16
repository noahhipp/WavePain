function [xyz, xyz_mm] = wave_load_coordinates
% loads coordinates from simple binary file in current directory

[fid, errmsg] = fopen('coordinates.bin', 'r');
if ~isempty(errmsg)
    warning('something wrong with coordinates');
    return;
end
xyz = fread(fid, 'double');
xyz_mm = xyz(4:6);
xyz = xyz(1:3);
fclose(fid);