function out = sliding_polarization_v4(ua, ub, p)
%SLIDING_POLARIZATION_V4 Symmetry-adapted Berry/charge-transfer Pz proxy.
%
% V4 upgrades the simple polynomial Pz proxy by decomposing the polarization
% into physically interpretable contributions:
%
%   1. Landau-channel odd component: local sliding order parameter.
%   2. Periodic Berry-like component: registry-periodic odd Fourier terms.
%   3. Charge-transfer component: interlayer sheet-charge proxy.
%   4. Defect/doping renormalization: optional barrier/polarization scaling.
%
% The function returns a struct rather than only a scalar so downstream code
% can report the physical origin and claim level of Pz.

ua = ua(:);
ub = ub(:);

% Original local polynomial channel retained for continuity.
P_landau = p.landau.p1a .* ua + p.landau.p1b .* ub + p.landau.p3a .* ua.^3;

% Registry-periodic Berry-like channel.  Only sine-like terms are used by
% default because they are odd under u -> -u when the phase is zero.  With
% nonzero phase or a nontrivial polar operation, parity is reclassified by
% symmetry_adapted_registry_basis and reported as mixed if necessary.
P_berry = zeros(size(ua));
if isfield(p, 'registry') && isfield(p.registry, 'harmonicsG')
    G = p.registry.harmonicsG;
    amp = 0.04 * ones(1, size(G,1));
    if isfield(p, 'polarizationV4') && isfield(p.polarizationV4, 'berryAmplitude')
        a = p.polarizationV4.berryAmplitude;
        amp(1:min(numel(a), numel(amp))) = a(1:min(numel(a), numel(amp)));
    end
    for ig = 1:size(G,1)
        phase = 0;
        if isfield(p.registry, 'phaseRad') && numel(p.registry.phaseRad) >= ig
            phase = p.registry.phaseRad(ig);
        end
        arg = 2*pi*(G(ig,1).*ua + G(ig,2).*ub) + phase;
        P_berry = P_berry + amp(ig) .* sin(arg);
    end
end

% Charge-transfer channel: an intentionally conservative proxy linking
% interlayer registry to a sheet-charge-like response.  It is not a Berry-
% phase calculation; it is a calibration target for DFT charge-density
% difference or experimental electrostatic data.
ctWeight = 0.06;
if isfield(p, 'polarizationV4') && isfield(p.polarizationV4, 'chargeTransferWeight')
    ctWeight = p.polarizationV4.chargeTransferWeight;
end
P_charge = ctWeight .* tanh(0.8.*ua + 0.25.*ub);

scale = 1.0;
if isfield(p, 'doping') && isfield(p.doping, 'enabled') && p.doping.enabled
    v = 0;
    if isfield(p.doping, 'sulfurVacancyFraction')
        v = p.doping.sulfurVacancyFraction;
    end
    vref = max(p.doping.referenceVacancyFraction, eps);
    scale = 1 ./ (1 + 0.15 .* abs(v ./ vref));
end

P_total = scale .* (P_landau + P_berry + P_charge);

out.Pz = P_total;
out.P_landau = P_landau;
out.P_berry_like = P_berry;
out.P_charge_transfer = P_charge;
out.renormalization = scale;
out.claimLevel = 'symmetry-adapted phenomenological proxy; calibrate with Berry-phase DFT or electrostatic experiment for quantitative Pz';

basis = symmetry_adapted_registry_basis(ua, ub, p);
out.basisParity.polyLabels = basis.poly.labels;
out.basisParity.polyParity = basis.poly.parity;
out.basisParity.fourierLabels = basis.fourier.labels;
out.basisParity.fourierParity = basis.fourier.parity;

end
