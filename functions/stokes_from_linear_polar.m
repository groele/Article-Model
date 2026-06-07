function S = stokes_from_linear_polar(phiDeg, Iphi)
%STOKES_FROM_LINEAR_POLAR  Extracts linear Stokes parameters from analyzer data.
%
%  Derivation (see THEORY_DERIVATIONS.md §4):
%
%  A linear analyzer at angle φ transmits intensity:
%
%    I(φ) = ½ S₀  +  ½ S₁ cos(2φ)  +  ½ S₂ sin(2φ)
%
%  This is the Fourier series of the Malus law for partially polarized
%  light.  Fitting I(φ) by least squares gives S₀, S₁, S₂ directly.
%
%  Derived quantities:
%    DOLP  = √(S₁² + S₂²) / S₀        degree of linear polarization
%    θ_pol = ½ · atan2(S₂, S₁) mod 180°  polarization orientation
%
%  Inputs:
%    phiDeg — [N×1] analyzer angles (degrees)
%    Iphi   — [N×1] measured intensity at each angle
%
%  Output:
%    S — struct with fields: S0, S1, S2, DOLP, theta_deg, fitIntensity

phi = deg2rad(phiDeg(:));
y   = Iphi(:);

% Linear least-squares fit:  I = X · [S₀; S₁; S₂]
X = 0.5 * [ones(size(phi)), cos(2*phi), sin(2*phi)];
b = X \ y;

S0 = b(1);  S1 = b(2);  S2 = b(3);

S.S0           = S0;
S.S1           = S1;
S.S2           = S2;
S.DOLP         = sqrt(S1^2 + S2^2) / max(S0, eps);
S.theta_deg    = mod(0.5*atan2d(S2, S1), 180);
S.fitIntensity = X * b;

end
