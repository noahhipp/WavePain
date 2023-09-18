function wave_plotdesignmatrix(cons, con_names)
% plots regressors as they would show up in SPM design matrix

cropped = 1;

figure('Color', 'white');
x = linspace(0, -6*60, 360);

% Construct cropped idx
lower = [-44 -104 -164 -224 -284 -344];
upper = [-11 -71 -131 -191 -251 -311];
cidx = any(x >= lower' & x <= upper');

for i = 1:numel(con_names)
    sp = subplot(1,numel(con_names),i); hold on;
    title(con_names{i}, 'FontSize', 18, 'FontWeight', 'bold', 'Interpreter', 'none');
    
    if cropped 
        plot(cons(i,:),x, 'k:')
        
        % Now plot during task regressors with solid line
        c = cons(i,:);
        c(~cidx) = nan;
        
        plot(c,x, 'k-', 'LineWidth',1.7)
    else    
        plot(cons(i,:),x, 'k-')
    end
    xlim([-2,2])
    ylim([-360,0]);
    hline([-60:-60:-300], 'r-');
    
    yticks(-330:60:-30);
    yticklabels({'Wonline', 'Monline', 'W12', 'W21', 'M12', 'M21'});
    ytickangle(270);
    sp.FontSize = 14;
    sp.FontWeight = 'bold';
end