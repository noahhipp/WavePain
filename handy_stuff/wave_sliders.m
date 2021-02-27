function wave_sliders
% Open UI window with 8 sliders analoguous to pmod bar plot

ylims = wave_load_ylims;

% Initialize 7 sliders with ylims
slider_names    = {'heat', 'wm', 'slope',...
    'heat_X_wm', 'heat_X_slope','wm_X_slope',...
    'heat_X_wm_X_slope'};

fig             = uifigure('Position',[100 100 1000  500]);
pos             = [50 200 120 3];
betas           = wave_load('custom_betas', [7 1]);

for i = 1:numel(slider_names)
    [sliders(i), edts(i)] = create_slider(fig, betas(i), slider_names{i}, pos);
    pos = pos+[50 0 0 0];
end





% Set those sliders to betas



% Create figure window and components
fig = uifigure('Position',[100 100 1000  500]);

cg = uigauge(fig,'Position',[500 250 120 120]);

slope = uislider(fig,...
               'Position',[100 200 120 3],...
               'ValueChangingFcn',@(slope,event) sliderMoving(event,cg),...
               'Orientation', 'vertical');

slope = uislider(fig,...
               'Position',[300 200 120 3],...
               'ValueChangingFcn',@(slope,event) sliderMoving(event,cg),...
               'Orientation', 'vertical');           
           
           
intercept = uislider(fig,...
               'Position',[200 200 120 3],...
               'ValueChangingFcn',@(intercept,event) sliderMoving(event,cg),...
               'Orientation', 'vertical');
           
           
il = uilabel(fig, 'Text', 'Intercept', 'Position', [200 150 50 20]);           

edt = uieditfield(fig,'numeric',...
    'Position', [200 100 50 20],...
    'ValueChangedFcn', @(edt, event) wupdate(edt, cg, intercept));

btn = uibutton(fig, 'Text', 'reset','Position', [920 10 70 30]);

[test1, test2] = create_slider(fig, cg, 'TEST', [20 220, 120 3]);


% Create ValueChangingFcn callback
function sliderMoving(event,cg)
cg.Value = event.Value;


% Create and connected slider, box and label for variable in parent container
function [slider, edt] = create_slider(parent, target, label, pos)

% Instantiate objects
slider = uislider(parent,...
    'Position', pos,...
    'Orientation', 'vertical');

edt = uieditfield(parent,'numeric',...
    'Position', pos+[0 -50, -70, 17]);
    
uilabel(parent, 'Text', label,...
    'Position', pos+[0 -30 -70 17]);

% Connect them
slider.ValueChangingFcn = @(slider, event) wupdate(event, target, edt);
edt.ValueChangedFcn = @(edt, event) wupdate(event, target, slider);

% Updates second and third argument based on event
function wupdate(event, to_change1, to_change2)
to_change1.Value = event.Value;
to_change2.Value = event.Value;






