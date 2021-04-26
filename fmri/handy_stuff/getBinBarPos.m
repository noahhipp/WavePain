function [out1, out2] = getBinBarPos(xLength)
% Determines bar positions for binned SCL AUC under WavePain Waves

total = xLength;
stim = xLength / 1.1;
lead = xLength / 110 * 5;


% Determine barpositions
start = 0;
for n = 1:8
    if n == 1 
        jump = lead / 2;
    elseif n == 2 || n == 8
        jump = stim / 12 + lead / 2;
    else
        jump = stim / 6;
    end
    
    start = start + jump;
    out1(n) = start;   
end

% Some dirty corrections
out1([1 8]) = out1([1 8]) + xLength / 55;

% Determine bin boundaries
start = 0;
for n = 1:7
    if n == 1
        jump = lead;
    else
        jump = stim / 6;
    end
    start = start + jump;
    out2(n) = start;
end

end