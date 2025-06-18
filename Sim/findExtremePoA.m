function extremeCases = findExtremePoA(M,~,~,~,nList)
    [I,K]=size(M); allP=M(:);
    valid=~isnan(allP)&isfinite(allP);
    [~,ord]=sort(allP(valid),'descend'); idx=find(valid);
    topN=min(10,numel(ord)); extremeCases=cell(topN,1);
    for r=1:topN
      lin=idx(ord(r)); [i,k]=ind2sub([I,K],lin);
      ec.poa=allP(lin); 
      ec.n=nList(k); 
      ec.instance=i;
      extremeCases{r}=ec;
      fprintf('Rank %d: PoA=%.3f | n=%d | inst=%d\n',r,ec.poa,ec.n,ec.instance);
    end
end