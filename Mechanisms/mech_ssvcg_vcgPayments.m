function [X, p] = mech_ssvcg_vcgPayments(D, theta)
% MECH_SSVCG_VCGPAYMENTS: SSVCG allocation and VCG-like payments
% The mechanism uses theta_i sqrt(\cdot) as a proxy to agents valuation
% Inputs:
%   D     - n×m demand matrix
%   theta - 1×n vector of scalar reports
% Outputs:
%   X     - n×m allocation matrix
%   p     - 1×n vector of payments

n = size(D,1);
theta = theta(:);  % ensure column

% Step 1: full allocation
X = mech_ssvcg(D, theta);
lambda = compute_lambda(X, D);
u = theta .* sqrt(lambda);  % full utility

% Step 2: compute payments
p = zeros(1,n);
for r = 1:n
    keep = true(n,1); keep(r) = false;
    D_minus = D(keep,:);
    theta_minus = theta(keep);

    X_minus = mech_ssvcg(D_minus, theta_minus);
    lambda_minus = compute_lambda(X_minus, D_minus);
    u_minus = theta_minus .* sqrt(lambda_minus);
    
    % VCG payment = externality caused to others
    p(r) = sum(u_minus) - sum(u(keep));
end
end

