function wave_plot_fmri_wrapper

% If figures are open update title
wave_updating;

[~, ~, code_dir] = wave_ghost;
cd(fullfile(code_dir, 'plotting'));

% Save coordinates
global st;
xSPM                    = evalin('base', 'xSPM');
fprintf('\n\n STARTING NEW PLOTTING CYCLE FOR: X: %.2f, Y: %.2f Z: %.2f\n', st.centre); 
wave_save_coordinates(st.centre, xSPM);


% Load data from FIR SPM, then save to binary file for rapid access
fir_data = wave_load_SPM('fir_anova_6', 1:6);

% Load data from Canonical pmod ANOVA
pmod_data = wave_load_SPM('second_level_anovacanonical_pmodV3', 2);

% Plot timecourses
cd(fullfile(code_dir, 'plotting'));
wave_plot_fmri_fir(fir_data);

% Plot anovabars
cd(fullfile(code_dir, 'plotting'));
wave_plot_fmri_pmod(pmod_data);

% Plot fitted response
wave_plot_fmri_fitted_response;
wave_sliders;





