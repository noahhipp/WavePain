function callback_mom(child)
% sets specified function (child...) to be invoked by updating st.centre

switch child
    case 1
        f = @child1_plot_f_contrasts_baseline_corrected;
        m = 'spm_plot_f_constrats_baseline_corrected.m';
    case 2
        f = @child2_plot_f_contrasts_eoi;
        m = 'eoi of all 6 conditions';
    otherwise
        m = 'NOTHING';                
end


% Set callback
global st
st.callback = f;

fprintf('\n CAVE: %s set as callback function for st.centre\n', m);