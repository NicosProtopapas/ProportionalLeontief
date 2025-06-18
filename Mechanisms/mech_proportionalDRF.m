function [x, alpha] = mech_proportionalDRF(b, D, exp)
% MECH_PROPORTIONALDRF
%   Proportional DRF allocation mechanism with optional exponent.
%
%   Inputs:
%     b   - n×1 bid vector (must be column)
%     D   - n×m demand matrix (each row: demands of agent i)
%     exp - scalar exponent (>0) for weighting bids
%
%   Outputs:
%     x      - n×1 base allocation shares
%     alpha  - DRF scaling factor (tightest bottleneck)

    % Ensure input shapes
    b = b(:);  % force column vector

    if all(b == 0)
        % If all bids are zero, split equally
        n = length(b);
        x = (1/n) * ones(n, 1);
        alpha = 1;
        return;
    end

    % Step 1: Apply exponent to bids
    if exp~=1
        w = b.^exp;    % n×1 vector: weighted bids
    else
        w=b;
    end
    % Step 2: Total weight
    S = sum(w);    % scalar: total weight

    % Step 3: Compute resource usage
    %   D' has size m×n
    %   w has size n×1
    %   usage = D' * w  → m×1
    usage = D' * w;

    % Step 4: Compute alpha
    %   For each resource j, available budget = S
    %   Effective load on resource j = usage(j)
    alpha = min(S ./ usage);  % scalar

    % Step 5: Compute final shares
    %   x(i) = proportional share for agent i
    x = alpha * (w / S);
    x = x(:);  % force output as column
end
