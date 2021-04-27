function fir_xcorr
% Cross correlation exploration for wavepain fir modell

% Get data
load('segerdahl.mat','segerdahl');
pc = plot_parametric_contrasts(0);
m = pc.m;
w = pc.w;

% Assemble table
data = segerdahl;
data.condition = repelem(1:6,60)';
data.index     = repmat(1:60,1,6)';
data.s         = repmat(linspace(1,119,60),1,6)';
data.heat      = [m m w w m w]';

% Settings 
do_cut_leads                = 1;
do_resample                 = 10; % Frequency to resample to. 0 to stick with 0.5Hz
do_condition_wise_xcorr     = 1;

% Loop through conditions and apply settings
heat_out    = [];
y_out       = [];

porder = [1 5 3 7 9 11];
figure('Name', 'fir_xcorr_conditions', 'Color', [1 1 1]);
for i = 1:numel(unique(data.condition))
    t = data(data.condition == i, :);
    
    
    if do_resample
        freq = do_resample;
        xq = linspace(1,119,do_resample*120);
        y  = interp1(t.s, t.y, xq);
        heat = interp1(t.s, t.heat, xq);
    else
        freq = 0.5;
        xq = linspace(1,119,120*0.5);
        y  = t.y;
        heat = t.heat;
    end
    
    if do_cut_leads
        to_cut          = xq < 5 | xq > 105;
        heat(to_cut)    = [];
        y(to_cut)       = [];
        xq(to_cut)      = [];
    end
    
    
    if do_condition_wise_xcorr
        subplot(3,4,porder(i));
        shift = wavecorr(heat,y,freq,10);
        
        subplot(3,4,porder(i) + 1);        
        yyaxis left
        plot(xq, y, 'r-'); hold on; % plot signal
        hold on;
        plot(xq+shift, y,'r:');
        
        yyaxis right
        plot(xq, heat, 'k--'); % plot heat
        
        legend('fir signal', 'shifted fir signal', 'heat');
    end
    
    % Append to large structure    
    heat_out = [heat_out, heat];
    y_out    = [y_out, y];
end 

figure('Name', 'fir_xcorr_overall', 'Color', [1 1 1]);
wavecorr(y_out, heat_out, freq);


