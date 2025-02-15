function [m, w, dm, dw] = waveit2(varargin)
% returns m and w wave with lead in and out with specified number of
% samples

optargs             = {110, 0};
optargs(1:nargin)   = varargin;
[samples, suppress_output]             = optargs{:};
    

f                   = 0.015;

wave_samples        = round(samples * 100/110);
lead_in_samples     = round((samples - wave_samples) / 2);
lead_out_samples    = samples - wave_samples - lead_in_samples;

x                   = linspace(0,100,wave_samples);
wave                = sin(f * 2 * pi * x);
lead_in             = zeros(1,lead_in_samples);
lead_out            = zeros(1,lead_out_samples);

m                   = [lead_in, wave, lead_out];
w                   = [lead_in, wave .* -1, lead_out];

dm = [0 diff(m)]; dm = dm./max(dm);
dw = [0 diff(w)]; dw = dw./max(dw);

if ~suppress_output
    fprintf('=======\n waveit2: created waves with\n%d samples(%d lead in, %d wave, %d lead_out)\n=======\n',...
        samples, lead_in_samples, wave_samples, lead_out_samples);
end
    






