function nback_analysis2

% Settings
SAMPLE   = 'fmri';

% Housekeeping
host        = wave_ghost2(SAMPLE);
DATA_DIR                    = host.dir;
NBACK_DIR                   = fullfile(DATA_DIR, 'nback');
RAW_TEMPLATE                = 'all_nback.csv';
SLOPE_COLLAPSED_TEMPLATE    = 'all_nback_slope_collapsed.csv';
SLOPE_COLLAPSED_COLLAPSED_TEMPLATE = 'all_nback_slope_collapsed_collapsed.csv'; % 4 values/sub: ob | tb X up | down
SLOPE_COLLAPSED_COLLAPSED_C_TEMPLATE = 'all_nback_slope_collapsed_collapsed_c.csv'; % 2 values/sub: ob tb

RAW_FILE                    = fullfile(NBACK_DIR, RAW_TEMPLATE);
SLOPE_COLLAPSED_FILE        = fullfile(NBACK_DIR, SLOPE_COLLAPSED_TEMPLATE);
SLOPE_COLLAPSED_COLLAPSED_FILE = fullfile(NBACK_DIR, SLOPE_COLLAPSED_COLLAPSED_TEMPLATE);
SLOPE_COLLAPSED_COLLAPSED_C_FILE = fullfile(NBACK_DIR, SLOPE_COLLAPSED_COLLAPSED_C_TEMPLATE);

% Check if files are available
if ~exist(RAW_FILE, 'file') % then we cannot do anything
    fprintf('Source file (%s) is missing. Aborting.\n', RAW_FILE)
    return
end



