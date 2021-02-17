function wave_save_colors
% function that saves colors to binary file that can be quickly read by
% wave_load_colors


 c = [215,25,28;
     253,174,97;
     255,255,191;
     171,217,233;
     44,123,182];
 
 fid = fopen('colors.bin', 'w');
 fwrite(fid, c, 'double');
 fclose(fid);
     
    
    

