function aggregate_masks


matlabbatch{1}.spm.util.imcalc.input = {
                                        '/projects/crunchie/hipp/wavepain/sub005/fir/mask.nii,1'
                                        '/projects/crunchie/hipp/wavepain/sub006/fir/mask.nii,1'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'AND_mask';
matlabbatch{1}.spm.util.imcalc.outdir = {'/projects/crunchie/hipp/wavepain'};
matlabbatch{1}.spm.util.imcalc.expression = 'all(X)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
