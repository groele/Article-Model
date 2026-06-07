%% RUN_V5_MODEL_AUDIT
% End-to-end audit for the research-guided V5 ReS2 sliding model.
%
% This script intentionally avoids overwriting the original demo pipeline.
% It generates additional diagnostics for:
%   1. polar-state operation consistency;
%   2. DFT registry-grid fitting, if template/real data are present;
%   3. NEB barrier import, if template/real data are present;
%   4. scalar-P vs 2D-registry model ablation;
%   5. joint registry inversion and leave-one-channel-out stability.

clear; clc;
rootDir = fileparts(fileparts(mfilename('fullpath')));
if isempty(rootDir); rootDir = pwd; end
addpath(genpath(fullfile(rootDir, 'functions')));
outDir = fullfile(rootDir, 'output', 'v5_audit');
if ~exist(outDir, 'dir'); mkdir(outDir); end

p = default_res2_params();
if exist('apply_research_guided_v3_constraints', 'file') == 2
    p = apply_research_guided_v3_constraints(p);
end
p.symmetry.polarOperation = default_res2_symmetry_config();

fprintf('Checking polar-state operation...\n');
check_polar_state_operation(p, outDir);

fprintf('Running V4 validation...\n');
if exist('validate_model_v4', 'file') == 2
    validate_model_v4(p, fullfile(outDir, 'validation_v4'));
end

fprintf('Fitting DFT registry template, if available...\n');
dftPath = fullfile(rootDir, 'data', 'dft_registry_grid_template.csv');
if exist(dftPath, 'file')
    dft = load_dft_registry_grid(dftPath);
    energyFit = fit_registry_fourier_from_dft(dft, p);
    Tfit = table(energyFit.labels(:), energyFit.coefficients(:), ...
        'VariableNames', {'basis','coefficient_meV'});
    writetable(Tfit, fullfile(outDir, 'dft_registry_energy_fourier_fit.csv'));
    if dft.hasPz
        pfit = fit_polarization_from_berry_dft(dft, p);
        Tp = table(pfit.labels(:), pfit.parity(:), pfit.coefficients(:), ...
            'VariableNames', {'basis','parity','coefficient'});
        writetable(Tp, fullfile(outDir, 'berry_polarization_fit.csv'));
    end
end

fprintf('Importing NEB template, if available...\n');
nebPath = fullfile(rootDir, 'data', 'neb_barrier_path_template.csv');
if exist(nebPath, 'file')
    neb = import_neb_barrier_path(nebPath);
    Tneb = table(neb.reactionCoordinate(:), neb.energyZeroed_meV(:), ...
        'VariableNames', {'reaction_coordinate','energy_zeroed_meV'});
    writetable(Tneb, fullfile(outDir, 'neb_barrier_path.csv'));
end

fprintf('Running scalar-P vs 2D-registry ablation...\n');
run_ablation_scalarP_vs_registry2D(p, fullfile(outDir, 'ablation'));

fprintf('Running joint registry inversion demo...\n');
states = registry_state_catalog(p);
targetUa = states.ua(1);
targetUb = states.ub(1);
obs = bilayer_response_observables(targetUa, targetUb, 0, p);
target = struct();
target.ramanThetaDeg = obs.ramanThetaDeg;
target.X1Energy = obs.X1Energy;
target.X1AxisDeg = obs.X1AxisDeg;
target.X2Energy = obs.X2Energy;
target.X2AxisDeg = obs.X2AxisDeg;
target.shgIntensity = obs.shgIntensity;
target.ulfFrequency = obs.ulfFrequency;
inv = joint_registry_inversion_grid(target, p);
loo = leave_one_channel_out_test(target, p);
Tloo = loo.table;
writetable(Tloo, fullfile(outDir, 'leave_one_channel_out_registry_inversion.csv'));
Tbest = table(inv.best.ua, inv.best.ub, inv.best.loss, inv.confidenceAreaFraction, ...
    'VariableNames', {'best_ua','best_ub','best_loss','confidence_area_fraction'});
writetable(Tbest, fullfile(outDir, 'joint_registry_inversion_best.csv'));

fprintf('\nV5 audit finished. Outputs are in:\n%s\n', outDir);
