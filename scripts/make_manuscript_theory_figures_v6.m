function make_manuscript_theory_figures_v6(rootDir)
%MAKE_MANUSCRIPT_THEORY_FIGURES_V6 Generate manuscript-style theory figures.
%
% Outputs are saved to output/figures_v6.  These figures are diagnostic and
% should be regenerated after replacing template DFT/NEB data with real data.

if nargin < 1 || isempty(rootDir)
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    if isempty(rootDir); rootDir = pwd; end
end
addpath(genpath(fullfile(rootDir, 'functions')));
outDir = fullfile(rootDir, 'output', 'figures_v6');
if ~exist(outDir, 'dir'); mkdir(outDir); end

p = default_res2_params();
if exist('apply_research_guided_v3_constraints', 'file') == 2
    p = apply_research_guided_v3_constraints(p);
end

%% Figure T1: registry energy landscape and polar states
uaGrid = linspace(-1.6, 1.6, 180);
ubGrid = linspace(-0.9, 0.9, 120);
[UA, UB] = meshgrid(uaGrid, ubGrid);
F = sliding_free_energy(UA, UB, 0, p);
states = registry_state_catalog(p);
fig = figure('Color','w','Position',[100 100 760 560]);
contourf(UA, UB, F, 28, 'LineColor','none'); colorbar; hold on;
scatter(states.ua, states.ub, 65, 'filled');
text(states.ua+0.03, states.ub+0.03, states.label, 'Interpreter','none', 'FontSize', 8);
xlabel('u_a'); ylabel('u_b'); title('V6 Fig T1. Registry energy landscape and polar registry states');
box on; grid on;
saveas(fig, fullfile(outDir, 'FigT1_registry_energy_landscape.png'));
close(fig);

%% Figure T2: V4/V6 polarization decomposition
pz = sliding_polarization_v4(states.ua, states.ub, p);
fig = figure('Color','w','Position',[100 100 760 520]);
bar([pz.P_landau, pz.P_berry_like, pz.P_charge_transfer, pz.Pz]);
set(gca, 'XTickLabel', states.label, 'XTickLabelRotation', 30);
ylabel('P_z proxy'); title('V6 Fig T2. Polarization decomposition');
legend({'Landau','Berry-like','Charge-transfer','Total'}, 'Location','best');
box on; grid on;
saveas(fig, fullfile(outDir, 'FigT2_polarization_decomposition.png'));
close(fig);

%% Figure T3: resonant Raman excitation profile
E = linspace(1.42, 1.70, 260)';
rr1 = resonant_raman_matrix_element_v6(E, states.ua(1), states.ub(1), p, 1);
rr2 = resonant_raman_matrix_element_v6(E, states.ua(2), states.ub(2), p, 1);
fig = figure('Color','w','Position',[100 100 760 520]);
plot(E, rr1.total, 'LineWidth', 2); hold on;
plot(E, rr2.total, 'LineWidth', 2);
xlabel('Laser energy (eV)'); ylabel('Resonant Raman proxy');
title('V6 Fig T3. Branch-resolved resonant Raman profile');
legend(states.label{1}, states.label{2}, 'Interpreter','none', 'Location','best');
box on; grid on;
saveas(fig, fullfile(outDir, 'FigT3_resonant_raman_profile.png'));
close(fig);

%% Figure T4: rate-dependent hysteresis proxy
rates = [0.005, 0.02, 0.08];
fig = figure('Color','w','Position',[100 100 760 520]);
hold on;
for i = 1:numel(rates)
    sweep.Emax = 1.2; sweep.nPoints = 260; sweep.sweepRate_norm_per_s = rates(i); sweep.T_K = p.landau.T;
    sim = simulate_rate_dependent_hysteresis(p, 50, sweep, struct());
    plot(sim.E, sim.state, 'LineWidth', 1.7);
end
xlabel('Normalized electric field'); ylabel('Switching state proxy');
title('V6 Fig T4. Rate-dependent hysteresis proxy');
legend(compose('sweep rate %.3g', rates), 'Location','best');
box on; grid on;
saveas(fig, fullfile(outDir, 'FigT4_rate_dependent_hysteresis.png'));
close(fig);

%% Figure T5: joint inversion confidence basin demo
targetObs = bilayer_response_observables(states.ua(1), states.ub(1), 0, p);
target = struct('ramanThetaDeg', targetObs.ramanThetaDeg, ...
    'X1Energy', targetObs.X1Energy, 'X1AxisDeg', targetObs.X1AxisDeg, ...
    'X2Energy', targetObs.X2Energy, 'X2AxisDeg', targetObs.X2AxisDeg, ...
    'shgIntensity', targetObs.shgIntensity, 'ulfFrequency', targetObs.ulfFrequency);
inv = joint_registry_inversion_grid(target, p);
fig = figure('Color','w','Position',[100 100 760 560]);
imagesc(inv.uaGrid, inv.ubGrid, inv.deltaLossGrid); axis xy; colorbar; hold on;
contour(inv.uaGrid, inv.ubGrid, inv.deltaLossGrid, [2.30 2.30], 'k', 'LineWidth', 1.5);
scatter(inv.best.ua, inv.best.ub, 80, 'filled');
xlabel('u_a'); ylabel('u_b'); title('V6 Fig T5. Joint registry inversion confidence basin');
box on;
saveas(fig, fullfile(outDir, 'FigT5_joint_inversion_confidence_basin.png'));
close(fig);

%% Figure T6: parameter sensitivity ranking
sens = parameter_sensitivity_analysis(p);
fig = figure('Color','w','Position',[100 100 820 520]);
bar(sens.table.relativeSensitivity);
set(gca, 'XTick', 1:height(sens.table), 'XTickLabel', sens.table.parameter, 'XTickLabelRotation', 35);
ylabel('Relative sensitivity'); title('V6 Fig T6. Parameter sensitivity ranking');
box on; grid on;
saveas(fig, fullfile(outDir, 'FigT6_parameter_sensitivity.png'));
close(fig);

fprintf('V6 manuscript theory figures saved to:\n%s\n', outDir);
end
