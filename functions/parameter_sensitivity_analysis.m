function sens = parameter_sensitivity_analysis(p, observableFun, paramList, relStep)
%PARAMETER_SENSITIVITY_ANALYSIS Local finite-difference sensitivity analysis.
%
% observableFun must be a function handle:
%   y = observableFun(p)
%
% paramList is a cell array of dot paths, e.g. {'landau.p1a','exciton.K0'}.

if nargin < 1 || isempty(p)
    p = default_res2_params();
end
if nargin < 2 || isempty(observableFun)
    observableFun = @(pp) default_observable_vector(pp);
end
if nargin < 3 || isempty(paramList)
    paramList = {'landau.p1a','landau.p1b','landau.p3a','landau.registryWeight', ...
        'exciton.E0_a1','exciton.Delta_a1','exciton.K_a1','transport.shiftCurrent_P'};
end
if nargin < 4 || isempty(relStep)
    relStep = 1e-3;
end

y0 = observableFun(p);
y0 = y0(:);
S = zeros(numel(y0), numel(paramList));
baseVals = zeros(numel(paramList), 1);
for i = 1:numel(paramList)
    path = paramList{i};
    val = getfield_dot(p, path);
    baseVals(i) = val;
    h = relStep * max(abs(val), 1);
    pp = setfield_dot(p, path, val + h);
    pm = setfield_dot(p, path, val - h);
    yp = observableFun(pp); yp = yp(:);
    ym = observableFun(pm); ym = ym(:);
    S(:,i) = (yp - ym) ./ (2*h);
end

normSens = sqrt(sum(S.^2, 1)).';
relSens = normSens .* max(abs(baseVals), 1) ./ max(norm(y0), eps);
Tsens = table(string(paramList(:)), baseVals, normSens, relSens, ...
    'VariableNames', {'parameter','baseValue','absoluteSensitivity','relativeSensitivity'});
Tsens = sortrows(Tsens, 'relativeSensitivity', 'descend');

sens.table = Tsens;
sens.S = S;
sens.y0 = y0;
sens.claimLevel = 'Local sensitivity diagnostic; does not replace global uncertainty quantification.';
end

function y = default_observable_vector(p)
states = registry_state_catalog(p);
obs = bilayer_response_observables(states.ua, states.ub, zeros(height(states),1), p);
y = [obs.Pz; obs.X1Energy; obs.X2Energy; obs.X1AxisDeg; obs.X2AxisDeg; obs.shgIntensity; obs.photocurrent];
end

function val = getfield_dot(s, path)
parts = strsplit(path, '.');
val = s;
for i = 1:numel(parts)
    val = val.(parts{i});
end
end

function s = setfield_dot(s, path, val)
parts = strsplit(path, '.');
if numel(parts) == 1
    s.(parts{1}) = val;
else
    sub = s.(parts{1});
    sub = setfield_dot(sub, strjoin(parts(2:end), '.'), val);
    s.(parts{1}) = sub;
end
end
