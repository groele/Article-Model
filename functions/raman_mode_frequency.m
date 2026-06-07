function omega = raman_mode_frequency(ua, ub, p, modeId)
%RAMAN_MODE_FREQUENCY  Stacking-dependent phonon frequency for 2D sliding.
%
%  ω_m(ua, ub) = ω₀_m  +  δω₁ª_m·ua  +  δω₂ª_m·ua²  +  δω₁ᵇ_m·ub  +  δω₂ᵇ_m·ub²
%
%  Inputs:
%    ua     — easy-axis sliding coordinate
%    ub     — hard-axis sliding coordinate
%    p      — parameter struct from default_res2_params
%    modeId — index of Raman mode
%
%  Output:
%    omega  — phonon frequency in cm⁻¹

m = p.ramanModes(modeId);
omega = m.omega0 + m.domega_a1 .* ua + m.domega_a2 .* ua.^2 + ...
                   m.domega_b1 .* ub + m.domega_b2 .* ub.^2;

end
