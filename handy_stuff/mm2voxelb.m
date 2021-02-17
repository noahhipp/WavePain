function XYZvox = mm2voxelb(XYZmm, xSPM)
% 

disp(XYZmm);
[XYZmm,~] = spm_XYZreg('RoundCoords',XYZmm,xSPM.M,xSPM.DIM);
XYZvox = [XYZmm' 1]*(inv(xSPM.M))';
XYZvox(:,4) = []; 
disp(XYZvox);
