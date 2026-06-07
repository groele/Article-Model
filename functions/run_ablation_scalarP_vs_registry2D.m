function result = run_ablation_scalarP_vs_registry2D(p, outDir)
%RUN_ABLATION_SCALARP_VS_REGISTRY2D Test whether 2D registry is necessary.
%
% The function compares scalar-P, 1D sliding, and 2D registry models for a
% set of synthetic/model-generated observables.  It is intended as a model
% selection diagnostic and a manuscript-supporting ablation workflow.

if nargin < 1 || isempty(p)
    p = default_res2_params();
end
if nargin < 2 || isempty(outDir)
    outDir = fullfile(pwd, 'output', 'ablation_v5');
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

E = linspace(-1.2, 1.2, 121)';
[ua, ub, Pz] = minimize_sliding_path(E, p);
obs = bilayer_response_observables(ua, ub, E, p);
pred = struct('Pz', Pz, 'ua', ua, 'ub', ub);

observableNames = {'ramanThetaDeg','X1Energy','X1AxisDeg','X2Energy','X2AxisDeg', ...
    'shgIntensity','shiftCurrentProxy','photocurrent'};
rows = cell(numel(observableNames)*3, 7);
r = 0;
perObservable = struct();
for io = 1:numel(observableNames)
    name = observableNames{io};
    y = obs.(name);
    cmp = compare_model_hierarchy(y, pred);
    perObservable.(name) = cmp;
    for im = 1:height(cmp.table)
        r = r + 1;
        rows{r,1} = name;
        rows{r,2} = cmp.table.model{im};
        rows{r,3} = cmp.table.rmse(im);
        rows{r,4} = cmp.table.R2(im);
        rows{r,5} = cmp.table.AIC(im);
        rows{r,6} = cmp.table.BIC(im);
        rows{r,7} = strcmp(cmp.table.model{im}, cmp.bestByBIC);
    end
end

T = cell2table(rows, 'VariableNames', ...
    {'observable','model','rmse','R2','AIC','BIC','bestByBIC'});
writetable(T, fullfile(outDir, 'ablation_scalarP_vs_registry2D.csv'));

result.table = T;
result.perObservable = perObservable;
result.claimLevel = ['If registry2D is repeatedly selected by BIC/AIC, ', ...
    'the data require a 2D registry coordinate rather than scalar P alone.'];
end
