function eda_add_regressors_prepare_behav
% Prepares behav long scl file for analysis. This includes:
%           - changing column names
%           - adding time_within_trial column for downsampling later
%           - adding index_within_trial column
%           - adding regressors