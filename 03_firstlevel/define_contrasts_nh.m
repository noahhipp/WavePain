function define_contrasts_nh


% Collect host (could obviously factor this out into a function or even
% property of a class but 
hostname =  char(getHostName(java.net.InetAddress.getLocalHost));
switch hostname
    case 'DESKTOP-3UBJ04S'
        base_dir          = 'C:\Users\hipp\projects\WavePain\data\fmri\fmri_temp\';
        n_proc            = 2;
    case 'revelations'
        base_dir          = '/projects/crunchie/hipp/wavepain/';
        n_proc            = 1;
    otherwise
        error('Only hosts noahs isn laptop accepted');
end

do_cons = 1;
subs = 10;

% Housekeeping
ana_dirname     = 'fir_firstlevel';



for i = 1:numel(subs)
    name = sprintf('sub%03d',subs(i));
    fprintf(['Doing volunteer ' name '\n']);
    ana = fullfile(base_dir, name, ana_dirname, 'SPM.mat');
    
    template = [];
        template.spm.stats.con.spmmat = {ana};
        template.spm.stats.con.delete = 1;

        c = 0;
        for c = 1:360 % oder b oder was
                template.spm.stats.con.consess{c}.tcon.name    = sprintf('c%d',c);
                template.spm.stats.con.consess{c}.tcon.convec  = DER CON VECTOR DEN WIR DEFINIERT HAM;
                template.spm.stats.con.consess{c}.tcon.sessrep = 'none'; % k.a. was das ist
        end

        if do_cons            
            matlabbatch{i} = template; %now add contrasts
        end
    
end


spm_jobman('run', matlabbatch);
