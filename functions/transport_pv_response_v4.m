function tr = transport_pv_response_v4(ua, ub, E, p)
%TRANSPORT_PV_RESPONSE_V4 Symmetry-decomposed transport/PV response proxy.
%
% V4 separates electrical response channels by parity under polar-state
% reversal.  This prevents overclaiming that all photovoltaic or transport
% signals are ferroelectrically switchable.
%
% Output channels:
%   J_dark_even        baseline/thermionic transport proxy
%   J_dark_odd         polarization-gated Schottky contribution
%   J_shift_out_odd    out-of-plane switchable BPVE-like proxy
%   J_shift_in_even    in-plane unswitchable or weakly switchable BPVE proxy
%   J_shift_in_mixed   residual mixed symmetry channel

ua = ua(:);
ub = ub(:);
E = E(:);
if isscalar(E)
    E = repmat(E, size(ua));
end

pz4 = sliding_polarization_v4(ua, ub, p);
Pz = pz4.Pz;

kBT = 8.617333262e-5 * p.transport.temperatureK;
schottky_eV = p.transport.schottky0_eV - ...
    p.transport.lambda_P .* Pz - p.transport.lambda_E .* E;
thermionic = p.transport.darkCurrentScale .* exp(-schottky_eV ./ max(kBT, eps));
thermionicN = local_normalize_signed(thermionic);

bandOffset_eV = p.transport.bandOffset0_eV + p.transport.bandOffset_P .* Pz;
typeVWeight = 1 ./ (1 + exp(-(abs(bandOffset_eV) - ...
    p.transport.typeVThreshold_eV) ./ 0.015));

% Symmetry-decomposed current channels.
J_dark_even = p.transport.J0 + 0.08 .* abs(thermionicN);
J_dark_odd = p.transport.eta_P .* Pz + p.transport.eta_E .* E;

etaZ = p.transport.shiftCurrent_P;
etaInEven = p.transport.shiftCurrent0;
etaMixed = 0.25 * p.transport.shiftCurrent_P;
if isfield(p, 'transportV4')
    if isfield(p.transportV4, 'etaOutOdd'); etaZ = p.transportV4.etaOutOdd; end
    if isfield(p.transportV4, 'etaInEven'); etaInEven = p.transportV4.etaInEven; end
    if isfield(p.transportV4, 'etaMixed'); etaMixed = p.transportV4.etaMixed; end
end

% Even registry function: sensitive to stacking but not necessarily switchable.
g_even = ua.^2 + 0.6.*ub.^2;
if max(abs(g_even)) > eps
    g_even = g_even ./ max(abs(g_even));
end

% Mixed registry function: intentionally tagged as unsafe for direct
% switchability claims unless calibrated.
g_mixed = ua.*ub;
if max(abs(g_mixed)) > eps
    g_mixed = g_mixed ./ max(abs(g_mixed));
end

J_shift_out_odd = etaZ .* Pz;
J_shift_in_even = etaInEven .* g_even;
J_shift_in_mixed = etaMixed .* g_mixed;

tr.Pz = Pz;
tr.Pz_landau = pz4.P_landau;
tr.Pz_berry_like = pz4.P_berry_like;
tr.Pz_charge_transfer = pz4.P_charge_transfer;
tr.schottky_eV = schottky_eV;
tr.thermionicProxy = thermionic;
tr.bandOffset_eV = bandOffset_eV;
tr.typeVWeight = typeVWeight;
tr.J_dark_even = J_dark_even;
tr.J_dark_odd = J_dark_odd;
tr.J_shift_out_odd = J_shift_out_odd;
tr.J_shift_in_even = J_shift_in_even;
tr.J_shift_in_mixed = J_shift_in_mixed;
tr.shiftCurrentProxy = J_shift_out_odd + J_shift_in_even + J_shift_in_mixed;
tr.photocurrent = J_dark_even + J_dark_odd + tr.shiftCurrentProxy;
tr.parity.dark_even = 'even';
tr.parity.dark_odd = 'odd_candidate';
tr.parity.shift_out = 'odd_candidate';
tr.parity.shift_in_even = 'even_candidate';
tr.parity.shift_in_mixed = 'mixed';
tr.claimLevel = 'photocurrent is decomposed into parity channels; only odd_candidate terms may be interpreted as switchable after calibration';
end

function y = local_normalize_signed(x)
x = x(:);
r = max(x) - min(x);
if r < eps
    y = zeros(size(x));
else
    y = 2*((x - min(x))./r) - 1;
end
end
