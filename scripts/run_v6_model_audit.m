%% RUN_V6_MODEL_AUDIT
% End-to-end V6 audit for the ReS2 sliding-ferroelectric model.
%
% V6 adds:
%   - branch-resolved resonant Raman / exciton-phonon coupling;
%   - rate-dependent Kramers-like switching;
%   - local parameter sensitivity;
%   - manuscript-style theory figures.

clear; clc;
rootDir = fileparts(fileparts(mfilename('fullpath')));
if isempty(rootDir); rootDir = pwd; end
addpath(genpath(fullfile(rootDir, 'functions')));
outDir = fullfile(rootDir, 'output', 'v6_audit');
if ~exist(outDir, 'dir'); mkdir(outDir); end

p = default_res2_params();
if exist('apply_research_guided_v3_constraints', 'file') == 2
    p = apply_research_guided_v3_constraints(p);
end
p.symmetry.polarOperation = default_res2_symmetry_config();

fprintf('Running V5 audit components...\n');
if exist(fullfile(rootDir, 'scripts', 'run_v5_model_audit.m'), 'file')
    run(fullfile(rootDir, 'scripts', 'run_v5_model_audit.m'));
end

fprintf('Running resonant Raman V6 demo...\n');
states = registry_state_catalog(p);
E = linspace(1.42, 1.70, 240)';
rr = resonant_raman_matrix_element_v6(E, states.ua(1), states.ub(1), p, 1);
Trr = table(rr.E_laser_eV, rr.X1, rr.X2, rr.total, ...
    'VariableNames', {'E_laser_eV','X1_channel','X2_channel','total_proxy'});
writetable(Trr, fullfile(outDir, 'resonant_raman_v6_profile.csv'));

fprintf('Running rate-dependent switching demo...\n');
sweep.Emax = 1.2; sweep.nPoints = 301; sweep.sweepRate_norm_per_s = 0.02; sweep.T_K = p.landau.T;
sim = simulate_rate_dependent_hysteresis(p, 50, sweep, struct());
Tsw = table(sim.E, sim.state, sim.Pswitch, sim.hazard, ...
    'VariableNames', {'E_norm','state_proxy','switch_probability','hazard'});
writetable(Tsw, fullfile(outDir, 'rate_dependent_hysteresis_v6.csv'));

fprintf('Running parameter sensitivity analysis...\n');
sens = parameter_sensitivity_analysis(p);
writetable(sens.table, fullfile(outDir, 'parameter_sensitivity_v6.csv'));

fprintf('Generating manuscript-style theory figures...\n');
make_manuscript_theory_figures_v6(rootDir);

fid = fopen(fullfile(outDir, 'MODEL_V6_AUDIT_SUMMARY.md'), 'w');
if fid >= 0
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '# ReS2 Sliding Model V6 Audit Summary\n\n');
    fprintf(fid, 'V6 adds resonant Raman, Kramers-like switching kinetics, sensitivity analysis, and manuscript-style figure generation.\n\n');
    fprintf(fid, '## Claim boundary\n\n');
    fprintf(fid, ['All V6 additions remain phenomenological until calibrated with excitation-dependent Raman, ', ...
        'NEB switching barriers, sweep-rate-dependent hysteresis, and parameter uncertainty estimates.\n\n']);
    fprintf(fid, '## Generated outputs\n\n');
    fprintf(fid, '- resonant_raman_v6_profile.csv\n');
    fprintf(fid, '- rate_dependent_hysteresis_v6.csv\n');
    fprintf(fid, '- parameter_sensitivity_v6.csv\n');
    fprintf(fid, '- output/figures_v6/FigT1-FigT6 PNG files\n');
end

fprintf('\nV6 audit finished. Outputs are in:\n%s\n', outDir);
