function wave_plot_fitted_response(betas)
% Multiplies Design matrix by betas and plots the result


load('C:\projects\wavepain\code\fmri\03_firstlevel\firstlevel_canonical_pmod\plotting\xX.mat','A');
try
    data = A*betas;
catch
    data = A*betas;
end



porder              = [1 2; 6 7; 3 4; 8 9; 11 12; 13 14];
condition_names     = {'M21', 'M12','W21', 'W12','Monline','Wonline'};
do_ylims            = 0;

f =figure;
new = 1;


if new
    fprintf('...instantiating...');
    
    % Prepare wave
    load('parametric_contrats_60fir.mat','parametric_contrasts')
    m = (parametric_contrasts.m - parametric_contrasts.m(1)) .* (1/7); % minus mal minus das ist kein stuss, minus mal minus das gibt plus
    w = (parametric_contrasts.w - parametric_contrasts.w(1)) .* (1/7);
    wave_x = linspace(1,119,60);
    line_width          = 4;    
    
    % Set axis colors
    left_color = [0 0 0];
    right_color = [1 1 1];
    set(f,'defaultAxesColorOrder',[left_color; right_color]); 
    
    observed_data = [];
    for i = 1:6        
        subplot(3,5,porder(i,:)); hold on;
        
        % Plot data
        yyaxis left; cla;
        line = waveplot(data(:,i), condition_names{i}, zeros(size(data,1),1),55);
        if do_ylims
            ylim([-do_ylims, do_ylims]);
        end                                        
        
        % Plot wave
        if ismember(i,[1 2 5]);   pwave=m; 
            if i == 2;ylabel('fMRI Fitted response [au]', 'FontSize', 12, 'FontWeight', 'bold'); end
        else;       pwave=w;            
        end
        yyaxis right; cla;
        wave                = plot(wave_x, pwave, 'k--');
        wave.LineWidth      = line_width * .67;        
        if i==4
                hold on;                
                online = plot(1,0.3, '-*', 'LineWidth', 4, 'Color', [0.1725 0.4824 0.7137]);
                blank = plot(1,0.1,'w-');
                lg =legend([line(1:3) online blank wave],{'...no task', '...1-back','...2-back','...online rating','','Heat stimulus'});
                lg.Position= [0.83 .45, 0.1 0.1];                            
                lg.Title.String = 'FIR estimates during...';
                lg.FontSize = 12;
        end
        
        % Customize figure
        grid on;
        title(condition_names{i}, 'FontSize', 14, 'Interpreter','none');
        ylim([-0.25 0.25]);
        if i > 4
            xlabel('Time (s)', 'FontSize', 12, 'FontWeight', 'bold');            
        end
        [~,ticks] = getBinBarPos(110);
        ax = gca;
        Xachse = ax.XAxis;
        ax.YAxis(1).FontSize = 12;
        Xachse.FontSize = 12;
        Xachse.TickValues = [ticks(2), ticks(4), ticks(6), 110];
        Xachse.TickLabelFormat = '%d';
        
        % Save for later
%         observed_data = vertcat(observed_data, data{i}.contrast);        
    end
    
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