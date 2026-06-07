function obs = bilayer_response_observables(ua, ub, E, p)
%BILAYER_RESPONSE_OBSERVABLES Coupled observable set for bilayer ReS2.

ua = ua(:);
ub = ub(:);
E = E(:);
if isscalar(E)
    E = repmat(E, size(ua));
end

n = numel(ua);
nModes = numel(p.ramanModes);
nUlf = numel(p.ulfModes);

obs.ua = ua;
obs.ub = ub;
obs.E = E;
obs.Pz = sliding_polarization(ua, ub, p);
physAll = sliding_physical_units(ua, ub, E, p);
obs.ua_A = physAll.ua_A;
obs.ub_A = physAll.ub_A;
obs.slidingMagnitude_A = physAll.sliding_magnitude_A;
obs.E_kVcm = physAll.E_kVcm;
obs.Pz_uCcm2 = physAll.Pz_uCcm2;
obs.sheetCharge_cm2 = physAll.sheet_charge_cm2;
obs.chargeTransfer_e_per_cell = physAll.charge_transfer_e_per_cell;
obs.ramanThetaDeg = zeros(n, 1);
obs.ramanAnisotropy = zeros(n, 1);
obs.ramanFreqShift = zeros(n, nModes);
obs.ulfFrequency = zeros(n, nUlf);
obs.ulfIntensity = zeros(n, nUlf);
obs.lowerExcitonEnergy = zeros(n, 1);
obs.upperExcitonEnergy = zeros(n, 1);
obs.lowerExcitonAxisDeg = zeros(n, 1);
obs.upperExcitonAxisDeg = zeros(n, 1);
obs.lowerOsc = zeros(n, 1);
obs.upperOsc = zeros(n, 1);
obs.X1Energy = zeros(n, 1);
obs.X2Energy = zeros(n, 1);
obs.X1AxisDeg = zeros(n, 1);
obs.X2AxisDeg = zeros(n, 1);
obs.X1Osc = zeros(n, 1);
obs.X2Osc = zeros(n, 1);
obs.X1Population = zeros(n, 1);
obs.X2Population = zeros(n, 1);
obs.X1Intensity = zeros(n, 1);
obs.X2Intensity = zeros(n, 1);
obs.X1DOLP = zeros(n, 1);
obs.X2DOLP = zeros(n, 1);
obs.X1S1 = zeros(n, 1);
obs.X1S2 = zeros(n, 1);
obs.X2S1 = zeros(n, 1);
obs.X2S2 = zeros(n, 1);
obs.dolp = zeros(n, 1);
obs.shgChi = complex(zeros(n, 1));
obs.shgIntensity = zeros(n, 1);
obs.shgPhase = zeros(n, 1);
obs.photocurrent = zeros(n, 1);
obs.schottkyShift = zeros(n, 1);
obs.schottkyBarrier_eV = zeros(n, 1);
obs.bandOffset_eV = zeros(n, 1);
obs.typeVWeight = zeros(n, 1);
obs.shiftCurrentProxy = zeros(n, 1);
obs.interlayerCharge = zeros(n, 1);

theta = (0:1:179)';

for i = 1:n
    uai = ua(i);
    ubi = ub(i);
    Ei = E(i);

    I = raman_intensity_parallel(theta, uai, ubi, p, 1);
    [Imax, imax] = max(I);
    Imin = min(I);
    obs.ramanThetaDeg(i) = theta(imax);
    obs.ramanAnisotropy(i) = Imax / (Imin + eps);

    for im = 1:nModes
        obs.ramanFreqShift(i, im) = raman_mode_frequency(uai, ubi, p, im) - ...
            p.ramanModes(im).omega0;
    end
    ulf = ulf_raman_modes(uai, ubi, p);
    obs.ulfFrequency(i, :) = ulf.frequency_cm1;
    obs.ulfIntensity(i, :) = ulf.intensity;

    peak = exciton_peak_observables(uai, ubi, p);
    obs.lowerExcitonEnergy(i) = peak.energy_eV(1);
    obs.upperExcitonEnergy(i) = peak.energy_eV(2);
    obs.lowerExcitonAxisDeg(i) = peak.axis_deg(1);
    obs.upperExcitonAxisDeg(i) = peak.axis_deg(2);
    obs.lowerOsc(i) = peak.oscillator_strength(1);
    obs.upperOsc(i) = peak.oscillator_strength(2);
    obs.X1Energy(i) = peak.energy_eV(1);
    obs.X2Energy(i) = peak.energy_eV(2);
    obs.X1AxisDeg(i) = peak.axis_deg(1);
    obs.X2AxisDeg(i) = peak.axis_deg(2);
    obs.X1Osc(i) = peak.oscillator_strength(1);
    obs.X2Osc(i) = peak.oscillator_strength(2);
    obs.X1Population(i) = peak.population(1);
    obs.X2Population(i) = peak.population(2);
    obs.X1Intensity(i) = peak.intensity_proxy(1);
    obs.X2Intensity(i) = peak.intensity_proxy(2);
    obs.X1DOLP(i) = peak.dolp(1);
    obs.X2DOLP(i) = peak.dolp(2);
    obs.X1S1(i) = peak.S1(1);
    obs.X1S2(i) = peak.S2(1);
    obs.X2S1(i) = peak.S1(2);
    obs.X2S2(i) = peak.S2(2);
    obs.dolp(i) = obs.X1DOLP(i);

    shg = shg_response(uai, ubi, p);
    obs.shgChi(i) = shg.chi;
    obs.shgIntensity(i) = shg.intensity;
    obs.shgPhase(i) = shg.phase_rad;

    tr = transport_pv_response(uai, ubi, Ei, p);
    obs.interlayerCharge(i) = obs.Pz(i);
    obs.schottkyShift(i) = p.transport.lambda_P * obs.Pz(i) + p.transport.lambda_E * Ei;
    obs.schottkyBarrier_eV(i) = tr.schottky_eV;
    obs.bandOffset_eV(i) = tr.bandOffset_eV;
    obs.typeVWeight(i) = tr.typeVWeight;
    obs.shiftCurrentProxy(i) = tr.shiftCurrentProxy;
    obs.photocurrent(i) = tr.photocurrent;
end
end
