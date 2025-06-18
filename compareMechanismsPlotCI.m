function compareMechanismsPlotCI(configFilename, mechNames)

    if nargin < 1 || isempty(configFilename)
        configFilename = 'config.json';
    end
    if nargin < 2 || isempty(mechNames)
        mechNames = {'pDRF','cDRF','gready'};
    end

    cfg = jsondecode(fileread(configFilename));
    resultsFilename = cfg.output.resultsFilename;

    numMechs = numel(mechNames);
    colors = lines(numMechs);
    lineStyles = {'-', '--', ':', '-.'};
    markers = {'o', 's', '^', 'd', 'x', '+', '*', 'v'};

    mechLabelMap = containers.Map( ...
    {'pDRF', 'cDRF', 'greedy'}, ...             % internal names
    {'Proportional', 'Norm. Prop', 'Greedy'});  % display labels

    customLabels = containers.Map;

    % Example: pDRF has three exp
    customLabels('pDRF_1') = 'Prop. – exp=1';
    customLabels('pDRF_2') = 'Prop.– exp=0.5';
    customLabels('pDRF_3') = 'Prop. – exp=2';
    
    % cDRF has 3 discounts
    customLabels('cDRF_1') = 'Norm. Prop. – sum';
    customLabels('cDRF_2') = 'Norm. Prop. – sqrt';
    customLabels('cDRF_3') = 'Norm. Prop. – norm 2';
    
    % gready has one run
    customLabels('greedy_1') = 'Greedy';
 

    legendEntries = {};
    plotHandles = [];
    
    figure; hold on; grid on;

    for m = 1:numMechs
        S(m) = load(fullfile('results', mechNames{m}, [resultsFilename '.mat']), 'M', 'nList');
        M = S(m).M;  % [instances × n × experiments]
        [I, K, E] = size(M);

        for k = 1:E
            vals = squeeze(M(:,:,k));             % [instances × n]
            meanVals = mean(vals, 1);             % [1 × n]
            stderr = std(vals, 0, 1) / sqrt(I);   % Standard error
            ciWidth = 1.96 * stderr;              % 95% CI

            % Plot mean line
            ls = lineStyles{mod(k-1, length(lineStyles)) + 1};
            mk = markers{mod(k-1, length(markers)) + 1};

            h = plot(S(m).nList, meanVals, ...
    'LineStyle', ls, ...
    'Marker', mk, ...
    'Color', colors(m,:));
    plotHandles(end+1) = h;
    key = sprintf('%s_%d', mechNames{m}, k);
    if isKey(customLabels, key)
        legendEntries{end+1} = customLabels(key);
    else
        legendEntries{end+1} = sprintf('%s (Run %d)', mechNames{m}, k);  % fallback
    end

            % CI band
nList = S(m).nList(:)';  % ensure row vector
fill([nList, fliplr(nList)], ...
     [meanVals + ciWidth, fliplr(meanVals - ciWidth)], ...
     colors(m,:), ...
     'FaceAlpha', 0.15, ...
     'EdgeColor', 'none');
        end
    end

    xlabel('n'); ylabel('Avg PoA ± 95% CI');
    title(sprintf('PoA with 95%% Confidence Intervals (m=%d)',cfg.m));
    legend(plotHandles, legendEntries, 'Location', 'bestoutside');
end
