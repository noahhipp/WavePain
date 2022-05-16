function f = wavefig(varargin)
% defaults
width = 18;
height = 7;

% two arguments are passed so we overwrite defaults
if nargin == 2
    WIDTH   = varargin{1};
    HEIGHT  = varargin{2};
% none are passed so we use defaults
elseif ~nargin
    WIDTH   = width;
    HEIGHT  = height;
% if neither is the case we cast an error
else
    error('supply NONE or TWO (width_cm, height_cm) arguments!');    
end

% create desired figure
f = figure('Units', 'centimeters', 'Position', [0 0 WIDTH, HEIGHT]);

% feedback to user
fprintf('\ncreated figure (%dcm X %dcm)\n', WIDTH, HEIGHT);

    
    