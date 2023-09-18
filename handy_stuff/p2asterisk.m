function out = p2asterisk(p)

out = '';
thr = [0.05, 0.01, 0.001];

for i = 1:numel(thr)
    if p <= thr(i)
        out = [out '*'];
    end
end
