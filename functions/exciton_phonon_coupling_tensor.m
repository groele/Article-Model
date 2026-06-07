function g = exciton_phonon_coupling_tensor(ua, ub, p, modeId)
%EXCITON_PHONON_COUPLING_TENSOR Registry-dependent exciton-phonon coupling.
%
% This V6 helper provides a compact branch-resolved coupling proxy between
% Raman/phonon modes and the anisotropic X1/X2 excitons.  It is intended for
% resonant Raman modeling and should be calibrated against excitation-energy
% dependent Raman data or first-principles electron-phonon calculations.

if nargin < 4 || isempty(modeId)
    modeId = 1;
end
ua = ua(:);
ub = ub(:);

peak = exciton_peak_observables(ua(1), ub(1), p); %#ok<NASGU>
n = numel(ua);

% Mode-dependent base coupling.  The coefficients are conservative proxies
% and are not material constants until calibrated.
base = [1.00, 0.75];
if isfield(p, 'excitonPhonon') && isfield(p.excitonPhonon, 'baseCoupling')
    base = p.excitonPhonon.baseCoupling;
end
modeScale = 1 + 0.08*(modeId - 1);

% Registry anisotropy: odd and even terms are separated so downstream code
% can determine whether resonance enhancement is switchable or merely
% stacking-sensitive.
g_even = 1 + 0.10.*ua.^2 + 0.06.*ub.^2;
g_odd  = 0.08.*ua + 0.03.*ub;
g_mix  = 0.04.*ua.*ub;

g.X1 = modeScale .* base(1) .* (g_even + g_odd + g_mix);
g.X2 = modeScale .* base(2) .* (g_even - 0.5*g_odd - g_mix);
g.evenComponent = g_even;
g.oddComponent = g_odd;
g.mixedComponent = g_mix;
g.parity.X1 = 'mixed';
g.parity.X2 = 'mixed';
g.claimLevel = ['Registry-dependent exciton-phonon coupling proxy; ', ...
    'calibrate with resonant Raman excitation profiles or electron-phonon DFT.'];
end
