function [onsets,pmods] = wave_getpmods(onset, condition, frequency, varargin)
% receives onsets of wavepain condition, the name of the condition and the
% frequency for the modulated stick functions (pmods) to return


% Check if temps were provided
temps = [];
if nargin > 3
    temps = varargin{1};
    
    % Why round here?:
    % Assume temps.to_lead = 0.81
    % xq = -temps.to_lead:1/freq:110+temps.to_lead;
    % ramp_up_index               = xq < 0;
    % ramp_down_index             = xq > 110;
    % sum(ramp_up_index) is now 9, sum(ramp_down_index) is 8. This would
    % lead SPM to think that ramp up and ramp down are of different
    % lengths. This is incorrect. They are the same. To avoid this mess we
    % round to the log10 of our sampling frequency. For freq = 10 [Hz]
    % which is likely never going to change this means rounding to 1
    % Nachkommastelle. Now the beginning and end of xq look like this
    % -.8 -.7 -.6 -.5 -.4 -.3 -.2 -.1 0 .1 .2 .3 (...) 110 110.1 110.2
    % 110.3 110.4 110.5 110.6 110.7 110.8 which is nice as now
    % sum(ramp_up_index) == sum(ramp_down_index) which is closer to reality
    temps.to_lead = round(temps.to_lead, log10(frequency));
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
dm = [0 diff(m)];
dw = [0 diff(w)];


% Task


% tbob   = zeros(1,n_samples);
% tbob(task1) = 1;
% tbob(task2) = -1;
% obtb = -tbob;

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
%     slope = dsus;
    slope = dm;
else
    heat = w;
%     slope = usds;
    slope = dw;
end

% wm
if ismember(condition, {'M21', 'W21'})
    wm1 = task2;
    wm2 = task1;
elseif ismember(condition, {'M12', 'W12'})
    wm1 = task1;
    wm2 = task2;
else
    wm1 = zeros(1, n_samples);
    wm2 = zeros(1, n_samples);
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
        % only this is adjusted for the new binary wm regressors
       [template, x] = scale_ramp_sample_pmods(heat, wm1,wm2, slope, frequency, temps);
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
% SCALE (only for heat), PREPEND/APPEND RAMPS according
% to subject specific temps and RESAMPLE pmods in desired stick frequency

function [batch,xq] = scale_ramp_sample_pmods(heat,wm1,wm2, slope, freq, temps)
% This gets changed so we need to set it
N = numel(heat);
template = [];

% heat (the scaling becomes redundant now that we have seperate ramp
% regressor)
heat = heat.*(temps.peak-temps.lead); % amplitude
heat = heat+temps.lead; % lead in
template(:,1) = zscore([temps.lead heat temps.lead]);

% wm1 wm2
template(:,2) = zscore([0 wm1 0]);
template(:,3) = zscore([0 wm2 0]);

% slope
template(:,4) = zscore([0 slope 0]);

% heat x wm1
template(:,5) = template(:,1).*template(:,2);

% heat x wm2
template(:,6) = template(:,1).*template(:,3);

% heat x slope
template(:,7) = template(:,1).*template(:,4);

% wm1 x slope
template(:,8) = template(:,2).*template(:,4);

% wm2 x slope
template(:,9) = template(:,3).*template(:,4);

% heat x wm1 x slope
template(:,10) = template(:,1).*template(:,2).*template(:,4);

% heat x wm2 x slope
template(:,11) = template(:,1).*template(:,3).*template(:,4);

% Construct time vectors
x  = [-temps.to_lead linspace(0,110,N), 110+ temps.to_lead]; 
xq = -temps.to_lead:1/freq:110+temps.to_lead;

% Resample template
batch = [];
n = size(template,2);
for i = 1:n
    batch(:,i) = interp1(x,template(:,i),xq);
end

% Add ramp up ramp down
ramp_up_index               = xq < 0;
ramp_down_index             = xq > 110;

% Cast error if up ramp and down ramp are not equal
if sum(ramp_up_index) ~= sum(ramp_down_index)
    disp(temps.to_lead);
    fprintf('up ramp: %02d samples\ndown ramp: %02d samples\n', sum(ramp_up_index), sum(ramp_down_index));
    error('ramps unequal')
end

ramp_up                     = zeros(size(batch,1),1);
ramp_up(ramp_up_index)      = 1;
ramp_down                   = zeros(size(batch,1),1);
ramp_down(ramp_down_index)  = 1;

batch(:,n+1) = zscore(ramp_up);
batch(:,n+2) = zscore(ramp_down);




