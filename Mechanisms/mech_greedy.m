function x = mech_greedy(b, D)
    % Inputs:
    %   b - n x 1 vector of scalar bids
    %   D - n x m matrix of resource demands
    % Output:
    %   x - n x 1 allocation vector
    
    b = b(:); % ensure column 
    [n, m] = size(D);
    x = zeros(n, 1);                     % Initialize allocation
    used = zeros(1, m);                 % Track used capacity per resource

    % Compute cost for each agent (sum of demands)
    cost = sum(D, 2);                   % n x 1 vector
    rho = b ./ cost;                   % Efficiency score

    % Sort agents by decreasing efficiency
    [~, idx] = sort(rho, 'descend');

    for k = 1:n
        i = idx(k);                    % Agent in sorted order

        % Compute max feasible x_i under all resource constraints
        xi_max = 1;                    % Upper bound on allocation
        for j = 1:m
            if D(i,j) > 0
                xi_max_j = (1 - used(j)) / D(i,j);
                xi_max = min(xi_max, xi_max_j);
            end
        end

        % Assign the feasible allocation
        xi = min(1, max(0, xi_max));  % Bound to [0,1]
        x(i) = xi;

        % Update used capacity
        used = used + xi * D(i,:);
    end
    x = x(:);
end
