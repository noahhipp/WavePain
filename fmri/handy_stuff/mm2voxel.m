function [vox] = mm2voxel(mm, xSPM)
%function mm2voxel(mm, xSPM)
%
% Use transformation matrix from xSPM to transform coordinate from mm space
% to voxel space
%
% Expected input:
%   mm:     3 x N matrix. If given as row vector, will be transformed
    
    transpose = false;
    if isrow(mm)
        mm = mm'; 
        transpose = true;
    end
    mm = [mm; ones(1, size(mm, 2))];
    iM = xSPM.iM;
    vox = iM * mm;
    vox = vox(1:3, :);        
    if transpose
        vox = vox';
    end
    
    

end