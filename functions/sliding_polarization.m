function Pz = sliding_polarization(ua, ub, p)
%SLIDING_POLARIZATION Out-of-plane polarization from in-plane registry.
Pz = p.landau.p1a .* ua + p.landau.p1b .* ub + p.landau.p3a .* ua.^3;
end
