function [onsets,pmods] = wave_getpmods(onset, condition, frequency)
% receives onsets of wavepain condition, the name of the condition and the
% frequency for the modulated stick functions (pmods) to return

% Prepare high res regressors
n_samples = 110000;
[~,bins]    = getBinBarPos(n_samples);
idx     = linspace(0,n_samples, n_samples);
slope1  = idx >= bins(1) & idx < bins(2);
task1   = idx >= bins(2) & idx < bins(4);
task2   = idx >= bins(4) & idx < bins(6);
slope2  = idx >= bins(6) & idx < bins(7);

% Waves
[m, w] = waveit2(110000,1);


% Tasks
tbob   = zeros(1,n_samples);
tbob(task1) = 1;
tbob(task2) = -1;
obtb = -tbob;

% Slopes
dsus = zeros(1,n_samples);
dsus(slope1)    = 1;
dsus(task1)     = -1;
dsus(task2)     = 1;
dsus(slope2)    = -1;
usds            = -dsus;

% heat and slope
if ismember(condition, {'M21','M12','M_Online'})
    heat = m;
    slope = dsus;
else
    heat = w;
    slope = usds;
end

% wm
if ismember(condition, {'M21', 'W21'})
    wm = tbob;
elseif ismember(condition, {'M12', 'W12'})
    wm = obtb;
else
    wm = zeros(1, n_samples);
end

% prepare output: 
% - onset column 
% - pmods matrix (each pmod is a column)
onsets  = [];
pmods   = [];
for i = 1:numel(onset)
    template = [];
    [template(:,1), x] = resample_pmod(heat, frequency);
    x = x + onset(i); % shift onset accordingly
    onsets = vertcat(onsets, x');
    
    template(:,2) = resample_pmod(wm, frequency);
    template(:,3) = resample_pmod(slope, frequency);
    template(:,4) = resample_pmod(heat.*wm, frequency);
    template(:,5) = resample_pmod(heat.*slope, frequency);
    template(:,6) = resample_pmod(wm.*slope, frequency);
    template(:,7) = resample_pmod(heat.*wm.*slope, frequency);
    
    pmods = vertcat(pmods, template);
end

%==========================================================================
% FUNCTION rs_pmod = resample_pmod(pmod, resample)
%==========================================================================
function [rs_pmod,xq] = resample_pmod(pmod, freq)
xq = 0:1/freq:110;
x  = linspace(0, 110, numel(pmod));
rs_pmod = interp1(x, pmod, xq);






















    
