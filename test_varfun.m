function [d_old, d_new] = test_varfun

% What we used to do
fname = "E:\wavepain\data\behav_sample\overall_ratings\all_overall_ratings_cc.csv";
d_old = readtable(fname);

% New way
fname = "E:\wavepain\data\behav_sample\overall_ratings\all_overall_ratings.csv";
d     = readtable(fname);

grouping_variables = {'condition'};

% we combine rating and ID into one vector to sneak it past varfun
d.id_rating         = complex(d.id, d.rating);
sem_variables       = {'id_rating'}; 

% Apply mean to all cols and get rid of prefix
mean_d = varfun(@mean, d, 'GroupingVariables', grouping_variables);
for i = 1:width(mean_d)
    mean_d.Properties.VariableNames{i} = strrep(mean_d.Properties.VariableNames{i}, 'mean_','');
end

% Apply sembj only to the complex one
sem_d = varfun(@sembj, d, 'GroupingVariables', grouping_variables,...
    'InputVariables', sem_variables);

% Transfer interesting sem columns to mean DATA
idx = contains(sem_d.Properties.VariableNames, 'rating');
cols_to_transfer = sem_d.Properties.VariableNames(idx);
for i = 1:numel(cols_to_transfer)
    mean_d(:,cols_to_transfer{i}) = sem_d(:,cols_to_transfer{i});
end

% Write output
d_new = mean_d;   

function corrected_sem = sembj(d_id)
dv = imag(d_id);
ids = real(d_id);

% now the fun starts: first we prepare a table containing all cols we want.
% All credit goes to b.horing@uke.de
nc                          = nan(numel(dv),1);
d                           = table(ids, nc, dv, nc, nc, nc, nc, nc);
d.Properties.VariableNames  = ...
    {'id','n','dv','m1','mGrand','Ysj','Morey','preM2'};
d                           = sortrows(d,1);

% Prepare subject loop
ids                        = unique(ids);
n_ids                      = numel(ids);


% COUSIn_idsEAU METHOD START
% Subject loop 1
for i = 1:n_ids
    id          = ids(i);
    idx         = d.id == id;
    d.m1(idx)   = nanmean(d.dv(idx)); % subject mean
    d.n(idx)    = 1:numel(d.n(idx)); % count measurements/sub
    n           = max(d.n(idx));
    d.Morey(idx)= sqrt(n/(n-1));
end % subject loop 1 end

d.Morey(d.Morey==Inf) = nan;
d.mGrand                = repmat(nanmean(d.dv),height(d),1); % global mean
d.Ysj                   = d.dv-d.m1+d.mGrand;

% Subject loop 2
for i = 1:n_ids
    id          = ids(i);
    idx         = d.id == id;
    d.preM2(idx & d.n==1) = d.m1(idx & d.n==1);
    d.m1Yj(idx) = nanmean(d.Ysj(idx)); % mean of centered d m1
end % subject loop 2 end

d.Yjmean = repmat(nanmean(d.preM2),height(d),1); % ~m2, across subjects irrespective of number of observations
% COUSIn_idsEAU METHOD En_idsD

% MOREY CORRECTIOn_ids START
d.Zsj = d.Morey.*(d.Ysj-d.Yjmean)+d.Yjmean; % formula 4 this is the corrected d
% MOREY CORRECTIOn_ids En_idsD

% GET SEMS START
SEy = nanstd(d.Ysj)./sqrt(n_ids);
SEz = nanstd(d.Zsj)./sqrt(n_ids);
SEMnormj = sqrt((1/(n_ids*(n_ids-1)))*(nansum((d.Ysj-d.m1Yj).^2))); % from Franz & Loftus, Psychon Bull Rev (2012) 19:395–404

d.SEy = repmat(SEy,height(d),1); % ~~SEy(:) from MixedStandardErrors
d.SEz = repmat(SEz,height(d),1);
d.SEMnormj = repmat(SEMnormj,height(d),1);
% GET SEMS En_idsD

% Write output
corrected_sem = d.SEz(1);