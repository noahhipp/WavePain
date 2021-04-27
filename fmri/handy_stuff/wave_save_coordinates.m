function wave_save_coordinates(xyz_mm, xSPM)
% just a convenience function that saves st.centre to a file because global
% variables are scary

xyz_vox = mm2voxelb(xyz_mm, xSPM);

fid = fopen('coordinates.bin', 'w');
fwrite(fid, [xyz_vox', xyz_mm], 'double');
fclose(fid);