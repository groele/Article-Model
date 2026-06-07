function I = raman_intensity_parallel(thetaDeg, ua, ub, p, modeId, config, excitationEnergy_eV)
%RAMAN_INTENSITY_PARALLEL Polarized Raman intensity for bilayer ReS2.

if nargin < 6 || isempty(config)
    config = 'parallel';
end
if nargin < 7 || isempty(excitationEnergy_eV)
    excitationEnergy_eV = p.raman.excitationEnergy_eV;
end

R = raman_tensor(ua, ub, p, modeId);
th = deg2rad(thetaDeg(:));
I = zeros(size(th));

for k = 1:numel(th)
    ei = [cos(th(k)); sin(th(k))];
    if strcmp(config, 'cross')
        es = [-sin(th(k)); cos(th(k))];
    else
        es = ei;
    end
    amp = es.' * R * ei;
    I(k) = abs(amp).^2 + p.ramanModes(modeId).bg;
end

if isfield(p, 'raman') && p.raman.useExcitonResonance
    [evals, ~, osc] = exciton_hamiltonian(ua, ub, p);
    detuning = (excitationEnergy_eV - evals(:)').^2 + p.raman.resonanceGamma_eV^2;
    enhancement = 1 + p.raman.resonanceStrength * sum(osc(:)' ./ detuning);
    I = I .* enhancement;
end
end
