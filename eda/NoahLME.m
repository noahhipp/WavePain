function NoahLME

    % -----------------------------------
    % -----------------------------------
    % -----------------------------------
    % load existing data
    allLMEs = load("E:\wavepain\data\fmri_sample\eda\all_eda_sampled-at-half-a-hertz_lme.mat");
    allLMEs = allLMEs.lmes;
    lme = allLMEs{3,5}; % designated model        
    T = lme.Variables; % extract variables
    
    % -----------------------------------
    % -----------------------------------
    % -----------------------------------
    % redo LME to check for prerequesites and best model

    % check nesting
    nullLME = fitlme(T,'s_zid_scl ~ 1 + (1|id)','FitMethod','REML','StartMethod','default','CheckHessian',true);
    % this is obviously due to the z scored outcome variables, meaning that BY DEFINITION there can be no nesting

    % get base no-RE model to compare later
    noRELME = fitlme(T,'s_zid_scl ~ 1 + heat*slope + heat*wm_c2 + slope*wm_c2 + heat:slope:wm_c2','FitMethod','REML','StartMethod','default','CheckHessian',true);

    % check RE model
    % current version - actually not working (CheckHessian true) (somewhat unsurprising granted it's z scored data)
    rng(2022)
    rlme = fitlme(T,'s_zid_scl ~ 1 + heat*slope + heat*wm_c2 + slope*wm_c2 + heat:slope:wm_c2 + (1 | id) + (1 + heat | id) + (1 + wm_c2 | id) + (1 + slope | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)

    % check for best-that-we-can-do version
    rng(2022)
    rlme1 = fitlme(T,'s_zid_scl ~ 1 + heat*slope + heat*wm_c2 + slope*wm_c2 + heat:slope:wm_c2 + (-1 + heat | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)
    rng(2022)    
    rlme2 = fitlme(T,'s_zid_scl ~ 1 + heat*slope + heat*wm_c2 + slope*wm_c2 + heat:slope:wm_c2 + (-1 + heat | id) + (-1 + wm_c2 | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)
    rng(2022)
    
    % we use this one!!! as the data was zscored no random intercepts were
    % entered for subject id
    rlme3 = fitlme(T,'s_zid_scl ~ 1 + heat*slope + heat*wm_c2 + slope*wm_c2 + heat:slope:wm_c2 + (-1 + heat | id) + (-1 + wm_c2 | id) + (-1 + slope | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)
    rlme3b = fitlme(T,'s_zid_scl ~ heat*slope*wm_c2 + (-1 + heat | id) + (-1 + wm_c2 | id) + (-1 + slope | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)
    rlme3c = fitlme(T,'s_zid_scl ~ heat*slope*wm_c2 + (-1 + heat | id) ','FitMethod','REML','StartMethod','random','CheckHessian',true)
    rlme3d = fitlme(T,'s_zid_scl ~ heat*slope*wm_c2 + (-1 + wm_c2 | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)
    rlme3e = fitlme(T,'s_zid_scl ~ heat*slope*wm_c2 + (-1 + slope | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)
    
    rlme3noRE = fitlme(T,'s_zid_scl ~ heat*slope*wm_c2','FitMethod','REML','StartMethod','random','CheckHessian',true)
    rlme3rev = fitlme(T,'s_zid_scl ~ heat*slope*wm_c2 + (-1 + heat | id) + (-1 + slope | id)','FitMethod','REML','StartMethod','random','CheckHessian',true)
    
%     % just to test whether my notation is equivalent   
%     rlme4 = fitlme(T, 's_zid_scl ~ heat*wm_c2*slope + (heat
%    
    compare(noRELME,rlme1) 
    compare(rlme1,rlme2)
    compare(rlme2,rlme3) % => rlme3 superior, so we proceed with this model!

    % chosen model, RANDOM SLOPE ONLY model
    rlme = rlme3; 


    % -----------------------------------
    % -----------------------------------
    % -----------------------------------
    % strategy 1: plot effects from betas & REs (FAILED ATTEMPT something is wrong but I don't want to spend more time on it ATM)
    
    % fixed and random effects
    sbFEs = fixedEffects(rlme);
    [sbREs,bn] = randomEffects(rlme); % right
    ix_heat = cellfun(@(x) strcmp(x,'heat'),bn.Name); % because order is not always stable, we cannot rely on indices (e.g. 1:2:end)
    ix_wm_c2_notask = cellfun(@(x) strcmp(x,'wm_c2_notask'),bn.Name); % because order is not always stable, we cannot rely on indices (e.g. 1:2:end) 
    ix_wm_c2_1back = cellfun(@(x) strcmp(x,'wm_c2_1back'),bn.Name); % because order is not always stable, we cannot rely on indices (e.g. 1:2:end) 
    ix_slope = cellfun(@(x) strcmp(x,'slope'),bn.Name); % because order is not always stable, we cannot rely on indices (e.g. 1:2:end) 
    
    % extract random effects
    sbREs_heat = sbREs(ix_heat); % subject-specific random intercepts
    sbREs_wm_c2_notask = sbREs(ix_wm_c2_notask); % subject-specific random slopes for Segment
    sbREs_wm_c2_1back = sbREs(ix_wm_c2_1back); % subject-specific random slopes for Segment
    sbREs_slope = sbREs(ix_slope); % subject-specific random slopes for Segment
    
    subT = T(T.id==5 & T.trial==3,:); % M shape, 1back => 2back
    subT = T(T.id==5 & T.trial==4,:); % W shape, 2back => 1back
    subT = T(T.id==5 & T.trial==5,:); % M shape, 1back => 2back
    subT = T(T.id==5 & T.trial==6,:); % W shape, 2back => 1back
    
    % ...
    subT = T(T.id==5 & T.trial==3,:); % M shape, 1back => 2back
    slope = subT.slope';
    wm_c2_notask = double(subT.wm_c2=='notask')';
    wm_c2_1back = double(subT.wm_c2=='1back')';
    heat = subT.heat';
    yHat_1 = sbFEs(1) + ... % intercept
           sbFEs(2).*heat.*sbREs_heat + ... % ME; heat with random slope
           sbFEs(3).*slope.*sbREs_slope + ... % ME; slope with random slope
           sbFEs(4).*wm_c2_notask.*sbREs_wm_c2_notask + ... % ME
           sbFEs(5).*wm_c2_1back.*sbREs_wm_c2_1back + ... % ME 
           sbFEs(6).*heat.*sbREs_heat .* slope.*sbREs_slope + ... % 2way
           sbFEs(7).*heat.*sbREs_heat .* wm_c2_notask.*sbREs_wm_c2_notask + ... % 2way
           sbFEs(8).*heat.*sbREs_heat .* wm_c2_1back.*sbREs_wm_c2_1back + ... % 2way
           sbFEs(9).*slope.*sbREs_slope .* wm_c2_notask.*sbREs_wm_c2_notask + ... % 2way
           sbFEs(10).*slope.*sbREs_slope .* wm_c2_1back.*sbREs_wm_c2_1back + ... % 2way 
           sbFEs(11).*heat.*sbREs_heat .* slope.*sbREs_slope .* wm_c2_notask.*sbREs_wm_c2_notask + ... % 3way
           sbFEs(12).*heat.*sbREs_heat .* slope.*sbREs_slope .* wm_c2_1back.*sbREs_wm_c2_1back; % 3way
    % ...
    subT = T(T.id==5 & T.trial==4,:); % W shape, 2back => 1back
    slope = subT.slope';
    wm_c2_notask = double(subT.wm_c2=='notask')';
    wm_c2_1back = double(subT.wm_c2=='1back')';
    heat = subT.heat';
    yHat_2 = sbFEs(1) + ... % intercept
           sbFEs(2).*heat.*sbREs_heat + ... % heat with random slope
           sbFEs(3).*slope.*sbREs_slope + ... % slope with random slope
           sbFEs(4).*wm_c2_notask.*sbREs_wm_c2_notask + ... % zero
           sbFEs(5).*wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(6).*heat.*sbREs_heat .* slope.*sbREs_slope + ... % 
           sbFEs(7).*heat.*sbREs_heat .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(8).*heat.*sbREs_heat .* wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(9).*slope.*sbREs_slope .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(10).*slope.*sbREs_slope .* wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(11).*heat.*sbREs_heat .* slope.*sbREs_slope .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(12).*heat.*sbREs_heat .* slope.*sbREs_slope .* wm_c2_1back.*sbREs_wm_c2_1back; %  
    % ...
    subT = T(T.id==5 & T.trial==5,:); % M shape, 1back => 2back
    slope = subT.slope';
    wm_c2_notask = double(subT.wm_c2=='notask')';
    wm_c2_1back = double(subT.wm_c2=='1back')';
    heat = subT.heat';
    yHat_3 = sbFEs(1) + ... % intercept
           sbFEs(2).*heat.*sbREs_heat + ... % heat with random slope
           sbFEs(3).*slope.*sbREs_slope + ... % slope with random slope
           sbFEs(4).*wm_c2_notask.*sbREs_wm_c2_notask + ... % zero
           sbFEs(5).*wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(6).*heat.*sbREs_heat .* slope.*sbREs_slope + ... % 
           sbFEs(7).*heat.*sbREs_heat .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(8).*heat.*sbREs_heat .* wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(9).*slope.*sbREs_slope .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(10).*slope.*sbREs_slope .* wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(11).*heat.*sbREs_heat .* slope.*sbREs_slope .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(12).*heat.*sbREs_heat .* slope.*sbREs_slope .* wm_c2_1back.*sbREs_wm_c2_1back; %  
    % ...
    subT = T(T.id==5 & T.trial==6,:); % W shape, 2back => 1back
    slope = subT.slope';
    wm_c2_notask = double(subT.wm_c2=='notask')';
    wm_c2_1back = double(subT.wm_c2=='1back')';
    heat = subT.heat';
    yHat_4 = sbFEs(1) + ... % intercept
           sbFEs(2).*heat.*sbREs_heat + ... % heat with random slope
           sbFEs(3).*slope.*sbREs_slope + ... % slope with random slope
           sbFEs(4).*wm_c2_notask.*sbREs_wm_c2_notask + ... % zero
           sbFEs(5).*wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(6).*heat.*sbREs_heat .* slope.*sbREs_slope + ... % 
           sbFEs(7).*heat.*sbREs_heat .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(8).*heat.*sbREs_heat .* wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(9).*slope.*sbREs_slope .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(10).*slope.*sbREs_slope .* wm_c2_1back.*sbREs_wm_c2_1back + ... % 
           sbFEs(11).*heat.*sbREs_heat .* slope.*sbREs_slope .* wm_c2_notask.*sbREs_wm_c2_notask + ... % zero 
           sbFEs(12).*heat.*sbREs_heat .* slope.*sbREs_slope .* wm_c2_1back.*sbREs_wm_c2_1back; %  
    
    figure;
    axes;
    title('M')
    hold on;
    plot(mean(yHat_1,1),'LineWidth',2);
    plot(mean(yHat_3,1),'LineWidth',2);
    legend({'M 1=>2','M 2=>1'},'Location','northwest')
    xlabel('Time');
    ylabel('SCL');
    
    figure;
    axes;
    title('W')
    hold on;
    plot(mean(yHat_2,1),'LineWidth',2);
    plot(mean(yHat_4,1),'LineWidth',2);
    legend({'W 1=>2','W 2=>1'},'Location','northwest')
    xlabel('Time');
    ylabel('SCL');


    % -----------------------------------
    % -----------------------------------
    % -----------------------------------
    % strategy 2: plot effects from predict (discarded 1st level variance via trial<=6)
    
    P = predict(rlme);
    
    ix1 = (T.condition==1 & T.trial<=6); % M shape, 2back => 1back
    subP1 = reshape(P(ix1),55,numel(unique(T.id(ix1))));
    
    ix2 = (T.condition==2 & T.trial<=6); % M shape, 1back => 2back
    subP2 = reshape(P(ix2),55,numel(unique(T.id(ix2))));
    
    ix3 = (T.condition==3 & T.trial<=6); % W shape, 2back => 1back
    subP3 = reshape(P(ix3),55,numel(unique(T.id(ix3))));
    
    ix4 = (T.condition==4 & T.trial<=6); % W shape, 1back => 2back
    subP4 = reshape(P(ix4),55,numel(unique(T.id(ix4))));
    
    figure;
    axes;
    title('M')
    hold on;
    plot(mean(subP1,2),'LineWidth',2);
    plot(mean(subP2,2),'LineWidth',2);
    legend({'2=>1','1=>2'},'Location','northwest')

    figure;
    axes;
    title('W')
    hold on;
    plot(mean(subP3,2),'LineWidth',2);
    plot(mean(subP4,2),'LineWidth',2);
    legend({'2=>1','1=>2'},'Location','south')
    





