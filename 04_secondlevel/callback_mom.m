function callback_mom(child)
% sets specified function (child...) to be invoked by updating st.centre

switch child
    case f_contrasts_baseline_corrected
        f = @child1_plot_f_contrasts_baseline_corrected;
        m = 'spm_plot_f_constrats_baseline_corrected.m';
    otherwise
        m = 'NOTHING';                
end


% Set callback
global st
st.centre = callback@f;

fprintf('\n CAVE: %s set as callback function for st.centre\n', m);