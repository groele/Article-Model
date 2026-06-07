function minima = registry_minima_search(p, uaRange, ubRange, nUa, nUb)
%REGISTRY_MINIMA_SEARCH Find local minima of F(ua,ub,E=0) on a grid.

if nargin < 2 || isempty(uaRange)
    uaRange = [-1.5, 1.5];
end
if nargin < 3 || isempty(ubRange)
    ubRange = [-0.8, 0.8];
end
if nargin < 4 || isempty(nUa)
    nUa = 101;
end
if nargin < 5 || isempty(nUb)
    nUb = 81;
end

uaGrid = linspace(uaRange(1), uaRange(2), nUa);
ubGrid = linspace(ubRange(1), ubRange(2), nUb);
[UA, UB] = meshgrid(uaGrid, ubGrid);
F = sliding_free_energy(UA, UB, 0, p);

rows = [];
for r = 2:size(F, 1)-1
    for c = 2:size(F, 2)-1
        patch = F(r-1:r+1, c-1:c+1);
        center = F(r, c);
        if center == min(patch(:)) && sum(abs(patch(:) - center) < eps) == 1
            rows = [rows; UA(r,c), UB(r,c), center, sliding_polarization(UA(r,c), UB(r,c), p)]; %#ok<AGROW>
        end
    end
end

if isempty(rows)
    minima = table([], [], [], [], 'VariableNames', {'ua','ub','F0','Pz'});
    return;
end

[~, order] = sort(rows(:, 3), 'ascend');
rows = rows(order, :);
minima = array2table(rows, 'VariableNames', {'ua','ub','F0','Pz'});
end
