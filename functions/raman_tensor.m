function R = raman_tensor(ua, ub, p, modeId)
%RAMAN_TENSOR  Low-symmetry Raman tensor controlled by 2D sliding.
%
%  Derivation (see THEORY_DERIVATIONS.md §2):
%
%  R_m(ua, ub) = R⁰_m  +  ua · R¹ª_m  +  ub · R¹ᵇ_m  +  ua² · R²ª_m  +  ub² · R²ᵇ_m
%
%  Symmetrization  R ← ½(R + Rᵀ)  is enforced.
%
%  Inputs:
%    ua     — easy-axis sliding coordinate
%    ub     — hard-axis sliding coordinate
%    p      — parameter struct
%    modeId — index of Raman mode

m = p.ramanModes(modeId);
R = m.R0 + ua*m.R1a + ub*m.R1b + ua^2*m.R2a + ub^2*m.R2b;
R = 0.5*(R + R.');    % enforce symmetry

end
