function [x, alpha] = mech_conflictDRF(bids, demands, discount)
% PROPORTIONALDRF the mechanism for an n-agent, m-resource system.
%   demands: n-by-m, d_{ij} in [0,1].
%   bids: 1-by-n (or n-by-1).
%
%   x_i = alpha * (b_i / sum_k b_k),
%   alpha = min_j [ sum_i b_i / sum_i (b_i * d_{ij}) ].
%
%   If all(bids)==0, x_i=1/n.
%   discount: 1 --> r_i = sum(demands, 2)
%             2 --> r_i = sqrt(sum(demands,2))
%             3 --> r_i = sum(demands,2)/sqrt(m)
%


    bids = bids(:)'; % make it a row
    %n = length(bids);
    [n,m] = size(demands);
    sumB = sum(bids);
    if all(bids==0)
        x = (1/n)*ones(n,1);
        alpha = 1; 
        return;
    end

    
    switch discount
        case 1
        total_demands = sum(demands, 2);
        normalized_demands = demands ./ total_demands;  % size n×m
        case 2
        total_demands = sqrt(sum(demands, 2));
        normalized_demands = demands ./ total_demands;  % size n×m
        case 3
        total_demands = sqrt(sum(demands.^2, 2));%sqrt(m);
        normalized_demands = demands ./ total_demands;  % size n×m
    end

    temp = normalized_demands' * bids';   % size m×1

    alpha = min(sumB ./ temp);
    normalized_bids = bids./(total_demands)'; % need to make total demands row

    x = alpha * (normalized_bids / sumB);
    x = x(:); % n-by-1
end


