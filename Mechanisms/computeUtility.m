function u = computeUtility(v, X, p, D)
    % Get dimensions
    [n, m] = size(D);
    % Force correct shapes
    %v = reshape(v, n, 1);        % n x 1
    %p = reshape(p, n, 1);        % n x 1
    %X = reshape(X, n, m);        % n x m

    % Compute Leontief ratios
    ratios = X ./ D;
    ratios(D == 0) = Inf;

    % Get min scaling factor
    b = min(ratios, [], 2);      % n x 1
    b(isinf(b)) = 0;

    

    % Compute utility
    u = v .* b - p;              % n x 1
    u = u';                      % 1 x n row vector
end
