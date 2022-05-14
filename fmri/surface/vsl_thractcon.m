% No help function yet. Please get back to me.
% 
% TODO: This is an awkward detour via a thresholded contrast, so we effectively do a double threshold.
%       Consider the option to directly use T/F maps instead.
%
%__________________________________________________________________________
% 
% Bjoern Horing

function varargout = vsl_thractcon(statForBars,thrType,svc) 
    % varargin{1} statForBars
    % varargin{2} 'unc'|'none' for thr=xSPM.u, 'fwe' for xSPM.uc(1), 'fdr' for xSPM.uc(2)
    % varargin[3} - if set, will use TabDat data; if image, will use image as mask to constrain export

    saveAsGii = 1; % default 1; only required if isSurf (to distinguish from "data vector only"-export
    
    if ~nargin 
        statForBars = 1; % default 2; 0 = binary, 1 = -logP, 2 = Z
    end    
    if exist('thrType','var') && strcmp(thrType,'fwe') && exist('svc','var')
        error('SVC will only do MASKING, not correction. Use vsl_SOI first, but REMEMBER TO USE PROPER RESELS!');
    end        
    
    % REVISE
    if statForBars==0
        statTag = 'binary';        
    elseif statForBars==1
        statTag = 'logP';
    elseif statForBars==2
        statTag = 'Z';
    else
        error('Unknown statistic requested.');
    end

    xSPM = evalin('base','xSPM');
    cd(xSPM.swd);    
    
%     also try spm_mesh_detect(xCon(Ic(1)).Vspm)
    if isfield(xSPM,'G') % regexp(xSPM.Vspm(1).fname,'\.gii$','ONCE')
        isSurf = 1;
        cE = '.gii';
    elseif regexp(xSPM.Vspm(1).fname,'\.nii$','ONCE') % well alright, let's be thorough
        isSurf = 0;
        cE = '.nii';
    else
        warning('Contrast has unknown file format. Aborting.');
        return;
    end    
    
    if nargin>2
        % then we have the case of an SVC/SSC applied to the TabDat, but not necessarily to 
        % the xSPM; this means that effectively, whatever is in xSPM is pretty much irrelevant,
        % so we overwrite it with TabDat data or original data from the spmT/spmF file;
        % only basic info like STAT etc is preserved (essentially, whatever we can't get or
        % corroborate from TabDat, which has updated during SVC/SSC)        
        TabDat = evalin('base','TabDat');
        if isSurf
            if numel(xSPM.Vspm)==1 
                tmp = gifti(xSPM.Vspm.fname); 
                tmp = double(tmp.cdata); % if we don't convert it, it just provides the .dat reference
            else % then we have a conjunction we first have to export: iterate without svc; 2021-08-11
                warning('Trying to apply SSC on conjunction, so we need to extract the data first.');
                [~,tmp] = vsl_thractcon(statForBars,'none');
                tmp(isnan(tmp)) = 0;
            end            
            svcTag = '.ssc';
        else % not implemented
%             error('SVC functionality not implemented yet.');
            tmp = nifti(xSPM.Vspm.fname);
            tmp = double(tmp.dat);
            svcTag = '.svc';
        end
        xSPM.Z = tmp;

        xSPM.u = TabDat.ftr{1,2}(1); % the SVC/SSC derived threshold
        xSPM.uc = TabDat.ftr{5,2}(1:2); % the SVC/SSC derived threshold
        xSPM.df = TabDat.ftr{6,2};
        xSPM.FWHM = TabDat.ftr{7,2}(1); % cosmetic only
        xSPM.XYZ = [];
        xSPM.XYZ(1:3,1:numel(tmp)) = [1:numel(tmp);ones(1,numel(tmp));ones(1,numel(tmp))];
    else
        svcTag = '';
    end
    
    if nargin<2 % then we use the active contrast's alpha correction
        thrType = lower(cell2mat(regexp(xSPM.thresDesc,'(?<=\().{3}(?=\.*\))','MATCH'))); 
        if isempty(thrType)
            if ~isempty(regexp(xSPM.thresDesc,'T=\d\.\d{3}','ONCE'))
                thrType = 'unc';
                warning('Threshold type not recognized in xSPM.thresDesc=''%s'', set to ''unc''.',xSPM.thresDesc);
            else
                error('Threshold type not recognized.');
            end
        end
    end
    
    % check if we want to use uncorrected or corrected thresholds
    % obtain T or F threshold
    if strcmpi(thrType,'unc') || strcmp(thrType,'none') 
        thr = xSPM.u;
    elseif strcmpi(thrType,'fwe')
        thr = xSPM.uc(1); % why does this work? because xSPM.uc(1) is FWE=.05 by default; if you need any other FWE correction, xSPM.u would probably work BUT NOT with SSC
        % for example, by using manual (GUI) setting, uc(1) stays the same
%         thresDesc: 'p<0.05 (FWE)'
%         u: 7.83
%         uc: [7.83 9.6353 1 39]
% 
%         thresDesc: 'p<0.001 (unc.)'
%         u: 4.1303
%         uc: [7.83 6.8227 172 88]
% 
%         thresDesc: 'p<0.01 (FWE)'
%         u: 8.6287
%         uc: [7.83 10.518 1 10]
    elseif strcmpi(thrType,'fdr')
        thr = xSPM.uc(2);
    end
    
    % obtain critical p value                
    if strcmp(xSPM.STAT,'T')
        thr = 1-tcdf(thr,xSPM.df(2));
    else
        thr = 1-spm_Fcdf(thr,xSPM.df(1),xSPM.df(2));
    end    
    
    thrStr = sprintf('%1.3f',thr);   
    thrStr = regexprep(thrStr,'\.','pt');

    if strcmp(thrType,'fwe')
        thrTag = '.thr@0pt05fwe';
    else
        thrTag = [ '.thr@' thrStr thrType ];
    end
    
    skern = floor(xSPM.FWHM(1)); % this is actually not determined here, but only relevant for naming    

    if ~isempty(xSPM.Im) % then the contrast is masked and we add this to the file name
        mskTag = '.msk';
        if ~xSPM.Ex % inclusive mask
            mskTag = [mskTag 'i@'];
        elseif xSPM.Ex % exclusive mask
            mskTag = [mskTag 'e@'];
        else
            warning('Type of mask not recognized (options: incl, excl). Aborting.');
            return;
        end
        
        if isnumeric(xSPM.Im)
            mskThr = [ '.thr@' regexprep(num2str(xSPM.pm),'\.','pt') ];  
            if exist(sprintf('%s%sspmF_%04d%s',xSPM.swd,filesep,xSPM.Im,cE)) % awkward, but I'm not sure if the info which stat type the mask contrast has is readily avl            
%                 mskPath = sprintf('spmF_%04d%s',xSPM.Im,cE);
                mskTag = sprintf('%sspmF_%04d%s',mskTag,xSPM.Im,mskThr);
            elseif exist(sprintf('%s%sspmT_%04d%s',xSPM.swd,filesep,xSPM.Im,cE))
%                 mskPath = sprintf('spmT_%04d%s',xSPM.Im,cE);
                mskTag = sprintf('%sspmT_%04d%s',mskTag,xSPM.Im,mskThr);
            else
                warning(sprintf('Masking contrast spm[TF]_%04d%s could not be identified. Aborting.',xSPM.Im,cE));
                return;
            end         
        elseif iscell(xSPM.Im) % then we were masking by an image, with predefined (and possibly unknowable) threshold
            mskThr = [ '.thr@na' ];  
            [~,tmp,~] = fileparts(cell2mat(xSPM.Im));
%             mskPath = cell2mat(xSPM.Im);
            mskTag = sprintf('%s%s%s',mskTag,tmp,mskThr);
        else
            warning('Masking contrast could not be identified. Applying generic name, danger of overwriting.');
%             mskPath = '';
            mskTag = '.msk';
        end               
    else
%         mskPath = '';
        mskTag = '';
    end
    
    % apply mask to exclude voxels/vertices from export
    % this is not implemented yet, since it would require thresholding of the mask, as well; 
    % use ManualConjunction (or similar) to obtain SVC/SSC masks
%     if ~isempty(mskPath)
%         msk = gifti(mskPath);
%         msk = msk.cdata;            
%         xSPM.Z(isnan(msk)) = NaN; % constrain template vertices to those contained in the mask
%     end
    
    % apply SVC/SSC to exclude voxels/vertices from export
    if nargin>2 && isSurf && ischar(svc) && exist(svc,'file')
        svc = gifti(svc);
        svc = svc.cdata;            
        xSPM.Z(isnan(svc)) = []; % constrain template vertices to those contained in the svc
        xSPM.XYZ = xSPM.XYZ(1:3,~isnan(svc));
    elseif nargin>2 && ~isSurf && ischar(svc) && exist(svc,'file')
        error('This has not been tested yet.');
        svc = nifti(svc);
        svc = svc.dat; 
        xSPM.Z(isnan(svc)) = []; % constrain template vertices to those contained in the svc
        xSPM.XYZ = xSPM.XYZ(1:3,~isnan(svc));
    end
    
    if ~strcmp(statTag,'binary')
        statTag = xSPM.STAT; % OVERRIDE
    end
    
    conType = xSPM.STAT; % regardless of conjunction or not, only one statistic permissible
    if numel(xSPM.Ic)==1
        conTag = sprintf('spm%s_%04d',conType,xSPM.Ic);
        newFName = sprintf('%s%s.s%d.%s%s%s',statTag,svcTag,skern,conTag,thrTag,mskTag);    
    else % then it's likely a conjunction we're dealing with
        conTag = 'conj@';
        for n = 1:numel(xSPM.Ic)
            conTag = [conTag sprintf('spm%s_%04d',conType,xSPM.Ic(n))];
            if n<numel(xSPM.Ic)
                conTag = [conTag '+'];
            end
        end
        newFName = sprintf('%s%s.s%d.%s%s%s',statTag,svcTag,skern,conTag,thrTag,mskTag);    
    end
    
    % YOU KNOW, this is a lot more awkward than it need to be; in fact, xSPM.Z ALREADY contains only voxels/verts>xSPM.u
    % REVISION of the previous line: It doesn't necessarily, if we use TabDat-info for SSC
    dThr = -log10(thr);

    voxSigs = []; % voxel significances, tbd and then to be thresholded
    supraVox = xSPM.Z; % voxels above the xSPM's threshold 
    voxSigs = zeros(numel(supraVox),1); % UPDATE 2021-08-11
    
    if isempty(xSPM.Z)
        warning('No voxels survive. Writing empty volume or surface.');
        voxSigs = [];
    elseif strcmpi(conType,'t')
        df = xSPM.df(2);        
        voxSigs = -log10(max(eps,1-spm_Tcdf(supraVox,df))); % this is done so that if p is zero, we can still compute it (with eps) (note to self: log10. not log.)
        %voxSigs(~isnan(supraVox)) = -log10(max(eps,1-spm_Tcdf(supraVox(~isnan(supraVox)),df))); % UPDATE 2021-08-11
    elseif strcmpi(conType,'f')
        df1 = xSPM.df(1); 
        df2 = xSPM.df(2); 
        voxSigs = -log10(max(eps,1-spm_Fcdf(supraVox,df1,df2))); % this is done so that if p is zero, we can still compute it (with eps) (note to self: log10. not log.)
    end    
       
    voxSigs(voxSigs==0) = NaN;
    if sum(isnan(voxSigs))>0
        warning('Some zero parameters were replaced by NaN.');
    end
    
    if ~statForBars && nargin<3 % then we just set all sigVx to minimum p (~binary export I think 2021-08-05)
        voxSigs = repmat(-log10(eps),size(supraVox));
        supraVox(voxSigs>dThr) = 1;
    end
        
    if isSurf % then it's a SURFACE contrast we want to threshold
        %sigVxNodes = xSPM.XYZ(1,:); % get nodes from significant voxels
        sigVxNodes = xSPM.XYZ(1,voxSigs>dThr); % 2021-08-11
%         synCdata = zeros(size(xSPM.G.vertices,1),1); % instantiate cdata to synthesize
        synCdata = NaN(size(xSPM.G.vertices,1),1); % instantiate cdata to synthesize
        synCdata(sigVxNodes,1) = supraVox(voxSigs>dThr); % populate with logps from significant voxels
%         supraVox
%         synCdata(synCdata<dThr) = NaN; % threshold it
        
%         if ~statForBars && nargin==3
%             synCdata(~isnan(synCdata)) = -log10(eps); % threshold it
%         elseif statForBars==2 % then we want z scores from our -log10(p) 
%             synCdata = icdf('normal',1-(10.^-synCdata),0,1);            
%         end
        
        % determine hemisphere for naming (hemiStr) and template gifti
        if numel(synCdata)==327684
            hemiStr = 'mesh';
            giiTemp = gifti(fullfile(spm('dir'),'toolbox','cat12','templates_surfaces','mesh.central.freesurfer.gii'));
        elseif numel(synCdata)==163842
            hemiStr = 'uh'; % we should be able to find out using the folder name
            error('Don''t know the hemisphere, sorry. Do it manually.');
            %giiTemp = gifti(fullfile(spm('dir'),'toolbox','cat12','templates_surfaces','lh.central.freesurfer.gii'));
        else
            hemiStr = 'uh'; % we should be able to find out using the folder name
            giiTemp = gifti;
        end
        giiTemp.cdata = synCdata; % create or overwrite cdata                                         
        newFName = [hemiStr '.' newFName];
        
        if saveAsGii % SOMETHING IS WRONG WITH THIS! DO NOT USE ATM
            save(giiTemp,sprintf('%s%s%s.gii',xSPM.swd,filesep,newFName),'Base64Binary');
            fprintf('Thresholded contrast saved as %s%s%s.gii.\n',xSPM.swd,filesep,newFName);
        else % then we save it as a simple data vector
            cdata = synCdata;
            save(sprintf('%s%s%s.mat',xSPM.swd,filesep,newFName),'cdata');
            fprintf('Thresholded contrast saved as %s%s%s.mat.\n',xSPM.swd,filesep,newFName);
        end            
    else % then it's a VOLUME contrast
        sigVxCo = xSPM.XYZ(1:3,:); % get coordinates from significant voxels
        synCdata = zeros(xSPM.Vspm(1).dim); % instantiate; not sure if this is necessarily valid for conjunctions/with numel(xSPM.Vspm)>1, but it seems likely

% OLD APPROACH
%         error('TRY AGAIN - this next step takes forever')
% tic
%         for s = 1:size(sigVxCo,2) % there should be a way to do proper vector indexing here, but I can't figure it out atm
%             synCdata(sigVxCo(1,s),sigVxCo(2,s),sigVxCo(3,s)) = sigVx(s); % populate with significant voxels
%         end    
%    toc         

% WRONG ALTERNATIVE
%    synCdata(sigVxCo(1,:),sigVxCo(2,:),sigVxCo(3,:)) = sigVx(:); % populate with significant voxels

% WRONG ALTERNATIVE
%    synCdata(sigVxCo(1,:)) = sigVx(:); % populate with significant voxels
        
        % from cat_stat_spm2x
        OFF    = sigVxCo(1,:) + xSPM.Vspm(1).dim(1)*(sigVxCo(2,:)-1 + xSPM.Vspm(1).dim(2)*(sigVxCo(3,:)-1));
        synCdata(OFF) = voxSigs(:);
        synCdata(synCdata<dThr) = NaN;
        
        [~,f,e] = fileparts(sprintf('%s.nii',sprintf('spm%s_%04d',conType,xSPM.Ic(1))));
        copyfile([f,e],sprintf('%s.nii',newFName))
        newF=spm_vol(sprintf('%s.nii',newFName));
        
        % THIS WORKS
        synCdata=squeeze(synCdata); % squeeze or die!
        spm_write_vol(newF,synCdata);        
        fprintf('Thresholded contrast saved as %s%s%s.nii.\n',xSPM.swd,filesep,newFName);
        
        % THIS WORKS TOO (from cat12)
%         VO = xSPM.Vspm(1);
%         VO.fname = [xSPM.swd filesep newFName '.nii'];%Pname{i};
%         VO.dt = [spm_type('float32') spm_platform('bigend')];
% 
%         VO = spm_data_hdr_write(VO);
%         spm_data_write(VO,synCdata);%spm_data_write(VO,Y);        
    end    
    
    if nargout==1
        varargout{1} = sprintf('%s%s%s%s',xSPM.swd,filesep,newFName,cE);
    elseif nargout==2
        varargout{1} = sprintf('%s%s%s%s',xSPM.swd,filesep,newFName,cE);
        varargout{2} = synCdata;
    end
    