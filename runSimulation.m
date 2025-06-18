function runSimulation(configFile)
% RUNSIMULATION Compare multiple pay-your-bid mechanisms on the same data.
    base = fileparts(mfilename('fullpath'));
    addpath(fullfile(base,'DataGen'), fullfile(base,'Mechanisms'), ...
            fullfile(base,'Sim'), fullfile(base,'Utils'));

    config = jsondecode(fileread(configFile));
    nList = config.nList; m = config.m; I = config.numInstances; K = numel(nList);

    % Pre-generate data
    allData = cell(K,I);
    %rng(0,'twister'); %% for reproducability. Comment out for random
    %generation
    fprintf('Pre-generating data...');
    for k=1:K
        for i=1:I
            config.instanceIdx = i;
            [D,v] = dataGenerator(nList(k), m, config);
            allData{k,i} = struct('D',D,'v',v);
        end
    end

    % Loop mechanisms
    for mIdx = 1:numel(config.mechanisms)
        mechCfg = config.mechanisms(mIdx);
        config.mechanism = mechCfg;
        mechName = mechCfg.name;
        outFolder = fullfile(base, config.output.resultsFolder, mechName);
        if config.output.saveResults && ~exist(outFolder,'dir')
            mkdir(outFolder);
        end

        exponents = mechCfg.allocParams.exponents; % In case we want to compare with exponents
        E = numel(exponents);
        M = NaN(I,K,E); % PoA matrix
        B = cell(I,K,E); % PNE bids
        A = cell(I,K,E); % Utilization in PNE and OPT

        % Where:
        % i = instance index (from 1 to numInstances)
        % k = index in nList (e.g., n = 100, 200, ...)
        % e = index of exponent value (e.g., exponent = 1, 2, etc.)
        convergeMask = false(I,K,E);
        extremeCases = cell(E,1);

        for e=1:E
            expVal = exponents(e);
            config.mechanism.allocParams.exponent = expVal;
            fprintf('\nMechanism=%s, Exponent=%.2f\n', mechName, expVal);
            for k=1:K
                tic;
                for i=1:I
                    D = allData{k,i}.D;
                    v = allData{k,i}.v;
                    [bFinal,xFinal,reason,~] = bestResponseDriver(D,v,config);
                    convergeMask(i,k,e) = strcmp(reason,'converged');
                    [SWopt,~,Xopt] = solveOptimalLeontief(D,v);
                    SWne = computeSocialWelfare(D,v,xFinal);
                    if SWopt/SWne < 1
                        fprintf("PoA=%.2f, OPt= %.2f, EQ= %.2f\n", SWopt/SWne, SWopt, SWne)
                        fprintf("Wrong on i=%.2f and n=%.2f\n",i,nList(k))
                    end
                    M(i,k,e) = SWopt/SWne;
                    B{i,k,e} = bFinal;
                    utilization = [sum(sum(xFinal)),sum(sum(Xopt))];
                    A{i,k,e} = utilization;
                end
                t = toc;
                fprintf(' n=%d: avgPoA=%.3f, conv=%.2f%% (%.2fs)\n', ...
                    nList(k), mean(M(:,k,e),'omitnan'),100*mean(convergeMask(:,k,e)),t);
            end
            extremeCases{e} = findExtremePoA(M(:,:,e),[],[],[], nList);
        end

        %plotExponentComparison(M, nList, exponents);

        if config.output.saveResults
            save(fullfile(outFolder, [config.output.resultsFilename '.mat']), ...
                 'M','convergeMask','nList','extremeCases','B','A');
            %copyfile(configFile, fullfile(outFolder,'config.json'));
            outCfgName = [config.output.resultsFilename, '.json'];
            copyfile(configFile, fullfile(outFolder, outCfgName));
            fprintf('Saved results for %s\n', mechName);
        end
    end
end

