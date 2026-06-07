function rr = resonant_raman_matrix_element_v6(E_laser_eV, ua, ub, p, modeId)
%RESONANT_RAMAN_MATRIX_ELEMENT_V6 Branch-resolved resonant Raman proxy.
%
% The model follows a Kramers-Heisenberg-like phenomenological form:
%
%   M_m(E_L,u) = sum_j C_mj |e_in.d_j|^2 |e_out.d_j|^2 /
%                [(E_L - E_j(u))^2 + Gamma_j^2]
%
% where j = X1, X2. It connects registry-modulated excitonic eigenstates to
% resonant Raman enhancement. The function accepts either:
%   - one registry point and many laser energies;
%   - many registry points and one laser energy;
%   - matched arrays of registry points and laser energies.

if nargin < 5 || isempty(modeId)
    modeId = 1;
end
if nargin < 4 || isempty(p)
    p = default_res2_params();
end

E_laser_eV = E_laser_eV(:);
ua = ua(:);
ub = ub(:);
if numel(ua) ~= numel(ub)
    error('ua and ub must contain the same number of elements.');
end

nE = numel(E_laser_eV);
nu = numel(ua);
if nu == 1 && nE > 1
    ua = repmat(ua, nE, 1);
    ub = repmat(ub, nE, 1);
elseif nE == 1 && nu > 1
    E_laser_eV = repmat(E_laser_eV, nu, 1);
elseif nE ~= nu
    error('E_laser_eV must be scalar or have the same length as ua/ub.');
end

n = numel(ua);
M_X1 = zeros(n, 1);
M_X2 = zeros(n, 1);
E_X1 = zeros(n, 1);
E_X2 = zeros(n, 1);
Gamma_X1 = zeros(n, 1);
Gamma_X2 = zeros(n, 1);

for i = 1:n
    peak = exciton_peak_observables(ua(i), ub(i), p);
    g = exciton_phonon_coupling_tensor(ua(i), ub(i), p, modeId);
    E_X1(i) = peak.energy_eV(1);
    E_X2(i) = peak.energy_eV(2);
    if isfield(peak, 'gamma_eV')
        Gamma_X1(i) = peak.gamma_eV(1);
        Gamma_X2(i) = peak.gamma_eV(2);
    else
        Gamma_X1(i) = p.exciton.gamma0(1);
        Gamma_X2(i) = p.exciton.gamma0(2);
    end
    % Dipole anisotropy proxy using DOLP and oscillator strength.
    dip1 = max(peak.oscillator_strength(1), eps) .* (1 + peak.dolp(1));
    dip2 = max(peak.oscillator_strength(2), eps) .* (1 + peak.dolp(2));
    M_X1(i) = g.X1 .* dip1 ./ ((E_laser_eV(i) - E_X1(i)).^2 + Gamma_X1(i).^2);
    M_X2(i) = g.X2 .* dip2 ./ ((E_laser_eV(i) - E_X2(i)).^2 + Gamma_X2(i).^2);
end

rr.E_laser_eV = E_laser_eV;
rr.ua = ua;
rr.ub = ub;
rr.X1 = M_X1;
rr.X2 = M_X2;
rr.total = abs(M_X1 + M_X2).^2;
rr.E_X1 = E_X1;
rr.E_X2 = E_X2;
rr.Gamma_X1 = Gamma_X1;
rr.Gamma_X2 = Gamma_X2;
rr.modeId = modeId;
rr.claimLevel = ['Branch-resolved resonant Raman proxy; quantitative use ', ...
    'requires excitation-energy-dependent Raman calibration.'];
end
