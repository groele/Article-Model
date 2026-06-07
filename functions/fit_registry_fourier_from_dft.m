function fit = fit_registry_fourier_from_dft(dft, p, nHarmonics)
%FIT_REGISTRY_FOURIER_FROM_DFT Fit a periodic registry-energy model to DFT.
%
% The fitted model has the form
%   U(u) = c0 + sum_i [a_i cos(2*pi*G_i.u) + b_i sin(2*pi*G_i.u)]
%
% where G_i is taken from p.registry.harmonicsG unless nHarmonics truncates it.

if nargin < 2 || isempty(p)
    p = default_res2_params();
end
if nargin < 3 || isempty(nHarmonics)
    nHarmonics = size(p.registry.harmonicsG, 1);
end
if ischar(dft) || isstring(dft)
    dft = load_dft_registry_grid(char(dft));
end

G = p.registry.harmonicsG;
nHarmonics = min(nHarmonics, size(G,1));
G = G(1:nHarmonics, :);

ua = dft.ua(:);
ub = dft.ub(:);
y = dft.energy_zeroed_meV(:);

X = ones(numel(ua), 1 + 2*nHarmonics);
labels = cell(1, size(X,2));
labels{1} = 'c0';
for ig = 1:nHarmonics
    arg = 2*pi*(G(ig,1).*ua + G(ig,2).*ub);
    X(:, 2*ig) = cos(arg);
    X(:, 2*ig+1) = sin(arg);
    labels{2*ig} = sprintf('cos_%d_%d', G(ig,1), G(ig,2));
    labels{2*ig+1} = sprintf('sin_%d_%d', G(ig,1), G(ig,2));
end

coef = X \ y;
yhat = X * coef;
resid = y - yhat;
rmse = sqrt(mean(resid.^2));
ssTot = sum((y - mean(y)).^2);
R2 = 1 - sum(resid.^2) ./ max(ssTot, eps);

fit.G = G;
fit.coefficients = coef;
fit.labels = labels;
fit.energy_fit_meV = yhat;
fit.residual_meV = resid;
fit.rmse_meV = rmse;
fit.R2 = R2;
fit.nPoints = numel(y);
fit.nParameters = numel(coef);
fit.AIC = numel(y)*log(mean(resid.^2) + eps) + 2*numel(coef);
fit.BIC = numel(y)*log(mean(resid.^2) + eps) + numel(coef)*log(numel(y));
fit.claimLevel = 'DFT-fitted registry energy if input grid is converged; otherwise regression diagnostic only';
fit.evaluate = @(uaQuery, ubQuery) local_eval_fourier(uaQuery, ubQuery, G, coef);
end

function y = local_eval_fourier(ua, ub, G, coef)
ua = ua(:); ub = ub(:);
nH = size(G, 1);
X = ones(numel(ua), 1 + 2*nH);
for ig = 1:nH
    arg = 2*pi*(G(ig,1).*ua + G(ig,2).*ub);
    X(:,2*ig) = cos(arg);
    X(:,2*ig+1) = sin(arg);
end
y = X * coef;
end
