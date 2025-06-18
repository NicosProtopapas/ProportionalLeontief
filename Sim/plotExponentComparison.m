function plotExponentComparison(M, nList, exponents)
% PLOTEXPONENTCOMPARISON  Plot mean PoA vs n for each exponent.
%   M         : I × K × E array of PoA (instances × nList × exponents)
%   nList     : 1 × K vector of agent counts
%   exponents : 1 × E vector of exponent values

    [~, K, E] = size(M);

    % Compute mean over instances (dim 1)
    meanPoA = squeeze( mean(M, 1, 'omitnan') );  % 1×K×E → K×E

    figure; hold on; grid on;
    cols = lines(E);
    for e = 1:E
        plot(nList, meanPoA(:,e), '-o', 'Color', cols(e,:), ...
             'LineWidth',1.5, 'DisplayName', sprintf('exp=%.2f', exponents(e)));
    end
    xlabel('Number of agents (n)');
    ylabel('Mean PoA');
    title('Mean PoA vs n by Exponent');
    legend('Location','best');
end
