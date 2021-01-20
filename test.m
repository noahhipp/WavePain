matlabbatch{1}.spm.stats.fmri_spec.dir = {'/home/hipp'};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = {
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,1'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,2'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,3'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,4'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,5'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,6'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,7'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,8'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,9'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,10'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,11'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,12'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,13'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,14'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,15'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,16'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,17'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,18'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,19'
                                                 '/projects/crunchie/hipp/wavepain/sub016/run001/mrt/srafMRI.nii,20'
                                                 };
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.name = 'pain';
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.onset = [0
                                                      0.5
                                                      1
                                                      1.5
                                                      2
                                                      2.5
                                                      3
                                                      3.5
                                                      4
                                                      4.5
                                                      5
                                                      5.5
                                                      6
                                                      6.5
                                                      7
                                                      7.5
                                                      8
                                                      8.5
                                                      9
                                                      9.5
                                                      10
                                                      10.5
                                                      11
                                                      11.5
                                                      12
                                                      12.5
                                                      13
                                                      13.5
                                                      14
                                                      14.5
                                                      15
                                                      15.5
                                                      16
                                                      16.5
                                                      17
                                                      17.5
                                                      18
                                                      18.5
                                                      19
                                                      19.5
                                                      20];
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod.name = 'wave';
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod.param = [0.814723686393179
                                                           0.905791937075619
                                                           0.126986816293506
                                                           0.913375856139019
                                                           0.63235924622541
                                                           0.0975404049994095
                                                           0.278498218867048
                                                           0.546881519204984
                                                           0.957506835434298
                                                           0.964888535199277
                                                           0.157613081677548
                                                           0.970592781760616
                                                           0.957166948242946
                                                           0.485375648722841
                                                           0.8002804688888
                                                           0.141886338627215
                                                           0.421761282626275
                                                           0.915735525189067
                                                           0.792207329559554
                                                           0.959492426392903
                                                           0.655740699156587
                                                           0.0357116785741896
                                                           0.849129305868777
                                                           0.933993247757551
                                                           0.678735154857773
                                                           0.757740130578333
                                                           0.743132468124916
                                                           0.392227019534168
                                                           0.655477890177557
                                                           0.171186687811562
                                                           0.706046088019609
                                                           0.0318328463774207
                                                           0.27692298496089
                                                           0.0461713906311539
                                                           0.0971317812358475
                                                           0.823457828327293
                                                           0.694828622975817
                                                           0.317099480060861
                                                           0.950222048838355
                                                           0.0344460805029088
                                                           0.438744359656398];
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.orth = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 360;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
