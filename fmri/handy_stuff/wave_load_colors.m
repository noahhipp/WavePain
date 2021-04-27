function c = wave_load_colors
% reads 5 colors from binary file 

[fid, errmsg] = fopen('colors.bin', 'r');
if ~isempty(errmsg)
    warning('something wrong with colors');
    return;
end

c = reshape(fread(fid,'double'),5,[]) ./ 255;
fclose(fid);