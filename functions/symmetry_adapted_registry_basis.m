function basis = symmetry_adapted_registry_basis(ua, ub, p)
%SYMMETRY_ADAPTED_REGISTRY_BASIS Build registry basis functions with parity tags.
%
% The V4 model treats the interlayer registry vector u=(ua,ub) as the
% structural order parameter.  Observables are expanded in basis functions
% that are classified by their parity under the operation connecting the two
% opposite polar states.  The default operation is u -> -u; users can replace
% it by setting
%
%   p.symmetry.polarTransformMatrix = [m11 m12; m21 m22]
%
% This function is deliberately lightweight and works with the existing
% dimensionless registry coordinates used by the repository.

ua = ua(:);
ub = ub(:);
[uaP, ubP] = local_polar_partner(ua, ub, p);

basis.ua = ua;
basis.ub = ub;
basis.partner_ua = uaP;
basis.partner_ub = ubP;

% Low-order polynomial basis.  These terms are not forced to be periodic;
% they are useful for local Landau-like expansions near a sliding channel.
B = [ ...
    ua, ...
    ub, ...
    ua.^2, ...
    ub.^2, ...
    ua.*ub, ...
    ua.^3, ...
    ub.^3, ...
    ua.*ub.^2, ...
    ub.*ua.^2 ...
    ];
BP = [ ...
    uaP, ...
    ubP, ...
    uaP.^2, ...
    ubP.^2, ...
    uaP.*ubP, ...
    uaP.^3, ...
    ubP.^3, ...
    uaP.*ubP.^2, ...
    ubP.*uaP.^2 ...
    ];
labels = { ...
    'ua', 'ub', 'ua2', 'ub2', 'ua_ub', ...
    'ua3', 'ub3', 'ua_ub2', 'ub_ua2'};

n = size(B, 2);
parity = strings(1, n);
for k = 1:n
    parity(k) = local_classify_parity(B(:,k), BP(:,k));
end

basis.poly.values = B;
basis.poly.partnerValues = BP;
basis.poly.labels = labels;
basis.poly.parity = parity;

% Periodic registry basis from the Fourier harmonics already stored in p.
if isfield(p, 'registry') && isfield(p.registry, 'harmonicsG')
    G = p.registry.harmonicsG;
    nG = size(G, 1);
    F = zeros(numel(ua), 2*nG);
    FP = zeros(numel(ua), 2*nG);
    flabels = cell(1, 2*nG);
    fparity = strings(1, 2*nG);
    for ig = 1:nG
        phase = 0;
        if isfield(p.registry, 'phaseRad') && numel(p.registry.phaseRad) >= ig
            phase = p.registry.phaseRad(ig);
        end
        arg = 2*pi*(G(ig,1).*ua + G(ig,2).*ub) + phase;
        argP = 2*pi*(G(ig,1).*uaP + G(ig,2).*ubP) + phase;
        F(:,2*ig-1) = cos(arg);
        F(:,2*ig) = sin(arg);
        FP(:,2*ig-1) = cos(argP);
        FP(:,2*ig) = sin(argP);
        flabels{2*ig-1} = sprintf('cos_G%d_%d_%d', ig, G(ig,1), G(ig,2));
        flabels{2*ig} = sprintf('sin_G%d_%d_%d', ig, G(ig,1), G(ig,2));
        fparity(2*ig-1) = local_classify_parity(F(:,2*ig-1), FP(:,2*ig-1));
        fparity(2*ig) = local_classify_parity(F(:,2*ig), FP(:,2*ig));
    end
    basis.fourier.values = F;
    basis.fourier.partnerValues = FP;
    basis.fourier.labels = flabels;
    basis.fourier.parity = fparity;
else
    basis.fourier.values = [];
    basis.fourier.partnerValues = [];
    basis.fourier.labels = {};
    basis.fourier.parity = strings(1,0);
end

basis.note = ['Use odd basis functions for ferroelectric Pz-like terms; ', ...
    'use even/mixed basis functions for registry-sensitive but not strictly ', ...
    'switchable observables.'];
end

function [uaP, ubP] = local_polar_partner(ua, ub, p)
M = -eye(2);
if nargin >= 3 && isstruct(p) && isfield(p, 'symmetry') && ...
        isfield(p.symmetry, 'polarTransformMatrix')
    Mtry = p.symmetry.polarTransformMatrix;
    if isequal(size(Mtry), [2 2])
        M = Mtry;
    end
end
up = M * [ua.'; ub.'];
uaP = up(1,:).';
ubP = up(2,:).';
end

function tag = local_classify_parity(x, xp)
scale = max([norm(x), norm(xp), eps]);
errOdd = norm(xp + x) / scale;
errEven = norm(xp - x) / scale;
if errOdd < 1e-8
    tag = "odd";
elseif errEven < 1e-8
    tag = "even";
else
    tag = "mixed";
end
end
