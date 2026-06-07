function report = validate_model_physics(p, outDir)
%VALIDATE_MODEL_PHYSICS Run lightweight physics and numerical checks.

if nargin < 2 || isempty(outDir)
    outDir = fullfile(pwd, 'output', 'validation');
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

states = registry_state_catalog(p);
barriers = extract_registry_barriers(p);
prov = model_parameter_provenance_table(p);
materialTable = material_parameter_table(p);
minima = registry_minima_search(p);
gradCheck = finite_difference_gradient_check(p);
periodicCheck = registry_periodicity_check(p);
peak0 = exciton_peak_observables(states.ua(1), states.ub(1), p);
axisGap = abs(mod(diff(peak0.axis_deg) + 90, 180) - 90);
physStates = sliding_physical_units(states.ua, states.ub, zeros(height(states), 1), p);

E = linspace(-1.2, 1.2, 101)';
[ua, ub, Pz] = minimize_sliding_path(E, p);

pNoShear = p;
pNoShear.landau.kxy = 0;
[~, ub0] = minimize_sliding_path(E, pNoShear);

pHighT = p;
pHighT.landau.T = 650;
pHighT.landau.ax = abs(pHighT.landau.ax0) * (pHighT.landau.T / pHighT.landau.Tc - 1);
pHighT.landau.useRegistryPotential = false;
[~, ~, PHighT] = minimize_sliding_path(linspace(-0.2, 0.2, 21)', pHighT);

checks = {
    'registry_state_count', height(states), height(states) >= 4, ...
        'At least four labeled registry states are exposed.';
    'registry_barrier_positive', min(barriers.barrier_forward), ...
        all(barriers.barrier_forward > 0), 'Straight-path barriers are positive.';
    'finite_sliding_path', max(abs([ua; ub; Pz])), ...
        all(isfinite([ua; ub; Pz])), 'Gradient descent returns finite states.';
    'polarization_switches', max(Pz)-min(Pz), ...
        (max(Pz)-min(Pz)) > 0.2, 'Field sweep changes Pz appreciably.';
    'kxy_limiting_case', max(abs(ub0)), ...
        max(abs(ub0)) < max(abs(ub)) + 0.5, 'kxy=0 limiting case remains bounded.';
    'high_temperature_small_signal', max(abs(PHighT)), ...
        max(abs(PHighT)) < 0.5, 'Paraelectric high-T local model has small low-field Pz.'
    'analytic_gradient_check', gradCheck.max_abs_error, ...
        gradCheck.passed, 'Analytic gradient agrees with finite-difference free-energy gradient.';
    'registry_periodicity', periodicCheck.max_abs_error, ...
        periodicCheck.passed, 'Registry potential is invariant under integer model-coordinate translations.';
    'registry_minima_found', height(minima), ...
        height(minima) >= 2, 'Grid scan finds multiple local registry minima.'
    'two_pl_peaks_resolved', 1e3*abs(diff(peak0.energy_eV)), ...
        abs(diff(peak0.energy_eV)) > 0.005, 'PL readout keeps X1 and X2 as two resolved peaks.'
    'two_pl_axes_distinct', axisGap, ...
        axisGap > 20, 'X1 and X2 retain distinct linear-polarization axes.'
    'material_lattice_area_positive', p.material.unit_cell_area_A2, ...
        p.material.unit_cell_area_A2 > 10, 'ReS2 triclinic in-plane unit-cell area is positive and physical.';
    'physical_polarization_scale', max(abs(physStates.Pz_uCcm2)), ...
        max(abs(physStates.Pz_uCcm2)) < 1, 'Default physical Pz scale remains in a cautious sliding-ferroelectric range.'
    };

Tchecks = cell2table(checks, 'VariableNames', ...
    {'check_name','metric','passed','interpretation'});
writetable(states, fullfile(outDir, 'registry_state_catalog.csv'));
writetable(barriers, fullfile(outDir, 'registry_barriers.csv'));
writetable(minima, fullfile(outDir, 'registry_minima_grid.csv'));
writetable(prov, fullfile(outDir, 'parameter_provenance.csv'));
writetable(materialTable, fullfile(outDir, 'material_parameter_table.csv'));
writetable(Tchecks, fullfile(outDir, 'physics_validation_checks.csv'));

report = struct();
report.states = states;
report.barriers = barriers;
report.minima = minima;
report.provenance = prov;
report.material = materialTable;
report.physicalStates = physStates;
report.checks = Tchecks;
report.allPassed = all(Tchecks.passed);

write_audit_markdown(report, fullfile(outDir, 'MODEL_AUDIT_REPORT.md'));
end

function write_audit_markdown(report, path)
fid = fopen(path, 'w');
if fid < 0
    warning('Could not write audit report: %s', path);
    return;
end
cleanup = onCleanup(@() fclose(fid));

fprintf(fid, '# ReS2 Sliding Model Audit Report\n\n');
fprintf(fid, 'Claim level: semi-quantitative unless a parameter is explicitly calibrated.\n\n');
fprintf(fid, '## Validation checks\n\n');
for i = 1:height(report.checks)
    status = 'FAIL';
    if report.checks.passed(i)
        status = 'PASS';
    end
    fprintf(fid, '- %s: %s (metric = %.4g). %s\n', status, ...
        report.checks.check_name{i}, report.checks.metric(i), ...
        report.checks.interpretation{i});
end
fprintf(fid, '\n## Registry states\n\n');
for i = 1:height(report.states)
    fprintf(fid, '- %s: ua=%.3f, ub=%.3f, Pz=%.3f, F0=%.3f\n', ...
        report.states.label{i}, report.states.ua(i), report.states.ub(i), ...
        report.states.Pz(i), report.states.F0(i));
end
fprintf(fid, '\n## Grid-detected minima\n\n');
for i = 1:min(8, height(report.minima))
    fprintf(fid, '- minimum %d: ua=%.3f, ub=%.3f, Pz=%.3f, F0=%.3f\n', ...
        i, report.minima.ua(i), report.minima.ub(i), ...
        report.minima.Pz(i), report.minima.F0(i));
end
fprintf(fid, '\n## Physical scale for labeled registry states\n\n');
for i = 1:height(report.states)
    fprintf(fid, ['- %s: |u|=%.3f A, Pz=%.4f uC/cm^2, ', ...
        'sheet charge=%.3e cm^-2, charge transfer=%.3e e/cell\n'], ...
        report.states.label{i}, report.physicalStates.sliding_magnitude_A(i), ...
        report.physicalStates.Pz_uCcm2(i), report.physicalStates.sheet_charge_cm2(i), ...
        report.physicalStates.charge_transfer_e_per_cell(i));
end
fprintf(fid, '\n## Material constants used for scaling\n\n');
for i = 1:min(12, height(report.material))
    fprintf(fid, '- %s = %.4g %s\n', report.material.name{i}, ...
        report.material.value(i), report.material.unit{i});
end
fprintf(fid, '\n## Claim boundary\n\n');
fprintf(fid, ['This model should be cited as a registry-resolved phenomenological framework. ', ...
    'Quantitative claims require replacing the default amplitudes and couplings with DFT or experimental fits.\n']);
end
