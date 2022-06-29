function lmes = eda_plot_binned

% SETTINGS
SAMPLE                      = 'fmri';

% Housekeeping
HOST                        = wave_ghost2(SAMPLE);
EDA_DIR                     = fullfile(HOST.dir, 'eda');
EDA_BINNED_DIFF_TEMPLATE    = 'all_eda_binned_diff.csv';
EDA_BINNED_DIFF_FILE        = fullfile(EDA_DIR, EDA_BINNED_DIFF_TEMPLATE);

FIG_DIR                     = fullfile(HOST.results, '2022-06-16_binned_scl');
COLS_OF_INTEREST            = {'down_slope_difference', 'down_slope_quotient',...
    'up_slope_difference','up_slope_quotient','rating','delta_rating', 'total_difference'};
COL_LABELS                  = strrep(COLS_OF_INTEREST, '_',' ');
COL_LABELS_SHORT            = {'dsd','dsq','usd','usq','rat','drat','td'};

% Get data
d                               = readtable(EDA_BINNED_DIFF_FILE);
d.total_difference              = d.down_slope_difference + d.up_slope_difference;
d(ismember(d.condition,[2 4]),:)= []; % this information is redundant as we are looking at differences

% Do stats
formulas = {'delta_rating~down_slope_difference+down_slope_quotient+(1|id)',...
    'delta_rating~up_slope_difference+up_slope_quotient+(1|id)',...
    'delta_rating~up_slope_difference+down_slope_difference+(1|id)',...
    'delta_rating~up_slope_quotient+down_slope_quotient+(1|id)',...
    'delta_rating~down_slope_difference+down_slope_quotient+up_slope_difference+up_slope_quotient+(1|id)'};

for i = 1:numel(formulas)
    lmes{i} = fitlme(d,formulas{i});
    disp(lmes{i});
end

% Cov matrix
dmx                             = d{:,COLS_OF_INTEREST};

f = figure;
imagesc(corrcoef(dmx));
colorbar;
xticks(1:numel(COL_LABELS));
xticklabels(COL_LABELS);
xtickangle(45);
yticks(1:numel(COL_LABELS));
yticklabels(COL_LABELS);
ax = gca;
ax.FontSize = 8;
t =title(sprintf('Covariance matrix: %s sample', SAMPLE));
t.FontSize = 12;
fname = sprintf('%s_binned-scl_cov-matrix', SAMPLE);
fname = fullfile(FIG_DIR, fname);
print(fname, '-dpng','-r300');

% Covariance matrix for each sub
if 0
    f = figure('Units','normalized','Position',[0 0 1 1]); % opens full screen
    tiledlayout('flow');
    
    ids = unique(d.id);
    for i = 1:numel(ids)
        id = ids(i);
        dmx_id = d{d.id == id,COLS_OF_INTEREST};
        
        nexttile;
        imagesc(corrcoef(dmx_id));
        
        t =title(sprintf('sub%03d', id));
        xticks(1:numel(COL_LABELS_SHORT));
        xticklabels(COL_LABELS_SHORT);
        xtickangle(45);
        yticks(1:numel(COL_LABELS_SHORT));
        yticklabels(COL_LABELS_SHORT);
        ax=gca;
        ax.FontSize = 7;
    end
    t =sgtitle(sprintf('Covariance matrices: %s sample', SAMPLE));
    t.FontSize = 12;
    t.FontWeight = 'bold';
    
    fname = sprintf('%s_binned-scl_ID_cov-matrix', SAMPLE);
    fname = fullfile(FIG_DIR, fname);
    print(fname, '-dpng','-r300');
end

% Scatter histograms
for i = 1:numel(COLS_OF_INTEREST)
    xvar = COLS_OF_INTEREST{i};
    xvar_label = COL_LABELS{i};
    for j = 1:numel(COLS_OF_INTEREST)
        yvar = COLS_OF_INTEREST{j};
        yvar_label = COL_LABELS{j};
        figure;
        scatterhistogram(d,xvar, yvar, 'GroupVariable', 'condition',...
            'HistogramDisplayStyle','smooth','LineStyle','-');
        legend;
        
        xlabel(xvar_label);
        ylabel(yvar_label);
        title([SAMPLE, ': ', yvar_label, ' VS ',xvar_label]);
        
        fname = sprintf('%s_%s_VS_%s', SAMPLE, yvar, xvar);
        fname = fullfile(FIG_DIR, fname);
        print(fname, '-dpng','-r300');        
    end
end
        



