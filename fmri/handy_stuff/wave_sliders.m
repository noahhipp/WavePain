function wave_sliders
% Open UI window with 8 sliders analoguous to pmod bar plot

% After each change we rewrite:
% --> custom_betas 
% --> remainder_coeff
% --> and call wave_plot_fitted_response

ylims = wave_load_ylims;
betas           = wave_load('betas', [7 1]); % Initialize at original_betas

slider_names    = {'heat', 'wm', 'slope',...
    'heat_X_wm', 'heat_X_slope','wm_X_slope',...
    'heat_X_wm_X_slope'};

fig             = uifigure('Position',[100 100 1000  500], 'Name', 'Wave_Sliders');
pos             = [50 200 120 3];

% Initialize appropriate number of betas
for i = 1:numel(slider_names)
    [sliders(i), edts(i)] = create_slider(fig, slider_names{i}, pos, betas(i));
    pos = pos+[85 0 0 0];
end

% Initialize reset button
btn = uibutton(fig, 'push',...
    'Text', 'reset',...
    'Position', [300 100 120 20],...
    'ButtonPushedFcn', @(btn,event) reset_custom_betas(fig));

%==============================SUBFUNCTIONS================================

function [slider, edt] = create_slider(parent, label, pos, beta)
% Create and connected slid, box and label for variable in parent container
% Instantiate objects
slider = uislider(parent,...
    'Limits',[-1,1],...
    'Value', beta,...
    'Position', pos,...
    'Orientation', 'vertical');

edt = uieditfield(parent,'numeric',...
    'Value', beta,...
    'Position', pos+[0 -50, -70, 17]);
    
uilabel(parent, 'Text', label,...
    'Position', pos+[0 -30 -70 17]);

% Connect them
slider.ValueChangingFcn = @(slider, event) wupdate(event, edt, parent);
edt.ValueChangedFcn = @(edt, event) wupdate(event, slider, parent);


function wupdate(event, to_change1,parent)
% Updates second argument based on event and update. Called upon every
% change on wave_sliders

% Update partner gui element
to_change1.Value = event.Value;

% But also update custom betas
update_custom_betas(parent);


% And call our plotting routine again
wave_plot_fmri_fitted_response


function betas = collect_betas(parent)
% Collect values from all numeric fields in parent
betas       = [];
betas_idx   = 1;

% Gets values from gui
for i = 1:numel(parent.Children)    
    if strcmp(class(parent.Children(i)), 'matlab.ui.control.NumericEditField')
        betas(betas_idx) = parent.Children(i).Value;
        betas_idx = betas_idx + 1;
    end
end

betas = flip(betas); 

function update_custom_betas(parent)
% Rewrite custom betas based on values from parent
betas = collect_betas(parent);

% Write them to binary
wave_save(betas, 'custom_betas');
fprintf('\ncustom betas updated: ');
fprintf('%2.2f ', betas);

function reset_custom_betas(parent)

% Rewrite binary file
betas = wave_load('betas', [1,7]);
wave_save(betas, 'custom_betas');

% Just initialize again (could do this more elegantly but don't want to)
close(parent);
wave_sliders;
wave_plot_fmri_wrapper;








