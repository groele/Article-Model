function barriers = extract_registry_barriers(p)
%EXTRACT_REGISTRY_BARRIERS Estimate pairwise barriers along straight paths.

states = registry_state_catalog(p);
n = height(states);
rows = [];
for i = 1:n
    for j = i+1:n
        t = linspace(0, 1, 301)';
        ua = states.ua(i) + t .* (states.ua(j) - states.ua(i));
        ub = states.ub(i) + t .* (states.ub(j) - states.ub(i));
        F = sliding_free_energy(ua, ub, 0, p);
        saddle = max(F);
        startF = F(1);
        endF = F(end);
        barrierForward = saddle - startF;
        barrierReverse = saddle - endF;
        rows = [rows; i, j, barrierForward, barrierReverse, saddle]; %#ok<AGROW>
    end
end

barriers = array2table(rows, 'VariableNames', ...
    {'from_state_id','to_state_id','barrier_forward','barrier_reverse','saddle_energy'});
end
