function yl = wave_load_ylims
% loads ylims from binary file and returns them as two element vector

[fid, errmsg] = fopen('ylims.bin', 'r');
if ~isempty(errmsg)
    warning('something wrong with coordinates');
    return;
end

yl = fread(fid,'double');
fclose(fid);