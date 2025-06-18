function [D,v] = dataGenerator(n,m,config)
    vt = lower(config.dataGeneration.valuationsDistribution);
    vp = config.dataGeneration.valuationsParams;
    switch vt
      case 'uniform', v = vp.min + (vp.max-vp.min).*rand(1,n);
      case 'pareto', U=rand(1,n); v = vp.x_m ./ (U.^(1/vp.alpha));
      otherwise, error('Unknown valuationsDistribution');
    end
    dt = lower(config.dataGeneration.demandsDistribution);
    dp = config.dataGeneration.demandsParams;
    switch dt
      case 'uniform', D = rand(n,m);
        if isfield(dp,'normalizeEachAgent')&&dp.normalizeEachAgent
          mx=max(D,[],2); mx(mx==0)=1; D=D./mx;
        end
      case 'correlated'
        Sigma = dp.correlationMatrix; mu=zeros(1,m);
        if isfield(dp,'mean'), mu=dp.mean; end
        P = mvnrnd(mu,Sigma,n);
        if isfield(dp,'transform')&&strcmpi(dp.transform,'logistic')
          D=1./(1+exp(-P)); else D=P; end      

      case 'binary'
        if isfield(dp,'numOnes')
          k=dp.numOnes; D=false(n,m);
          for i=1:n, idx=randperm(m,k); D(i,idx)=true; end
        else  
          p=0.5; if isfield(dp,'density'), p=dp.density; end
          D=rand(n,m)<p;
        end
        D=double(D);
        case 'mixed'
        D = zeros(n, m);

        % 1. Choose number of large-demand agents at random
        k = randi([0, n]);  % Uniformly random between 0 and n
        largeIdx = randperm(n, k);
        sparseIdx = setdiff(1:n, largeIdx);

        % 2. Assign large-demand rows
        D(largeIdx, :) = 1;

        % 3. Assign sparse-demand rows
        if isfield(dp, 'sparsePattern') && strcmpi(dp.sparsePattern, 'uniform')
            D(sparseIdx, :) = rand(length(sparseIdx), m) < 0.2;
        elseif isfield(dp, 'numOnesPerSparseRow')
            r = dp.numOnesPerSparseRow;
            for i = sparseIdx
                idx = randperm(m, min(r, m));
                D(i, idx) = 1;
            end
        else
            % Default: 1 one per sparse agent
            for i = sparseIdx
                D(i, randi(m)) = 1;
            end
        end

        % 4. Optional noise
        if isfield(dp, 'noiseLevel') && dp.noiseLevel > 0
            noise = dp.noiseLevel * randn(n, m);
            D = D + noise;
            D(D < 0) = 0; % clip negative values
            D(D > 1) = 1; % clip values above 1
        end
        % Ensure every row has at least one positive value
        rowSums = sum(D, 2);
        emptyRows = find(rowSums == 0);
        for i = emptyRows'
            j = randi(m);         % Random column
            D(i, j) = rand() * 0.1 + 0.1;  % Set to a small positive value
        end
      otherwise, error('Unknown demandsDistribution');
    end
if isfield(config.dataGeneration,'normalizeEachAgent')&&config.dataGeneration.normalizeEachAgent
  mx=max(D,[],2); mx(mx==0)=1; D=D./mx;
end
if isfield(config.dataGeneration, 'saveData') && config.dataGeneration.saveData
    % Get target folder and filename
    folder = fullfile(fileparts(mfilename('fullpath')), '..', config.dataGeneration.dataFolder);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end

    % Build file name
    fname = sprintf('%s_n%d_i%02d.mat', ...
        config.dataGeneration.dataPrefix, n, config.instanceIdx);
    fullpath = fullfile(folder, fname);

    % Save D and v
    save(fullpath, 'D', 'v');
    fprintf('[DataGen] Saved %s\n', fullpath);
end


end