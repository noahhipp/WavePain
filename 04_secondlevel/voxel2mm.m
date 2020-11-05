function [mm] = voxel2mm(vox, xSPM)
%function voxel2mm(vox, xSPM)
%
% Use transformation matrix from xSPM to transform coordinate from voxel 
% space to mm space
%
% Expected input:
%   mm:     3 x N matrix. If given as row vector, will be transformed
    
    transpose = false;
    if isrow(vox)
        vox = vox'; 
        transpose = true;
    end
    vox = [vox; ones(1, size(vox, 2))];
    M = xSPM.M;
    mm = M * vox;
    mm = mm(1:3, :);
    if transpose
        mm = mm';
    end

end