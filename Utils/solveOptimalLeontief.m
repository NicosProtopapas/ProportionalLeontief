function [SW,alpha,Xopt] = solveOptimalLeontief(D,v)
    [n,m] = size(D);
    f = -v(:);
    A = D'; 
    b = ones(m,1);
    lb = zeros(n,1);
    ub = ones(n,1);  % Prevent unbounded utility
    
    opts = optimoptions('linprog','Display','none');
    [alpha,fv] = linprog(f,A,b,[],[],lb,ub,opts);
    
    SW = -fv;
    Xopt = alpha .* D;
end
