function loo = leave_one_channel_out_test(target, p, gridSpec, weights)
%LEAVE_ONE_CHANNEL_OUT_TEST Test registry-inversion stability by dropping channels.
%
% The function first performs full joint inversion, then repeats inversion
% while removing one target channel at a time.  Stable registry assignments
% indicate that the inferred sliding state is not dominated by a single
% observable.

if nargin < 2 || isempty(p)
    p = default_res2_params();
end
if nargin < 3; gridSpec = []; end
if nargin < 4; weights = []; end

full = joint_registry_inversion_grid(target, p, gridSpec, weights);
fields = fieldnames(target);
rows = cell(numel(fields), 5);
for i = 1:numel(fields)
    t = target;
    t = rmfield(t, fields{i});
    inv = joint_registry_inversion_grid(t, p, gridSpec, weights);
    du = sqrt((inv.best.ua - full.best.ua).^2 + (inv.best.ub - full.best.ub).^2);
    rows{i,1} = fields{i};
    rows{i,2} = inv.best.ua;
    rows{i,3} = inv.best.ub;
    rows{i,4} = du;
    rows{i,5} = inv.confidenceAreaFraction;
end

loo.full = full;
loo.table = cell2table(rows, 'VariableNames', ...
    {'droppedChannel','best_ua','best_ub','distanceFromFull','confidenceAreaFraction'});
loo.maxDistanceFromFull = max(loo.table.distanceFromFull);
loo.claimLevel = ['Leave-one-channel-out diagnostic; small registry shifts ', ...
    'support multi-channel consistency.'];
end
