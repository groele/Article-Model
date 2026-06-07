function cmp = compare_model_hierarchy(obs, predictors)
%COMPARE_MODEL_HIERARCHY Compare scalar-P, 1D sliding, and 2D registry models.
%
% cmp = compare_model_hierarchy(obs, predictors)
%
% obs must be a numeric column vector. predictors may be either:
%   1) a struct with fields Pz, ua, ub, or
%   2) an N-by-k numeric design matrix, in which case only one model is fit.
%
% The default hierarchy is:
%   Model A: scalar-P only
%   Model B: 1D sliding u_a
%   Model C: full 2D registry u_a,u_b and second-order terms

obs = obs(:);
if isstruct(predictors)
    required = {'Pz','ua','ub'};
    for i = 1:numel(required)
        if ~isfield(predictors, required{i})
            error('Missing predictor field: %s', required{i});
        end
    end
    Pz = predictors.Pz(:);
    ua = predictors.ua(:);
    ub = predictors.ub(:);
    designs = struct();
    designs.scalarP = [ones(size(obs)), Pz];
    designs.sliding1D = [ones(size(obs)), ua, ua.^2, ua.^3];
    designs.registry2D = [ones(size(obs)), ua, ub, ua.^2, ub.^2, ua.*ub, ua.^3, ub.^3];
else
    designs.custom = predictors;
end

names = fieldnames(designs);
rows = cell(numel(names), 1);
for i = 1:numel(names)
    X = designs.(names{i});
    fit = local_linear_fit(obs, X);
    rows{i,1} = names{i};
    rows{i,2} = fit.rmse;
    rows{i,3} = fit.R2;
    rows{i,4} = fit.AIC;
    rows{i,5} = fit.BIC;
    rows{i,6} = size(X, 2);
    rows{i,7} = fit;
end

cmp.table = cell2table(rows(:,1:6), 'VariableNames', ...
    {'model','rmse','R2','AIC','BIC','nParameters'});
cmp.fits = rows(:,7);
[~, idx] = min(cmp.table.BIC);
cmp.bestByBIC = cmp.table.model{idx};
cmp.claimLevel = 'Model hierarchy diagnostic; use cross-validation and experimental uncertainty for manuscript-level model selection.';
end

function fit = local_linear_fit(y, X)
X = double(X);
y = double(y(:));
coef = X \ y;
yhat = X * coef;
resid = y - yhat;
n = numel(y);
k = size(X, 2);
rmse = sqrt(mean(resid.^2));
ssTot = sum((y - mean(y)).^2);
R2 = 1 - sum(resid.^2) ./ max(ssTot, eps);
AIC = n*log(mean(resid.^2) + eps) + 2*k;
BIC = n*log(mean(resid.^2) + eps) + k*log(n);
fit.coef = coef;
fit.yhat = yhat;
fit.resid = resid;
fit.rmse = rmse;
fit.R2 = R2;
fit.AIC = AIC;
fit.BIC = BIC;
end
