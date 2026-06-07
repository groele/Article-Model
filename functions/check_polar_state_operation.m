function check = check_polar_state_operation(p, outDir)
%CHECK_POLAR_STATE_OPERATION Validate the configured polar-state operation.
%
% The function tests whether the configured operation maps cataloged registry
% states into plausible opposite-polar partners and whether Pz changes sign.

if nargin < 1 || isempty(p)
    p = default_res2_params();
end
if nargin < 2 || isempty(outDir)
    outDir = fullfile(pwd, 'output', 'validation_v5');
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

states = registry_state_catalog(p);
partner = identify_polar_partner_registry(states.ua, states.ub, p);
P = sliding_polarization(states.ua, states.ub, p);
PP = sliding_polarization(partner.ua, partner.ub, p);

coordError = zeros(height(states), 1);
matchedLabel = strings(height(states), 1);
matchedIndex = zeros(height(states), 1);
for i = 1:height(states)
    d2 = (states.ua - partner.ua(i)).^2 + (states.ub - partner.ub(i)).^2;
    [coordError(i), idx] = min(sqrt(d2));
    matchedIndex(i) = idx;
    matchedLabel(i) = string(states.label{idx});
end

pzOddError = norm(PP + P) ./ max([norm(P), norm(PP), eps]);

T = table(string(states.label), states.ua, states.ub, P, partner.ua, partner.ub, ...
    PP, matchedLabel, coordError, matchedIndex, ...
    'VariableNames', {'state_label','ua','ub','Pz','partner_ua','partner_ub', ...
    'partner_Pz','nearest_catalog_label','nearest_catalog_distance','nearest_catalog_index'});

writetable(T, fullfile(outDir, 'polar_state_operation_check.csv'));

check.operation = partner.operation;
check.table = T;
check.maxNearestCatalogDistance = max(coordError);
check.pzOddError = pzOddError;
check.passedPzOdd = pzOddError < 0.25;
check.passedCatalogMapping = max(coordError) < 0.75;
check.allPassed = check.passedPzOdd && check.passedCatalogMapping;
check.claimBoundary = ['If this check fails, the configured polar-state ', ...
    'operation should not be used for ReS2-specific quantitative claims.'];
end
