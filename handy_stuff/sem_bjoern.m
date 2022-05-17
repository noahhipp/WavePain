% v2 accoutns for different number of measurements per person

% 2020-01-23 let this be the final version
% SEy the deficient one
% SEz is the good one
% SEMnormj the one proposed by Loftus & Masson, but same error bars for all conds

% Based on "Error bars in within-subject designs: a comment on Baguley (2012)" by Denis Cousineau & Fearghal O’Brien

function [data,SEz,SEy,SEMnormj,pm] = MixedStandardErrors_v2(D,colTag)


    % Input
    % D = table with columns SbId and DV
    %
    % D = table with column SbId
    % DVTag = column name of DV

    %THERE IS NO CORRESPONDENCE BETWEEN GROUPS, obvs

    % Representing Error bars in within-subject designs  in typical software packages

    % Loftus  and Masson  (1994)  propose  an  alternative  to  calculate  amore  appropriate  standard  error  by  carrying  out  a repeated-measures ANOVA and using the formula
    % SE = sqrt(MSerror/n);
    % but this leads to same error bars for all conditions
    %
    % Hence, Suggestion by Cousineau to use standardized data, with modifcation by Morey 2008

    if ~nargin
        vas=[1 3 3;4 7 7;3 4 4;7 8 8;10 NaN 19;100 1 1];
        D = table(repmat([1:6]',3,1),vas(:));
        D.Properties.VariableNames = {'SbId','DV'};
    elseif nargin==2
        nD = table(D.SbId,D.(colTag));
        nD.Properties.VariableNames = {'SbId','DV'};
        D = nD;
    end

    nancol = NaN(size(D,1),1);

    data = [];
    data = table(D.SbId,nancol,D.DV,nancol,nancol,nancol,nancol,nancol);
    data.Properties.VariableNames = {'SbId','n','DV','m1','mGrand','Ysj','Morey','preM2'};
    data = sortrows(data,1); % cosmetics

    allSbIds = unique(data.SbId);
    N = numel(allSbIds); % number of subjects

    %---------------------------------------
    % FIRST, APPLY COUSINEAU METHOD
    % via Error bars in within-subject designs: a commenton Baguley (2012) eetc.
    % normalize observation according to Cousineau method
    for sb = 1:numel(allSbIds)
        sbId = allSbIds(sb);
        data.m1(data.SbId==sbId) = nanmean(data.DV(data.SbId==sbId)); % for every subject, average across measurements
        data.n(data.SbId==sbId) = [1:numel(data.n(data.SbId==sbId))]'; % condition index, not sure if useful
        n = sum(~isnan(data.DV(data.SbId==sbId))); % n of valid measurements
        data.Morey(data.SbId==sbId) = sqrt(n/(n-1)); % for every subject, Morey correction factor; has to be individual bc different numbers
                                                     % of measurement (n) can exist
    end
    data.Morey(data.Morey==Inf) = NaN;
    data.mGrand = repmat(nanmean(data.DV),size(data,1),1); % grand mean

    data.Ysj = data.DV-data.m1+data.mGrand; % "normalized" data (actually centered on grand mean, but not my words)

    for sb = 1:numel(allSbIds)
        sbId = allSbIds(sb);
        data.preM2(data.SbId==sbId & data.n==1) = data.m1(data.SbId==sbId & data.n==1);
        data.m1Yj(data.SbId==sbId) = nanmean(data.Ysj(data.SbId==sbId)); % mean of centered data m1
    end

    data.Yjmean = repmat(nanmean(data.preM2),size(data,1),1); % ~m2, across subjects irrespective of number of observations

    %---------------------------------------
    % SECOND, APPLY MOREY CORRECTION
    % correction factor
    % probably works like this: 1. center data 2. apply correction factoir to centered data 3. decenter data again
    data.Zsj = data.Morey.*(data.Ysj-data.Yjmean)+data.Yjmean; % formula 4 this is the corrected data
    data.Zsj2 = data.Morey.*data.Ysj; %  ??????

    %---------------------------------------
    % THIRD, get standard errors
    SEy = nanstd(data.Ysj)./sqrt(N);
    SEz = nanstd(data.Zsj)./sqrt(N);
    SEMnormj = sqrt((1/(N*(N-1)))*(nansum((data.Ysj-data.m1Yj).^2))); % from Franz & Loftus, Psychon Bull Rev (2012) 19:395–404

    data.SEy = repmat(SEy,size(data,1),1); % ~~SEy(:) from MixedStandardErrors
    data.SEz = repmat(SEz,size(data,1),1);
    data.SEMnormj = repmat(SEMnormj,size(data,1),1);

    if 1==2
        figure;
        subplot(3,1,1);histogram(data.DV);
        subplot(3,1,2);histogram(data.Ysj); % normalized
        subplot(3,1,3);histogram(data.Zsj); % normalized, Morey-corrected
    end

    %---------------------------------------
    % ALSO CONSIDER
    %The Cousineau–Morey approach introduced an accessibleway to plot error bars of various kinds in mean
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
