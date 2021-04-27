function wave_corrmat_regs

% Plot correlation matrix of regressors

% get regressors
pcs = plot_parametric_contrasts(0);


m = pcs.m_unit(1:55);
w = pcs.w_unit(1:55);
obtb = pcs.obtb(1:55);
tbob = pcs.tbob(1:55);
dsus = pcs.dsus(1:55);
usds = pcs.usds(1:55);
nb = zeros(1,55);

regs = [];
regs(:,1) = [m m w w m w];
regs(:,2) = [tbob obtb tbob obtb nb nb];
regs(:,3) = [dsus dsus usds usds dsus usds];
regs(:,4) = regs(:,1) .* regs(:,2);
regs(:,5) = regs(:,1) .* regs(:,3);
regs(:,6) = regs(:,2) .* regs(:,3);
regs(:,7) = regs(:,1).* regs(:,2) .* regs(:,3);

pmod_names          = {'heat', 'wm', 'slope',...
    'heat X wm', 'heat X slope','wm X slope',...
    'heat X wm X slope'}; % regressor

clims = [-1,1];

% 
save_at = '21_01_20_first_level_pmods';
base_dir = 'C:\Users\hipp\projects\WavePain\results';
save_dir = fullfile(base_dir, save_at);

figure;
for i = 1:7
    subplot(7,1,i);
    plot(regs(:,i));
end

% The whole thing
t = 'all_conditions';
figure;
M = corrcoef(regs);
imagesc(M,clims);
title(t, 'Interpreter', 'none');
colorbar;
xticklabels(pmod_names);
yticklabels(pmod_names);
xtickangle(90);
ax = gca; ax.FontSize = 14;
sfig(fullfile(save_dir, t));

% Split it
split   = 110;
nchunks = size(regs,1)/split;
j       = 0;

for i = 1:2
    if i == 1
        to_take = [1:110, 221:275];
    else
        to_take = [111:220, 276:330];
    end
    j = j+1; start = j;
    j = j+split-1; stop = j;
    t = sprintf('shape_%d', i);
    
    figure;
    M = corrcoef(regs(to_take,:));
    imagesc(M,clims);
    colorbar;
    title(t, 'Interpreter', 'none');
    xticklabels(pmod_names);
    yticklabels(pmod_names);
    xtickangle(90);
    ax = gca; ax.FontSize = 14;
    sfig(fullfile(save_dir, t));
end

function sfig(name)
print(name, '-dpng', '-r300');

