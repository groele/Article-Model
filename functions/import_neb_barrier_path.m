function neb = import_neb_barrier_path(path)
%IMPORT_NEB_BARRIER_PATH Import NEB switching-path data.
%
% Expected columns:
%   image_id, ua, ub, energy_meV_per_cell
%
% Optional columns:
%   reaction_coordinate, Pz_uC_cm2

if nargin < 1 || isempty(path)
    path = fullfile(pwd, 'data', 'neb_barrier_path_template.csv');
end
if ~exist(path, 'file')
    error('NEB path file not found: %s', path);
end
T = readtable(path);
required = {'image_id','ua','ub','energy_meV_per_cell'};
for i = 1:numel(required)
    if ~ismember(required{i}, T.Properties.VariableNames)
        error('Missing required NEB column: %s', required{i});
    end
end
T = sortrows(T, 'image_id');
E = T.energy_meV_per_cell(:);
E0 = E - min(E);
barrier = max(E0);
if ismember('reaction_coordinate', T.Properties.VariableNames)
    s = T.reaction_coordinate(:);
else
    du = [0; sqrt(diff(T.ua).^2 + diff(T.ub).^2)];
    s = cumsum(du);
    if max(s) > eps
        s = s ./ max(s);
    end
end
neb.table = T;
neb.reactionCoordinate = s;
neb.energyZeroed_meV = E0;
neb.forwardBarrier_meV = barrier;
neb.reverseBarrier_meV = max(E - E(end));
neb.startRegistry = [T.ua(1), T.ub(1)];
neb.endRegistry = [T.ua(end), T.ub(end)];
neb.sourcePath = path;
neb.claimLevel = 'NEB-calibrated barrier only if images are fully relaxed and convergence settings are documented.';
end
