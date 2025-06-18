function theta = computeSSVCGEquilibriumFromCharacterization(D, v, maxIters, tol, verbose)
% COMPUTESSVCGEQUILIBRIUMFROMCHARACTERIZATION
%   Iteratively computes an approximate equilibrium using the
%   characterization from Lemma 2.
%
% Inputs:
%   D        - n x m demand matrix
%   v        - 1 x n valuation vector
%   maxIters - maximum number of iterations (default: 30)
%   tol      - tolerance for convergence (default: 1e-4)
%   verbose  - if true, prints progress info
%
% Output:
%   theta    - 1 x n equilibrium-like proxy values

if nargin < 3, maxIters = 30; end
if nargin < 4, tol = 1e-4; end
if nargin < 5, verbose = false; end

[n, m] = size(D);
theta = v(:);  % initialize with true values

for iter = 1:maxIters
    theta_old = theta;

    for r = 1:n
        % Solve the optimization: maximize U_r + sum over s≠r of bar(U)
        cvx_begin quiet
            variables X(n,m) lambda(n,1)
            expression sum_other
            sum_other = 0;
            for i = 1:n
                if i ~= r
                    sum_other = sum_other + theta(i) * sqrt(lambda(i));
                end
            end
            maximize( v(r) * lambda(r) + sum_other )
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

        % Estimate theta_r from U_r(x_r) and lambda_r
        min_ratio = min(X(r,:)./D(r,:));
        if isfinite(min_ratio) && min_ratio > 0
            theta(r) = v(r) / sqrt(min_ratio);
        else
            theta(r) = 0;
        end
    end

    delta = norm(theta - theta_old, inf);
    if verbose
        fprintf('Iteration %2d | max θ change: %.4e\n', iter, delta);
    end
    if delta < tol
        break;
    end
end

theta = theta(:)';
end
