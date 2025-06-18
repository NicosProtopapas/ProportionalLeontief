function compareMechanismsPlot(configFilename, mechNames)

    if nargin < 1 || isempty(configFilename)
        configFilename = 'config.json';
    end
    if nargin < 2 || isempty(mechNames)
        mechNames = {'pDRF','cDRF','gready'};
    end

    lineStyles = {'-', '--', ':', '-.', '-', '--', ':', '-.'};  % Extend if needed
    markers = {'o', 's', '^', 'd', 'x', '+', '*', 'v'};

    cfg = jsondecode(fileread(configFilename));
    resultsFilename = cfg.output.resultsFilename;

    numMechs = numel(mechNames);
    colors = lines(numMechs);
    for m = 1:numMechs
        S(m) = load(fullfile('results', mechNames{m}, [resultsFilename '.mat']), 'M', 'nList');
    end

    nList = S(1).nList; 
    K = numel(nList);

    figure; hold on; grid on;
    for m = 1:numMechs
    avg = squeeze(mean(S(m).M, 1));  % [numN × numExperiments]
        for k = 1:size(avg, 2)
            ls = lineStyles{mod(k-1, length(lineStyles)) + 1};  % cycle through styles
            plot(nList, avg(:,k), '-o', 'Color', colors(m,:),'LineStyle', ls, ...
                'DisplayName', sprintf('%s (exp %d)', mechNames{m}, k));
        end
    end
    xlabel('n'); ylabel('Avg PoA'); title('Avg PoA Comparison'); legend;

 figure; hold on; grid on;


for m = 1:numMechs
    [I, K2, E] = size(S(m).M);
    for k = 1:E
        % Data for experiment k
        data = squeeze(S(m).M(:,:,k));  % [I × K2]
        pos = (1:K2) + (m - (numMechs + 1)/2)*0.8 + (k - (E+1)/2)*0.15;  % offset by mechanism and experiment
        h = boxplot(data, 'positions', pos, 'widths', 0.12, 'colors', colors(m,:));

        % Optionally: color individual boxes using patch (if desired)
        h = findobj(gca, 'Tag', 'Box');
        for j = 1:length(h)
            patch(get(h(j), 'XData'), get(h(j), 'YData'), colors(m,:), ...
                'FaceAlpha', 0.3, 'EdgeColor', colors(m,:), 'LineStyle', lineStyles{mod(k-1,length(lineStyles))+1});
        end
    end
end

xticks(1:K2);
xticklabels(string(S(1).nList));
xlabel('n'); ylabel('PoA'); title('PoA Distributions by Mechanism and Experiment');
legendStr = arrayfun(@(m,k) sprintf('%s (exp %d)', mechNames{m}, k), ...
    repelem(1:numMechs,E), repmat(1:E,1,numMechs), 'UniformOutput', false);
legend(legendStr, 'Location', 'bestoutside');
end
