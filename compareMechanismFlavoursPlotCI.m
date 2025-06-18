function compareMechanismFlavoursPlotCI(configFilename, flavourList)
% Plots selected flavours of mechanisms with mean and 95% CI bands.
% flavourList should be a cell array of strings like {'pDRF_1', 'cDRF_2'}.

    if nargin < 1 || isempty(configFilename)
        configFilename = 'config.json';
    end
    if nargin < 2 || isempty(flavourList)
        flavourList = {'pDRF_1', 'pDRF_2', 'cDRF_1', 'greedy_1','ssvcg'};
    end

    cfg = jsondecode(fileread(configFilename));
    resultsFilename = cfg.output.resultsFilename;

    % Map base mechanism to list of runs to plot
    mechRunsMap = containers.Map();
    for i = 1:numel(flavourList)
        parts = split(flavourList{i}, '_');
        mech = parts{1};
        runIdx = str2double(parts{2});
        if ~isKey(mechRunsMap, mech)
            mechRunsMap(mech) = runIdx;
        else
            mechRunsMap(mech) = [mechRunsMap(mech), runIdx];
        end
    end

    mechs = keys(mechRunsMap);
    numMechs = numel(mechs);
    colors = lines(numMechs);
    lineStyles = {'-', '--', ':', '-.'};
    markers = {'o', 's', '^', 'd', 'x', '+', '*', 'v'};

    % Display label maps
    customLabels = containers.Map;
    customLabels('pDRF_1') = 'Prop. – exp=1';
    customLabels('pDRF_2') = 'Prop.– exp=0.5';
    customLabels('pDRF_3') = 'Prop. – exp=2';
    customLabels('cDRF_1') = 'Norm. Prop. – sum';
    customLabels('cDRF_2') = 'Norm. Prop. – sqrt';
    customLabels('cDRF_3') = 'Norm. Prop. – norm 2';
    customLabels('greedy_1') = 'Greedy';
    customLabels('ssvcg') = 'SSVCG';
    legendEntries = {};
    plotHandles = [];

    figure; hold on; grid on;

    for m = 1:numMechs
        mech = mechs{m};
        runIndices = mechRunsMap(mech);
        S = load(fullfile('results', mech, [resultsFilename '.mat']), 'M', 'nList');
        M = S.M;  % [instances × n × experiments]
        [I, N, E] = size(M);

        for idx = 1:numel(runIndices)
            k = runIndices(idx);
            if k > E
                warning('Run %d not found for %s; skipping.', k, mech);
                continue;
            end

            vals = squeeze(M(:,:,k));             % [instances × n]
            meanVals = mean(vals, 1);             % [1 × n]
            stderr = std(vals, 0, 1) / sqrt(I);   % Standard error
            ciWidth = 1.96 * stderr;              % 95% CI

            ls = lineStyles{mod(k-1, length(lineStyles)) + 1};
            mk = markers{mod(k-1, length(markers)) + 1};

            h = plot(S.nList, meanVals, ...
                'LineStyle', ls, ...
                'Marker', mk, ...
                'Color', colors(m,:));
            plotHandles(end+1) = h;

            flavourKey = sprintf('%s_%d', mech, k);
            if isKey(customLabels, flavourKey)
                legendEntries{end+1} = customLabels(flavourKey);
            else
                legendEntries{end+1} = sprintf('%s', mech, k);
            end

            % CI band
            nList = S.nList(:)';
            fill([nList, fliplr(nList)], ...
                [meanVals + ciWidth, fliplr(meanVals - ciWidth)], ...
                colors(m,:), ...
                'FaceAlpha', 0.15, ...
                'EdgeColor', 'none');
        end
    end

    xlabel('n');
    ylabel('Avg PoA ± 95% CI');
    title('PoA with 95% Confidence Intervals (per Flavour)');
    legend(plotHandles, legendEntries, 'Location', 'bestoutside');
end
