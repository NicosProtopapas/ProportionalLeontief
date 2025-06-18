function [u_i, lambda_i, externalityCache] = computeAgentUtility_cached(i, theta, D, externalityCache, config)
    n = length(theta);

    % Allocation with agent i present
    X = mech_ssvcg(D, theta);
    lambda = compute_lambda(X, D);
    lambda_i = lambda(i);
    u_with = theta(i) * sqrt(lambda_i);

    % Use cache if valid
    if isfield(externalityCache, 'valid') && externalityCache.valid(i)
        u_minus = externalityCache.u_minus{i};
    else
        idx = [1:i-1, i+1:n];
        D_minus = D(idx,:);
        theta_minus = theta(idx);
        X_minus = mech_ssvcg(D_minus, theta_minus);
        lambda_minus = compute_lambda(X_minus, D_minus);
        u_minus = theta_minus .* sqrt(lambda_minus);

        externalityCache.u_minus{i} = u_minus;
        externalityCache.valid(i) = true;
    end

    others = [1:i-1, i+1:n];
    p_i = sum(externalityCache.u_minus{i}) - sum(theta(others) .* sqrt(lambda(others)));
    u_i = u_with - p_i;
end
