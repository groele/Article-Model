function F = sliding_free_energy(ua, ub, E, p)
%SLIDING_FREE_ENERGY Hybrid local plus registry-periodic free energy.
%
% F = U_local(ua,ub) + w*U_registry(ua,ub) - E*Pz(ua,ub).

Pz = sliding_polarization(ua, ub, p);
F0 = 0.5*p.landau.ax .* ua.^2 + 0.25*p.landau.bx .* ua.^4 + ...
     (1/6)*p.landau.cx .* ua.^6 + 0.5*p.landau.ky .* ub.^2 + ...
     p.landau.kxy .* ua .* ub;

if isfield(p.landau, 'useRegistryPotential') && p.landau.useRegistryPotential
    Ureg = registry_potential(ua, ub, p);
    F0 = F0 + p.landau.registryWeight .* Ureg;
end

F = F0 - E .* Pz;
end
