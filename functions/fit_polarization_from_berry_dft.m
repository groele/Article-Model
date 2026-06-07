function fit = fit_polarization_from_berry_dft(dft, p, useOddOnly)
%FIT_POLARIZATION_FROM_BERRY_DFT Fit Pz(u) using Berry-phase DFT data.
%
% Required DFT column:
%   Pz_uC_cm2
%
% The fitted basis is taken from symmetry_adapted_registry_basis.  By default
% only odd basis terms are used so that the fitted polarization reverses under
% the configured polar-state operation.

if nargin < 2 || isempty(p)
    p = default_res2_params();
end
if nargin < 3 || isempty(useOddOnly)
    useOddOnly = true;
end
if ischar(dft) || isstring(dft)
    dft = load_dft_registry_grid(char(dft));
end
if ~dft.hasPz
    error('DFT grid does not contain Pz_uC_cm2.');
end

ua = dft.ua(:);
ub = dft.ub(:);
y = dft.Pz_uC_cm2(:);
basis = symmetry_adapted_registry_basis(ua, ub, p);

Xpoly = basis.poly.values;
labels = basis.poly.labels;
parity = basis.poly.parity;
Xfourier = basis.fourier.values;
labels = [labels, basis.fourier.labels];
parity = [parity, basis.fourier.parity];
X = [Xpoly, Xfourier];

if useOddOnly
    keep = parity == "odd";
else
    keep = parity == "odd" | parity == "mixed";
end
if ~any(keep)
    error('No eligible basis terms for Pz fitting.');
end

Xk = X(:, keep);
coef = Xk \ y;
yhat = Xk * coef;
resid = y - yhat;
rmse = sqrt(mean(resid.^2));
ssTot = sum((y - mean(y)).^2);
R2 = 1 - sum(resid.^2) ./ max(ssTot, eps);

fit.coefficients = coef;
fit.labels = labels(keep);
fit.parity = parity(keep);
fit.Pz_fit_uC_cm2 = yhat;
fit.residual_uC_cm2 = resid;
fit.rmse_uC_cm2 = rmse;
fit.R2 = R2;
fit.useOddOnly = useOddOnly;
fit.claimLevel = 'Berry-phase calibrated Pz only if the input Pz_uC_cm2 column comes from converged Berry-phase DFT';
end
