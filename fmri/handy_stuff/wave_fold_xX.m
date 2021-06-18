function X =wave_fold_xX(X, hrf, n_conds)
% Loop through matrix and fold with hrf


for i = 1:size(X,2) % col loop start
    
    % Select column
    col = X(:,i);
    
    % Make column iterable
    col = reshape(col, [], n_conds);
    
    
    for j = 1:size(col,2) % loop through col
        
        convolved = conv(col(:,j),hrf);       
        col(:,j) = convolved(1:size(col,1));
    end
    
    % Reshape column again
    col = reshape(col, [],1);
    X(:,i) = col;
end
    
        
    