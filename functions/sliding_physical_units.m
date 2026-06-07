function phys = sliding_physical_units(ua, ub, E, p)
%SLIDING_PHYSICAL_UNITS Map dimensionless model variables to physical scales.

ua = ua(:);
ub = ub(:);
E = E(:);
if isscalar(E)
    E = repmat(E, size(ua));
end

Pnorm = sliding_polarization(ua, ub, p);
phys.ua_A = ua .* p.units.u_a_period_A;
phys.ub_A = ub .* p.units.u_b_period_A;
phys.sliding_magnitude_A = hypot(phys.ua_A, phys.ub_A);
phys.E_kVcm = E .* p.units.E_norm_to_kVcm;
phys.Pz_uCcm2 = Pnorm .* p.units.P_norm_to_uCcm2;
phys.Pz_Cm2 = phys.Pz_uCcm2 ./ 100;

elementaryCharge_C = 1.602176634e-19;
phys.sheet_charge_cm2 = phys.Pz_Cm2 ./ elementaryCharge_C ./ 1e4;
phys.unit_cell_area_A2 = p.material.unit_cell_area_A2 .* ones(size(ua));
phys.charge_transfer_e_per_cell = phys.sheet_charge_cm2 .* ...
    (p.material.unit_cell_area_A2 .* 1e-16);
end
