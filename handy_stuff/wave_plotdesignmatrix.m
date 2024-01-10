function wave_plotdesignmatrix(cons, con_names)
% plots regressors as they would show up in SPM design matrix

cropped = 1; 
scl     = 1; 
small   = 1; % for matrix multiplication compound figure

x = linspace(0, -6*60, 360);
lower = [-44 -104 -164 -224 -284 -344];
upper = [-11 -71 -131 -191 -251 -311];

% Prepare data for scl
if scl
    cons(:, [56:60 116:120 176:180 236:240 296:300 356:360]) = []; % pop last 10s
    x = linspace(0, -6*60, 330); 
    lower = [-44 -104 -164 -224 -284 -344] -5;
    upper = [-11 -71 -131 -191 -251 -311] ;
end

% Construct cropped idx

cidx = any(x >= lower' & x <= upper');

for i = 1:numel(con_names)
    sp = subplot(1,numel(con_names),i); hold on;
    t = title(con_names{i}, 'Interpreter', 'none');
    
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
    t.FontSize = 18;
    t.FontWeight = 'bold';
    
    if small
        xlim([-1.7 1.7])
        ylim([-240, 0])
        sp.FontSize = 8;
        sp.FontWeight = 'normal';
        
        t.FontSize = 10;
        t.FontWeight = 'bold';
        
        xticks([]);
    end
end