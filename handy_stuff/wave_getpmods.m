function [onsets,pmods] = wave_getpmods(onset, condition, frequency, varargin)
% receives onsets of wavepain condition, the name of the condition and the
% frequency for the modulated stick functions (pmods) to return


% Check if temps were provided
temps = [];
if nargin > 3
    temps = varargin{1};    
end

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
    if isempty(temps)
        [template(:,1), x] = resample_pmod(heat, frequency);
        template(:,2) = resample_pmod(wm, frequency);
        template(:,3) = resample_pmod(slope, frequency);
        template(:,4) = resample_pmod(heat.*wm, frequency);
        template(:,5) = resample_pmod(heat.*slope, frequency);
        template(:,6) = resample_pmod(wm.*slope, frequency);
        template(:,7) = resample_pmod(heat.*wm.*slope, frequency);
    else
       [template, x] = scale_ramp_sample_pmods(heat, wm, slope, frequency, temps);
    end
    
    x = x + onset(i); % shift onset accordingly
    onsets = vertcat(onsets, x');
    pmods = vertcat(pmods, template);
end

%==========================================================================
% FUNCTION rs_pmod = resample_pmod(pmod, resample)
%==========================================================================
function [rs_pmod,xq] = resample_pmod(pmod, freq)
xq = 0:1/freq:110;
x  = linspace(0, 110, numel(pmod));
rs_pmod = interp1(x, pmod, xq);

%==========================================================================
% FUNCTION template, x = scale_ramp_sample_pmods(heat, wm, slope, freq,
% temp)
%==========================================================================
% SCALE (only for heat), PREPEND/APPEND RAMPS and RESAMPLE pmods according
% to subject specific temps

function [batch,x] = scale_ramp_sample_pmods(heat,wm, slope, freq, temps)
% This gets changed so we need to set it
N = numel(heat);
template = [];

% heat
heat = heat.*(temps.peak-temps.lead); % amplitude
heat = heat+temps.lead; % lead in
template(:,1) = zscore([32 heat 32]);

% wm
template(:,2) = zscore([0 wm 0]);

% slope
template(:,3) = zscore([1 slope -1]);

% heat x wm
template(:,4) = template(:,1).*template(:,2);

% heat x slope
template(:,5) = template(:,1).*template(:,3);

% wm x slope
template(:,6) = template(:,2).*template(:,3);

% heat x wm x slope
template(:,7) = template(:,1).*template(:,2).*template(:,3);

% Construct corresponding time vectors
x  = [-temps.to_lead linspace(0,110,N), 110+ temps.to_lead];
xq = -temps.to_lead:freq:110+temps.to_lead;

% Prepare template
batch = [];
for i = 1:size(template,2)
    batch(:,i) = interp1(x,template(:,i),xq);
end