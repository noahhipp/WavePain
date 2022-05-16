% v2 accoutns for different number of measurements per person

% 2020-01-23 let this be the final version
% SEy the deficient one
% SEz is the good one
% SEMnormj the one proposed by Loftus & Masson, but same error bars for all conds

% Based on "Error bars in within-subject designs: a comment on Baguley (2012)" by Denis Cousineau & Fearghal O’Brien

function [data,SEz,SEy,SEMnormj,pm] = MixedStandardErrors_v2(D,colTag)    
    % Input
    % D = table with columns id and dv
    %
    % D = table with column id
    % dvTag = column name of dv

    %THERE IS NO CORRESPONDENCE BETWEEN GROUPS, obvs

    % Representing Error bars in within-subject designs  in typical software packages 

    % Loftus  and Masson  (1994)  propose  an  alternative  to  calculate  amore  appropriate  standard  error  by  carrying  out  a repeated-measures ANOVA and using the formula
    % SE = sqrt(MSerror/n);
    % but this leads to same error bars for all conditions
    %
    % Hence, Suggestion by Cousineau to use standardized data, with modifcation by morey 2008
    
    if ~nargin        
        vas=[1 3 3;4 7 7;3 4 4;7 8 8;10 NaN 19;100 1 1];
        D = table(repmat([1:6]',3,1),vas(:));
        D.Properties.VariableNames = {'id','dv'};     
    elseif nargin==2
        nD = table(D.id,D.(colTag));
        nD.Properties.VariableNames = {'id','dv'};     
        D = nD;
    end
    
    nancol = NaN(size(D,1),1);
    onecol = ones(size(D,1),1);
    
    data = [];
    data = table(D.id,nancol,D.dv,nancol,nancol,nancol,nancol,nancol);
    data.Properties.VariableNames = {'id','trial_number','dv','m1','m2','dv_centered_on_m2','morey','m1_n1'};
    data = sortrows(data,1); % cosmetics
    
    ids = unique(data.id);
    n_ids = numel(ids);
    
    % Grand mean
    data.m2 = nanmean(data.dv).*onecol; 

    %---------------------------------------
    % FIRST, APPLY COUSINEAU METHOD
    % via Error bars in within-subject designs: a commenton Baguley (2012) eetc.    
    % normalize observation according to Cousineau method    
    
    % loop through subs start
    for i = 1:numel(ids)
        id                              = ids(i);
        
        % Subject mean
        data.m1(data.id==id)            = nanmean(data.dv(data.id==id));
        
        % Count trials (ie measurements)
        data.trial_number(data.id==id)  = ...
            [1:numel(data.trial_number(data.id==id))]'; 
        
        % N of valid measurements per condition per subject
        n                               = sum(~isnan(data.dv(data.id==id))); 
        
        % Morey correction factor, individ. bc. diff. trial_counts                                                     
        data.morey(data.id==id)         = sqrt(n/(n-1)); 
    end % loop through subs end 
    
    % Take care auf faulty correction rates
    data.morey(data.morey==Inf) = NaN;               
    
    % Center data on grand mean ("normalize" data)
    data.dv_centered_on_m2 = data.dv-data.m1+data.m2; 
    for i = 1:numel(ids)
        id = ids(i);
        
        % m1 but only once for each subject
        data.m1_n1(data.id==id & data.trial_number==1) =...
            data.m1(data.id==id & data.trial_number==1);
        
        % m1 of centered data
        data.m1_from_centered(data.id==id) =...
            nanmean(data.dv_centered_on_m2(data.id==id)); % this is m2 again -.^
    end
    data.Yjmean = data.m1_n1; % ~m2, across subjects
    
    %---------------------------------------
    % SECOND, APPLY MOREY CORRECTION
    % correction factor    
    data.Zsj = data.morey.*(data.dv_centered_on_m2-data.Yjmean)+data.Yjmean; % formula 4
    
    %---------------------------------------
    % THIRD, get standard errors
    SEy = nanstd(data.dv_centered_on_m2)./sqrt(n_ids);
    SEz = nanstd(data.Zsj)./sqrt(n_ids);
    SEMnormj = sqrt((1/(n_ids*(n_ids-1)))*(nansum((data.dv_centered_on_m2-data.m1_from_centered).^2))); % from Franz & Loftus, Psychon Bull Rev (2012) 19:395–404    
    
    data.SEy = repmat(SEy,size(data,1),1); % ~~SEy(:) from MixedStandardErrors
    data.SEz = repmat(SEz,size(data,1),1);    
    data.SEMnormj = repmat(SEMnormj,size(data,1),1); 
  
    if 1==2
        figure;
        subplot(3,1,1);histogram(data.dv);
        subplot(3,1,2);histogram(data.dv_centered_on_m2); % normalized
        subplot(3,1,3);histogram(data.Zsj); % normalized, morey-corrected
    end
    
    %---------------------------------------
    % ALSO CONSIDER
    %The Cousineau–morey approach introduced an accessibleway to plot error bars of various kinds in mean 
    %plots whenrepeated measure designs are used. Still, the discussion is farfrom over. First, as Franz 
    %and Loftus (2012) correctly noted,such an approach requires that the sphericity assumption bevalid 
    %(the same is true for some of the propositions in Loftus &Masson,1994). Hence, a mean plot of within-subject 
    %designdata should always report a measure of sphericity such as theHuynh–Feldt epsilon (1976), although one 
    %should beware,since some popular statistical packages compute this statisticincorrectly (see Lecoutre,1991). 
    %This measure of sphericityshould be above 0.70 at the very least. See Franz and Loftus(2012) for alternative propositions.
    %
    %Second, mixed designs involve both within- and between-group treatments. In this case, we end up with two 
    %differentstandard errors and, consequently, two different CIs dependingon whether the conditions are compared 
    %across measures oracross groups. Baguley (2012) suggested the use of two-tierederror bars in which, ticks show both
    %error bars. This solutionhas the advantage that if the ticks are equal for the between andwithin error bars, it implies 
    %that there is no correlation betweenthe participants’scores. However, the presence of two sets ofticks on each error bar 
    %could potentially be misleading.
    