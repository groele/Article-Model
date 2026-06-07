function [Ureg, dUdua, dUdub] = registry_potential(ua, ub, p)
%REGISTRY_POTENTIAL Periodic stacking energy from Fourier harmonics.
%
% Ureg is dimensionless.  The amplitudes are semi-quantitative and should be
% replaced by DFT or fitted experimental values for quantitative use.

G = p.registry.harmonicsG;
A = p.registry.amplitude(:);
ph = p.registry.phaseRad(:);

scale = 1;
if isfield(p, 'doping') && isfield(p.doping, 'enabled') && p.doping.enabled && ...
        isfield(p.registry, 'dopingBarrierScale') && p.registry.dopingBarrierScale
    ref = max(p.doping.referenceVacancyFraction, eps);
    scale = 1 + p.doping.barrierScalePerReference * ...
        (p.doping.sulfurVacancyFraction / ref);
end
A = scale .* A;

Ureg = zeros(size(ua));
dUdua = zeros(size(ua));
dUdub = zeros(size(ua));

for i = 1:numel(A)
    arg = 2*pi*(G(i,1).*ua + G(i,2).*ub) + ph(i);
    Ureg = Ureg + A(i) .* (1 - cos(arg));
    dUdua = dUdua + A(i) .* sin(arg) .* (2*pi*G(i,1));
    dUdub = dUdub + A(i) .* sin(arg) .* (2*pi*G(i,2));
end
end
