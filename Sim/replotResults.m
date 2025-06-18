function replotResults(resultsFolder)
    S=load(fullfile(resultsFolder,'simResults.mat'));
    config=jsondecode(fileread(fullfile(resultsFolder,'config.json')));
    exps=config.mechanism.allocParams.exponents;
    plotExponentComparison(S.results,S.nList,exps);
    if config.plots.boxplot
      figure; boxplot(S.M,'Labels',string(S.nList)); title('PoA Distribution');
    end
    if config.plots.errorbar
      figure; errorbar(S.nList,nanmean(S.M),nanstd(S.M),'o-');
      title('Mean PoA ± std');
    end
end