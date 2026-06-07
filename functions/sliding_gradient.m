function [dF_dua, dF_dub] = sliding_gradient(ua, ub, E, p)
%SLIDING_GRADIENT Analytic gradient of the hybrid sliding free energy.

dP_dua = p.landau.p1a + 3*p.landau.p3a .* ua.^2;
dP_dub = p.landau.p1b + zeros(size(ub));

dF_dua = p.landau.ax.*ua + p.landau.bx.*ua.^3 + p.landau.cx.*ua.^5 + ...
         p.landau.kxy.*ub - E.*dP_dua;
dF_dub = p.landau.ky.*ub + p.landau.kxy.*ua - E.*dP_dub;

if isfield(p.landau, 'useRegistryPotential') && p.landau.useRegistryPotential
    [~, dUdua, dUdub] = registry_potential(ua, ub, p);
    w = p.landau.registryWeight;
    dF_dua = dF_dua + w .* dUdua;
    dF_dub = dF_dub + w .* dUdub;
end
end
