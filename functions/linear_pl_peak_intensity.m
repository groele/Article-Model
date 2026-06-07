function Iphi = linear_pl_peak_intensity(phiDeg, axisDeg, dolp, amplitude)
%LINEAR_PL_PEAK_INTENSITY Partial linearly polarized PL angular profile.
%
% I(phi) = A/2 * [1 + DOLP*cos(2*(phi-axis))].

if nargin < 4
    amplitude = 1;
end
phiDeg = phiDeg(:);
Iphi = 0.5 .* amplitude .* (1 + dolp .* cosd(2 .* (phiDeg - axisDeg)));
Iphi = max(Iphi, 0);
end
