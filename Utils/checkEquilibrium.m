function [isEquilibrium, bestDeviations] = checkEquilibrium(v, D, bids, config, tol)
% CHECKEQUILIBRIUM
%   Checks if the bids form a pure Nash equilibrium.
%
% Inputs:
%   v      - n×1 valuations
%   D      - n×m demand matrix
%   bids   - n×1 bid vector (known, given)
%   config - config structure (mechanism info)
%   tol    - tolerance for deviation improvement
%
% Outputs:
%   isEquilibrium - true if no agent can improve beyond tol
%   bestDeviations - best deviation utility for each agent

    % Force column shapes
    v = v(:);
    bids = bids(:);
    n = length(v);

    % Compute allocation and utility under current bids
    [X, p] = allocateAndPay(bids, D, config);
    uOrig = computeUtility(v, X, p, D);

    bestDeviations = zeros(n, 1);

    for i = 1:n
        currUtility = uOrig(i);
        bestUtility = currUtility;

        % Build grid for deviations
        if strcmpi(config.bestResponse.method, 'commongrid')
            trials = linspace(0, max(v), config.bestResponse.gridPoints);
        else
            trials = linspace(0, v(i), config.bestResponse.gridPoints);
        end

        for t = trials
            bTest = bids;
            bTest(i) = t;

            [Xtest, pTest] = allocateAndPay(bTest, D, config);
            uTest = computeUtility(v, Xtest, pTest, D);

            if uTest(i) > bestUtility
                bestUtility = uTest(i);
            end
        end

        bestDeviations(i) = bestUtility;

        % If a profitable deviation exists
        if bestUtility > currUtility + tol
            isEquilibrium = false;
            return;
        end
    end

    isEquilibrium = true;
end
