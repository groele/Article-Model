%% Fast non-figure smoke tests for the ReS2 sliding model
clear; clc;
addpath(genpath('functions'));

p = default_res2_params();
outDir = fullfile('output', 'smoke_tests');
report = validate_model_physics(p, outDir);
assert(report.allPassed, 'Physics validation checks failed.');

grad = finite_difference_gradient_check(p);
assert(grad.passed, 'Analytic sliding gradient does not match finite differences.');

periodic = registry_periodicity_check(p);
assert(periodic.passed, 'Registry potential is not periodic under integer translations.');

states = registry_state_catalog(p);
assert(height(states) >= 4, 'Registry state catalog is incomplete.');

scan = shg_angular_scan(states.ua(1), states.ub(1), p);
assert(all(isfinite(scan.intensity)), 'SHG angular scan produced nonfinite intensity.');

peak = exciton_peak_observables(states.ua(1), states.ub(1), p);
assert(numel(peak.energy_eV) == 2, 'PL model must expose two ReS2 exciton peaks.');
assert(abs(diff(peak.energy_eV)) > 0.005, 'X1/X2 PL peaks are not resolved.');
axisGap = abs(mod(diff(peak.axis_deg) + 90, 180) - 90);
assert(axisGap > 20, 'X1/X2 polarization axes are not distinct.');

fprintf('ReS2 model smoke tests passed. Gradient error %.3g, periodicity error %.3g.\n', ...
    grad.max_abs_error, periodic.max_abs_error);
