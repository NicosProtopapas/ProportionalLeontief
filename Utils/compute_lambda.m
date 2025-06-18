function lambda = compute_lambda(X, D)
% Compute lambda_i = min_j x_ij / d_ij for each agent i
[n, ~] = size(D);
lambda = zeros(n,1);
ratios = X ./ D;
ratios(D == 0) = inf;
lambda = min(ratios, [], 2);
lambda(isinf(lambda)) = 0;
end
