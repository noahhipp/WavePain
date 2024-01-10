function patch = wave_shade_between(line1, line2, varargin)
% receives two line objects and shades the area in between

% Set defaults
default_color = mean([line1.Color; line2.Color]);
default_alpha = 0.5;

% Validation functions
valid_line = @(x) ...
    strcmp(class(x), 'matlab.graphics.chart.primitive.Line') ||...
    strcmp(class(x), 'matlab.graphics.primitive.Line');
valid_color = @(x) isnumeric(x) && isequal(size(x),[1, 3]);
valid_alpha = @(x) isnumeric(x) && (x > 0) && (x <= 1);

% Construct parser
p = inputParser;
addRequired(p,'line1',valid_line);
addRequired(p,'line2',valid_line);
addParameter(p,'color',default_color,@isstring);
addParameter(p,'alpha',default_alpha,...
    @(x) any(validatestring(x,expectedShapes)));
parse(p,line1,line2,varargin{:});


% Collect x
x1 = p.Results.line1.XData;
x2 = p.Results.line2.XData;
if ~isequal(x1,x2)
    warning('lines have different x values')
    return
end
x = [x1, fliplr(x2)];

% Collect y
y1 = p.Results.line1.YData;
y2 = p.Results.line2.YData;    
y_between = [y1, fliplr(y2)];

% Draw shade
patch = fill(x, y_between, p.Results.color);
patch.FaceAlpha = p.Results.alpha;