function [a,b] = wave_make_tables_same_height(a,b)
% receives two tables with possibly different height and returns those
% tables with equal height equivalent to smaller height

target_height = min([height(a), height(b)]);
n_chopped_off = max([height(a), height(b)]) - target_height;

fprintf('wave_make_tables_same_height: "Target height is %d. chopped off %d samples."\n',...
    target_height, n_chopped_off);
a = a(1:target_height,:);
b = b(1:target_height,:);