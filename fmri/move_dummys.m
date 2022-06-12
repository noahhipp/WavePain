function move_dummys

go_back = pwd;
subs = 47:48;

base_dir          = '/projects/crunchie/hipp/wavepain/';
run_dir            = {'run001/mrt/dummy/', 'run002/mrt/dummy/'};

for sub = subs
    name = sprintf('sub%03d',sub');
    for run = run_dir
        path = fullfile(base_dir, name, run);
        cd(path{1});
        for i = 6:10
            fname = sprintf('fPRISMA*%02d-01.nii', i);
            fname = fullfile(path,fname);
            unix(sprintf('mv %s ./..', fname{1}));
        end
    end
end

cd(go_back);