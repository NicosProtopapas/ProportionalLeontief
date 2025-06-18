function [bFinal,X,exitReason,histU] = bestResponseDriver(D,v,config)
    % Handle RNG safely: if a seed is given AND we are not inside parfor, set it.
    if isfield(config, 'seed') && (~isfield(config, 'fromParfor') || ~config.fromParfor)
        rng(config.seed);
    end
    n=length(v);
    perm = randperm(n);  % Random order of agents

    %b=0.5*v;
    b = v .* exp(log(1e-3) + log(1e3) * rand(size(v)));  % range from ~0.001*v to v
    exitReason='maxIters';
    mi=config.bestResponse.maxIters; 
    tol=config.bestResponse.tol;
    method=config.bestResponse.method;
    G=config.bestResponse.gridPoints;
    [X,p]=allocateAndPay(b,D,config);
    u=computeUtility(v,X,p,D);
    histU=zeros(mi+1,n); 
    histU(1,:)=sum(u);
    for it=1:mi
      improved=false;
      %perm = randperm(n);  % Random order of agents
      for i=perm
        curr=u(i); bestU=curr; bestB=b(i);
        if strcmpi(method,'commongrid'), trials=linspace(0,max(v),G);
        else 
            trials=linspace(0,v(i),G); 
        end
        for t=trials
          bC=b; 
          bC(i)=t; 
          [XC,PC] = allocateAndPay(bC,D,config);
          uC=computeUtility(v,XC,PC,D);
          if uC(i)>bestU, bestU=uC(i); bestB=t; end
        end
        if bestU-curr>tol
          b(i)=bestB; improved=true;
          [X,p]=allocateAndPay(b,D,config); u=computeUtility(v,X,p,D);
        end
      end
      histU(it+1,:)=sum(u);
      if ~improved, exitReason='converged'; break; end
    end
    bFinal=b;
end