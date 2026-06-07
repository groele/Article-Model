function [PLmap, comp] = pl_spectrum_model(energy, phiDeg, ua, ub, p)
%PL_SPECTRUM_MODEL Polarization-resolved PL map for 2D sliding.

energy = energy(:);
phiDeg = phiDeg(:);

peak = exciton_peak_observables(ua, ub, p);
evals = peak.energy_eV;
Gamma = peak.gamma_eV;
dipoles = peak.dipoles;

PLmap = zeros(numel(energy), numel(phiDeg));
for j = 1:2
    L = lorentzian(energy, evals(j), Gamma(j));
    for k = 1:numel(phiDeg)
        angularWeight = linear_pl_peak_intensity(phiDeg(k), peak.axis_deg(j), ...
            peak.dolp(j), peak.oscillator_strength(j));
        PLmap(:, k) = PLmap(:, k) + peak.population(j) * angularWeight * L;
    end
end
PLmap = PLmap + p.exciton.bg;

comp.E = evals(:)';
comp.Gamma = Gamma(:)';
comp.theta_deg = peak.axis_deg(:)';
comp.osc = peak.oscillator_strength(:)';
comp.population = peak.population(:)';
comp.peak_dolp = peak.dolp(:)';
comp.labels = peak.labels;
comp.dipoles = dipoles;
end

function L = lorentzian(E, E0, gamma)
L = (0.5*gamma).^2 ./ ((E - E0).^2 + (0.5*gamma).^2);
area = trapz(E, L);
if area > eps
    L = L ./ area;
end
end
