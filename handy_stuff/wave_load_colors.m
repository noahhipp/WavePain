function c = wave_load_colors
% returns array with colors for wavepain paper
% earlier version used to read 5 colors from binary file but this is not C 
% so we can do it like this

c = [215,25,28;
     253,174,97;
     255,255,191;
     171,217,233;
     44,123,182;
     119,221,119]./255;