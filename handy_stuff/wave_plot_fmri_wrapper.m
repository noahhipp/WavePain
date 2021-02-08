function wave_plot_fmri_wrapper

hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        error('this does not work, sorry');
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';        
        code_dir          = '/home/hipp/projects/WavePain/code/matlab/fmri/03_firstlevel/firstlevel_canonical_pmod/';
        cd(fullfile(code_dir, 'plotting'));
    otherwise
        error('Only hosts noahs isn laptop accepted');
end

% Save coordinates
global st;
xSPM                    = evalin('base', 'xSPM');
wave_save_coordinates(st.centre, xSPM);

% Load data from FIR SPM
fir_data = wave_load_SPM('fir_anova_6', 1:6);

% Load data from Canonical pmod ANOVA
pmod_data = wave_load_SPM('second_level_anovacanonical_pmodV3', 2);

% Plot
wave_plot_fmri(fir_data, pmod_data);




