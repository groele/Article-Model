function peak = exciton_peak_observables(ua, ub, p)
%EXCITON_PEAK_OBSERVABLES Peak-resolved ReS2 PL observables.
%
% ReS2 PL should be treated as two linearly polarized exciton peaks rather
% than a single combined polarization channel.  X1 is the lower-energy peak
% and X2 is the higher-energy peak after Hamiltonian diagonalization.

[evals, thetaDeg, osc, H, dipoles] = exciton_hamiltonian(ua, ub, p);
gamma = p.exciton.gamma0 + p.exciton.gamma_u * ua + ...
    p.exciton.gamma_T_coeff * max(p.exciton.temperatureK - 78, 0);
gamma = max(gamma, 0.003);

kBT = 8.617333262e-5 * max(p.exciton.temperatureK, 1);
population = exp(-(evals(:)' - min(evals)) ./ kBT);
population = population ./ max(sum(population), eps);

peakDOLP = p.exciton.peakDOLP0 - p.exciton.peakDOLP_ub .* abs(ub);
peakDOLP = min(max(peakDOLP, 0), 0.999);

peak.labels = string(p.exciton.peakLabels);
peak.energy_eV = evals(:)';
peak.gamma_eV = gamma(:)';
peak.axis_deg = thetaDeg(:)';
peak.oscillator_strength = osc(:)';
peak.population = population(:)';
peak.intensity_proxy = peak.oscillator_strength .* peak.population;
peak.dolp = peakDOLP(:)';
peak.S1 = peak.dolp .* cosd(2*peak.axis_deg);
peak.S2 = peak.dolp .* sind(2*peak.axis_deg);
peak.H = H;
peak.dipoles = dipoles;
end
