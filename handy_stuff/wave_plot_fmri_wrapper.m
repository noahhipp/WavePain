    function wave_plot_fmri_wrapper

% If figures are open update title
wave_updating;

[host] = wave_ghost2;
code_dir = host.code;
cd(fullfile(code_dir, 'plotting'));

% Save coordinates
global st;
xSPM                    = evalin('base', 'xSPM');
fprintf('\n\n STARTING NEW PLOTTING CYCLE FOR: X: %.2f, Y: %.2f Z: %.2f\n', st.centre); 
wave_save_coordinates(st.centre, xSPM);


% Load data from FIR SPM, then save to binary file for rapid access
fir_data = wave_load_SPM('fir_anova_6', 1:6);

% Load data from Canonical pmod ANOVA
% for pmodV5: wave_load_SPM('second_level_anovacanonical_pmodV5', 1)
pmod_data = wave_load_SPM('second_level_anovacanonical_pmodV6', 1);

% Plot timecourses
cd(fullfile(code_dir, 'plotting'));
wave_plot_fmri_fir_paper(fir_data);

% Plot anovabars
cd(fullfile(code_dir, 'plotting'));
wave_plot_fmri_pmod(pmod_data);

% Plot fitted response
% wave_plot_fmri_fitted_response_paper;
% wave_sliders;





