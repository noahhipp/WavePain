function wave_plot_fitted_response_EDA(in, varargin)

% Handle input
flag = '';
if nargin > 1
    flag = varargin{1};
end

% lme or betas
if strcmp(class(in), 'LinearMixedModel')
    betas = in.Coefficients.Estimate(2:end);
    if any(contains(in.CoefficientNames, 'diff'))
        flag = 'diffheat';
    end
else
    betas = in;
end

if numel(betas) == 7 % one trinary wm regressor
    M = wave_load_designmatrix(flag);
elseif numel(betas) == 11 % two binary wm regressors
    [~,M] = wave_load_designmatrix(flag);
end

fprintf("\nwave_plot_fitted_response_EDA([")
fprintf("%.2f ", betas);
fprintf("], '%s')\n", flag);

try 
    data = M*betas;
catch
    data = M*betas';
end

data = reshape(data,[],6);

% Plot fitted response
font_sizes = [8 10 12];




% porder              = [1 1 2 2 3 4];
porder              = [1 2; 1 2; 3 4; 3 4 ; 6 7; 8 9];

condition_names     = {'M21', 'M12','W21', 'W12','Monline','Wonline'};
do_ylims            = 0;

f =figure('Units', 'centimeters', 'Position',[10 10 18 10]);
new = 1;


if new
    
    % Prepare wave
    load('parametric_contrats_60fir.mat','parametric_contrasts')
    m = M(1:60,1);
    w = M(121:180,1);
    wave_x = linspace(1,120,60);
    line_width          = 1;    
    
    % Set axis colors
    left_color = [0 0 0];
    right_color = [1 1 1];
    set(f,'defaultAxesColorOrder',[left_color; right_color]); 
    
    observed_data = [];
    for i = 1:6        
%         subplot(2,2,porder(i)); hold on;
        subplot(2,5,porder(i,:)); hold on;

        
        % Plot data
        yyaxis left; % cla;
        line = waveplot2(data(:,i), condition_names{i}, zeros(size(data,1),1),55);
        lines{i} = line; % save it for shades
        ylim([-1.5 1.5]);
        hold on;
        
        % Customize left yaxis
        ax = gca;
        ax.YAxis(1).TickValues = [-1 0 1];
        if ismember(i, [2,5])
            ylabel('SCL [Zscores]', 'FontWeight', 'bold', 'FontSize', font_sizes(1));
        end
        
        % Plot shades
        if i == 2
            % shade between lines{1}(2) and lines{2}(2)
            shade = wave_shade_between(lines{1}(2), lines{2}(2));
            title('M21 & M12', 'FontSize', font_sizes(2), 'Interpreter','none');
        elseif i == 4
            % shade between lines{1}(2) and lines{2}(2)
            shade = wave_shade_between(lines{3}(3), lines{4}(3));
            title('W21 & W12', 'FontSize', font_sizes(2), 'Interpreter','none');
        end
        
        % Plot wave
        if ismember(i,[1 2 5])
            pwave=m;            
        else
            pwave=w;                        
        end
        yyaxis right;  % cla;
        wave                = plot(wave_x, pwave, 'k--');
        wave.LineWidth      = line_width * .67;  
        yticks([]);
        if i==4
                hold on;                
                online = plot(1,0.3, '-', 'LineWidth', 2, 'Color', [0.1725 0.4824 0.7137]);
                blank = plot(1,0.1,'w-');
                lg =legend([line(1:3) online blank wave],{'...no task', '...1-back','...2-back','...online rating','','Heat stimulus'});
                lg.Position= [0.83 .45, 0.1 0.1];                            
                lg.Title.String = 'Fitted responses during...';
                lg.FontSize = font_sizes(1);
        end
        
        % Customize figure
        grid on;
%         title(condition_names{i}, 'FontSize', font_sizes(2), 'Interpreter','none');
        ylim([-1.5 1.5]);
        if i > 4
            xlabel('Time (s)', 'FontSize', font_sizes(1), 'FontWeight', 'bold');            
        end
        [~,ticks] = getBinBarPos(110);
        ax = gca;
        Xachse = ax.XAxis;
        ax.YAxis(1).FontSize = font_sizes(1);
        Xachse.FontSize = font_sizes(1);
        Xachse.TickValues = [ticks(2), ticks(4), ticks(6), 110];
%         Xachse.TickValues = [];
        Xachse.TickLabelFormat = '%d';
        xlim([0 110]);
        ylim([-1.5 1.5]);

        
        % Save for later
%         observed_data = vertcat(observed_data, data{i}.contrast);        
    end
    
    sgt = sgtitle('fMRI sample: Fitted responses from LME model');
    sgt.FontWeight = 'bold';
    sgt.FontSize = font_sizes(3);
    
else
    % Still have to figure this out cause selecting the subplot clears
    % it...
    fprintf('...updating...     ');
    for i = 1:6        
        subplot(3,5,porder(i,:)); hold on;
        
       
        yyaxis left; cla;
        [line, legend_labels] = waveplot(data{i}.contrast, condition_names{i}, data{i}.standarderror,55);
        if do_ylims
            ylim([-do_ylims, do_ylims]);
        end
        xlim([0 110]);
    end        
end










