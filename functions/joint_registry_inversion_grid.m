function inv = joint_registry_inversion_grid(target, p, gridSpec, weights)
%JOINT_REGISTRY_INVERSION_GRID Invert hidden registry from multi-channel targets.
%
% target may include any subset of fields:
%   ramanThetaDeg, X1Energy, X1AxisDeg, X2Energy, X2AxisDeg,
%   shgIntensity, photocurrent, shiftCurrentProxy, ulfFrequency
%
% The function evaluates a grid in (ua,ub), computes model observables, and
% returns the best-fit registry plus a confidence basin.

if nargin < 2 || isempty(p)
    p = default_res2_params();
end
if nargin < 3 || isempty(gridSpec)
    gridSpec.ua = linspace(-1.4, 1.4, 121);
    gridSpec.ub = linspace(-0.8, 0.8, 81);
end
if nargin < 4 || isempty(weights)
    weights = default_weights();
end

[UA, UB] = meshgrid(gridSpec.ua, gridSpec.ub);
ua = UA(:); ub = UB(:); E = zeros(size(ua));
obs = bilayer_response_observables(ua, ub, E, p);

loss = zeros(size(ua));
used = {};
fields = fieldnames(target);
for i = 1:numel(fields)
    f = fields{i};
    if ~isfield(obs, f)
        continue;
    end
    w = 1.0;
    if isfield(weights, f); w = weights.(f); end
    y = obs.(f);
    t = target.(f);
    if isscalar(t)
        sigma = local_scale(y);
        loss = loss + w .* ((y - t)./sigma).^2;
    else
        t = t(:).';
        if strcmp(f, 'ulfFrequency') && size(obs.ulfFrequency, 2) == numel(t)
            for j = 1:numel(t)
                yj = obs.ulfFrequency(:,j);
                loss = loss + w .* ((yj - t(j))./local_scale(yj)).^2;
            end
        end
    end
    used{end+1} = f; %#ok<AGROW>
end

[minLoss, idx] = min(loss);
best.ua = ua(idx);
best.ub = ub(idx);
best.loss = minLoss;

% Confidence basin defined by delta loss <= 2.30, the 1-sigma contour for
% two parameters under a Gaussian approximation.
deltaLoss = loss - minLoss;
basinMask = deltaLoss <= 2.30;
confidenceArea = sum(basinMask) / numel(basinMask);

inv.best = best;
inv.usedChannels = used;
inv.lossGrid = reshape(loss, size(UA));
inv.deltaLossGrid = reshape(deltaLoss, size(UA));
inv.uaGrid = gridSpec.ua;
inv.ubGrid = gridSpec.ub;
inv.confidenceMask = reshape(basinMask, size(UA));
inv.confidenceAreaFraction = confidenceArea;
inv.claimLevel = 'Grid inversion diagnostic; confidence basin depends on assumed weights and model uncertainty.';
end

function s = local_scale(y)
s = max(std(y(:)), 0.05*range(y(:)) + eps);
end

function w = default_weights()
w.ramanThetaDeg = 0.8;
w.X1Energy = 0.6;
w.X2Energy = 0.6;
w.X1AxisDeg = 0.8;
w.X2AxisDeg = 0.8;
w.shgIntensity = 1.0;
w.photocurrent = 0.3;
w.shiftCurrentProxy = 0.3;
w.ulfFrequency = 2.0;
end
