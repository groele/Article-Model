function shg = shg_response(ua, ub, p, pumpDeg, analyzerDeg)
%SHG_RESPONSE Tensor SHG response for a linearly polarized geometry.

if nargin < 4 || isempty(pumpDeg)
    pumpDeg = p.shg.defaultPumpDeg;
end
if nargin < 5 || isempty(analyzerDeg)
    analyzerDeg = p.shg.defaultAnalyzerDeg;
end

T = p.shg.tensor_bg + ua.*p.shg.tensor_a1 + ub.*p.shg.tensor_b1 + ...
    ua.^2.*p.shg.tensor_a2 + ub.^2.*p.shg.tensor_b2;

ein = [cosd(pumpDeg); sind(pumpDeg)];
eout = [cosd(analyzerDeg); sind(analyzerDeg)];
P2 = complex(zeros(2, 1));
for i = 1:2
    for j = 1:2
        for k = 1:2
            P2(i) = P2(i) + T(i,j,k) * ein(j) * ein(k);
        end
    end
end
chi = eout.' * P2;

chiLegacy = p.shg.chi_bg + p.shg.chi_a1 .* ua + p.shg.chi_b1 .* ub + ...
            p.shg.chi_a2 .* ua.^2 + p.shg.chi_b2 .* ub.^2;

shg.tensor = T;
shg.vector = P2;
shg.chi = chi;
shg.chiLegacy = chiLegacy;
shg.intensity = abs(chi).^2;
shg.phase_rad = mod(angle(chi), 2*pi);
shg.sign = sign(real(chiLegacy));
end
