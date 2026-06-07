function rate = switching_rate_kramers_model(barrier_meV, E_norm, T_K, params)
%SWITCHING_RATE_KRAMERS_MODEL Kramers-like thermal switching proxy.
%
% The model uses
%   Gamma(E,T) = f0 * exp[-DeltaF(E)/(kBT)]
% with a field-lowered barrier.  It is a kinetic proxy unless NEB barriers
% and attempt frequencies are calibrated.

if nargin < 4 || isempty(params)
    params = struct();
end
if ~isfield(params, 'attemptFrequency_Hz'); params.attemptFrequency_Hz = 1e9; end
if ~isfield(params, 'fieldLoweringExponent'); params.fieldLoweringExponent = 1.5; end
if ~isfield(params, 'criticalField_norm'); params.criticalField_norm = 1.0; end
if ~isfield(params, 'minBarrier_meV'); params.minBarrier_meV = 0.0; end

kB_meV_K = 8.617333262e-2;
Eabs = abs(E_norm(:));
barrier_meV = barrier_meV(:);
if isscalar(barrier_meV)
    barrier_meV = repmat(barrier_meV, size(Eabs));
end

x = min(Eabs ./ max(params.criticalField_norm, eps), 1.0);
DeltaF = barrier_meV .* max(1 - x.^params.fieldLoweringExponent, 0) + params.minBarrier_meV;
Gamma = params.attemptFrequency_Hz .* exp(-DeltaF ./ max(kB_meV_K*T_K, eps));

rate.Gamma_Hz = Gamma;
rate.DeltaF_meV = DeltaF;
rate.E_norm = Eabs;
rate.T_K = T_K;
rate.params = params;
rate.claimLevel = 'Kramers-like kinetic proxy; quantitative switching rates require calibrated NEB barrier and attempt frequency.';
end
