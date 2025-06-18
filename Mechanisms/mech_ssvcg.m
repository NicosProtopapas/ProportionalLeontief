function X = mech_ssvcg(D, theta)
% MECH_SSVCG  SSVCG allocation based on proxy utility θ_i * sqrt(min_j x_ij / d_ij)
% Inputs:
%   D     - n×m demand matrix
%   theta - 1×n vector of scalar reports
% Output:
%   X     - n×m allocation matrix (Leontief-style)

[n, m] = size(D);
theta = theta(:);  % ensure column

cvx_begin quiet
    variables X(n,m) lambda(n,1)
    maximize( sum(theta .* sqrt(lambda)) )
    subject to
        for i = 1:n
            for j = 1:m
                X(i,j) >= lambda(i) * D(i,j);
            end
        end
        for j = 1:m
            sum(X(:,j)) <= 1;
        end
        X >= 0
        lambda >= 0
cvx_end
end
