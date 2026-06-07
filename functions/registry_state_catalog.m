function states = registry_state_catalog(p)
%REGISTRY_STATE_CATALOG Return labeled registry states with derived observables.

labels = p.registry.stateLabels(:);
ua = p.registry.stateUa(:);
ub = p.registry.stateUb(:);
desc = p.registry.stateDescription(:);
n = numel(labels);

state_id = (1:n)';
Pz = sliding_polarization(ua, ub, p);
F0 = sliding_free_energy(ua, ub, 0, p);
shgIntensity = zeros(n, 1);
shgPhase = zeros(n, 1);
lowerExciton_eV = zeros(n, 1);
upperExciton_eV = zeros(n, 1);
registryClass = strings(n, 1);

for i = 1:n
    s = shg_response(ua(i), ub(i), p);
    shgIntensity(i) = s.intensity;
    shgPhase(i) = s.phase_rad;
    e = exciton_hamiltonian(ua(i), ub(i), p);
    lowerExciton_eV(i) = e(1);
    upperExciton_eV(i) = e(2);
    registryClass(i) = string(desc{i});
end

states = table(state_id, string(labels), ua, ub, Pz, F0, shgIntensity, ...
    shgPhase, lowerExciton_eV, upperExciton_eV, registryClass, ...
    'VariableNames', {'state_id','label','ua','ub','Pz','F0', ...
    'shgIntensity','shgPhase_rad','lowerExciton_eV','upperExciton_eV', ...
    'description'});
end
