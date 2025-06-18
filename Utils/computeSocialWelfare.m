function SW_NE = computeSocialWelfare(D, v, X)
    [n,~] = size(D); SW_NE=0;
    for i=1:n
        ratios = X(i,:)./D(i,:); ratios(D(i,:)==0)=Inf;
        b=min(ratios); if isinf(b), b=0; end
        SW_NE = SW_NE + v(i)*b;
    end
end