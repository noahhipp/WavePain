function Z = naninterp(V)
% Thanks to Stephen23: 
% https://de.mathworks.com/matlabcentral/answers/408164-how-to-interpolate-at-nan-values

if isrow(V)
    transpose = 0;    
elseif iscolumn(V)
    transpose = 1;
    V = V';
else
    error('this will only work on rows or cols, not matrices')
end


X = ~isnan(V);
Y = cumsum(X-diff([1,X])/2);
Z = interp1(1:nnz(X),V(X),Y);

if transpose
    Z = Z';
end