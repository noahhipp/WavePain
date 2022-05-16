% ================
% jittered display
% ================
% prints string char by char with human typewriter timing 
function jdisp(string)

% Ideas for future (no internet, just see what I can comeup with over time)
% - errors
% - intraword is faster than global
% - scrape your own typing and usethose parameters
% 

% DEBUG
debug = 1;

% Determine timing
cpm = [250 300]; % min max chars per minute according to sloppy literature
spc = 60 ./ cpm; % min max secs per char

% Settings
% a computer typing at human speed feels stupidly slow therefore we employ:
global_speed_multiplier      = 5; 

% before starting a new word there sometimes is a small break
space_pause                  = .08; % pause extra before new word
space_pause_probability      = .1; % probability for extra pause


digit_pause                  = 1;

% Do the printing
fprintf('\n');
if ~debug
    for char = string



        % Print char
        fprintf('%s',char);

        % For precise countdowns
        if isstrprop(char, 'digit')
            pause(digit_pause)
            continue
        end

        % Pause stuff (looks messy but works)
        t = jitter(spc);    
        pause(t/global_speed_multiplier);
        if (char == ' ') && (rand > space_pause_probability)
            pause(space_pause)
        end


    end
else
    disp(string);
end
fprintf('\n\n');

% jitter(spc)
% receives min max secs per char and returns a number sampled from a normal
% distribution encapsulating spc
function t = jitter(spc)
t = mean(spc) + (rand-0.5) * (range(spc)/2);

