%% Bilayer ReS2 2D sliding-coordinate-resolved Raman–PL theory model
%  This script demonstrates the full 2D sliding-ferroelectric theory pipeline:
%    §1  2D Stacking potential energy surface and field-driven curved path
%    §2  Polarized Raman: polar plots and tensor fitting
%    §3  Exciton Hamiltonian and polarized PL maps
%    §4  Observables vs 2D sliding coordinates along the path
%    §5  Joint 2D inversion of [ua, ub] from Raman + PL
%
%  All calculations natively support 2D sliding vectors u = [ua; ub].

if ~exist('isLauncherRunning', 'var')
    clear; clc; close all;
end
addpath(genpath('functions'));

rootDir = fileparts(mfilename('fullpath'));
if isempty(rootDir); rootDir = pwd; end
outDir = fullfile(rootDir, 'output');
if ~exist(outDir, 'dir'); mkdir(outDir); end

p = default_res2_params();
stateCatalog = registry_state_catalog(p);
barrierTable = extract_registry_barriers(p);
provenanceTable = model_parameter_provenance_table(p);
writetable(stateCatalog, fullfile(outDir, 'registry_state_catalog.csv'));
writetable(barrierTable, fullfile(outDir, 'registry_barriers.csv'));
writetable(provenanceTable, fullfile(outDir, 'parameter_provenance.csv'));

%% ========== §1  2D Sliding potential energy surface and hysteresis ==========

Efield = linspace(-1.2, 1.2, 121);
[uaPath, ubPath, PPath] = minimize_sliding_path(Efield, p);

% Generate 2D Free Energy Surface at E = 0
uaGrid = linspace(-1.6, 1.6, 200);
ubGrid = linspace(-0.8, 0.8, 100);
[UA, UB] = meshgrid(uaGrid, ubGrid);
F_PES = sliding_free_energy(UA, UB, 0, p);

% Fig 1: 2D PES contour plot
fig = figure('Color','w','Position',[80 80 800 600]);
contourf(UA, UB, F_PES, 25, 'LineColor', 'none');
colormap(sky); colorbar;
hold on;
% Overlay the relaxed sliding path (MEP under E-field sweep)
plot(uaPath, ubPath, 'r--', 'LineWidth', 2.5);
scatter(uaPath(1), ubPath(1), 80, 'b', 'filled');
scatter(uaPath(end), ubPath(end), 80, 'r', 'filled');
xlabel('Easy-axis sliding coordinate u_a'); 
ylabel('Hard-axis sliding coordinate u_b');
title('Fig 1: 2D Stacking potential energy surface and sliding path');
legend('PES F(u_a, u_b)', 'Relaxed path (MEP)', 'Start (-P_z)', 'End (+P_z)', 'Location', 'best');
grid on; box on;
saveas(fig, fullfile(outDir, 'Fig1_free_energy_landscape.png'));

% Fig 2: Field-driven sliding coordinate hysteresis (ua and ub)
fig = figure('Color','w','Position',[80 80 720 520]);
plot(Efield, uaPath, 'b-', 'LineWidth', 2); hold on;
plot(Efield, ubPath, 'r-', 'LineWidth', 2);
ylabel('Relaxed sliding coordinates'); xlabel('Normalized vertical electric field E');
title('Fig 2: 2D field-driven sliding-state evolution (hysteresis)');
legend('u_a (easy axis)', 'u_b (hard axis)', 'Location', 'best');
grid on; box on;
saveas(fig, fullfile(outDir, 'Fig2_sliding_path_vs_field.png'));

% Fig 3: Switchable out-of-plane polarization
fig = figure('Color','w','Position',[80 80 720 520]);
plot(Efield, PPath, 'LineWidth', 2, 'Color', [0.1, 0.6, 0.2]);
ylabel('P_z(u_a, u_b) (arb. units)'); xlabel('Normalized vertical electric field E');
title('Fig 3: Switchable out-of-plane polarization from 2D sliding');
grid on; box on;
saveas(fig, fullfile(outDir, 'Fig3_polarization_vs_field.png'));

%% ========== §2  Synthetic polarized Raman for two sliding states ==========

% Two literature-anchored polar registry states from the registry catalog.
uaStates = stateCatalog.ua(1:2)';
ubStates = stateCatalog.ub(1:2)';
stateNames = cellstr(stateCatalog.label(1:2));
angles     = (0:5:175)';
modeList   = 1:numel(p.ramanModes);

rng(6);

nAngles = numel(angles);
nModes  = numel(modeList);
nStates = numel(uaStates);
nRows   = nStates * nModes * nAngles;
ramanRows = zeros(nRows, 4);
row = 0;

for is = 1:nStates
    for im = modeList
        I = raman_intensity_parallel(angles, uaStates(is), ubStates(is), p, im);
        I = I + 0.025 * max(I) * randn(size(I));
        for ia = 1:nAngles
            row = row + 1;
            ramanRows(row, :) = [is, im, angles(ia), I(ia)];
        end
    end
end
ramanTable = array2table(ramanRows, 'VariableNames', ...
    {'state_id','mode_id','angle_deg','intensity'});
writetable(ramanTable, fullfile(outDir, 'synthetic_polarized_Raman.csv'));

% Plot and fit Raman polar plots
nFits   = nStates * nModes;
fitRows = zeros(nFits, 5);
frow    = 0;

for is = 1:nStates
    fig = figure('Color','w','Position',[80 80 760 620]);
    tiledlayout(2,2,'Padding','compact','TileSpacing','compact');
    for im = modeList
        idx = ramanTable.state_id==is & ramanTable.mode_id==im;
        th  = ramanTable.angle_deg(idx);
        y   = ramanTable.intensity(idx);
        fit = fit_raman_tensor(th, y);
        frow = frow + 1;
        fitRows(frow, :) = [is, im, fit.thetaMax_deg, fit.anisotropy, fit.rmse];
        nexttile;
        polarplot(deg2rad(th), normalize01(y), 'o'); hold on;
        thFine = linspace(0, 175, 360)';
        polarplot(deg2rad(thFine), normalize01(fit.modelFun(thFine)), 'LineWidth', 1.8);
        title(sprintf('%s, mode %d: \\theta_{max}=%.1f°', stateNames{is}, im, fit.thetaMax_deg));
    end
    saveas(fig, fullfile(outDir, sprintf('Fig4_Raman_polar_state_%d.png', is)));
end
fitRamanTable = array2table(fitRows, 'VariableNames', ...
    {'state_id','mode_id','thetaMax_deg','Imax_over_Imin','rmse'});
writetable(fitRamanTable, fullfile(outDir, 'fitted_Raman_tensor_summary.csv'));

%% ========== §3  Exciton Hamiltonian and polarized PL maps ==========

energy = linspace(1.43, 1.66, 600)';
phi    = (0:10:170)';

plSummary = zeros(nStates * 2, 7);
prow = 0;

for is = 1:nStates
    [PLmap, comp] = pl_spectrum_model(energy, phi, uaStates(is), ubStates(is), p);
    PLmap = PLmap + 0.006 * max(PLmap(:)) * randn(size(PLmap));

    % Save PL map
    T = array2table([energy, PLmap], 'VariableNames', ...
        [{'energy_eV'}, compose('phi_%d', phi')]);
    writetable(T, fullfile(outDir, sprintf('synthetic_PL_map_state_%d.csv', is)));

    % Heatmap figure
    fig = figure('Color','w','Position',[80 80 800 560]);
    imagesc(phi, energy, PLmap); axis xy;
    xlabel('Analyzer angle \phi (deg)'); ylabel('Energy (eV)');
    title(sprintf('Fig 5: Polarization-resolved PL: %s', stateNames{is}));
    colorbar;
    saveas(fig, fullfile(outDir, sprintf('Fig5_PLmap_state_%d.png', is)));

    % Stokes parameters
    for jc = 1:numel(comp.E)
        Iphi = linear_pl_peak_intensity(phi, comp.theta_deg(jc), ...
            comp.peak_dolp(jc), comp.osc(jc) * comp.population(jc));
        S    = stokes_from_linear_polar(phi, Iphi);
        prow = prow + 1;
        plSummary(prow, :) = [is, jc, comp.E(jc), comp.Gamma(jc), ...
            comp.theta_deg(jc), S.DOLP, S.theta_deg];
    end
end
plTable = array2table(plSummary, 'VariableNames', ...
    {'state_id','exciton_id','model_energy_eV','model_gamma_eV', ...
     'model_theta_deg','fit_DOLP','fit_theta_deg'});
writetable(plTable, fullfile(outDir, 'fitted_PL_Stokes_summary.csv'));

%% ========== §4  Observables vs 2D sliding coordinates along the path ==========

nQ = numel(uaPath);

Eplus    = zeros(1, nQ);   Eminus = zeros(1, nQ);
thPlus   = zeros(1, nQ);   thMinus = zeros(1, nQ);
oscLower = zeros(1, nQ);   oscUpper = zeros(1, nQ);
x1Dolp   = zeros(1, nQ);   x2Dolp = zeros(1, nQ);
x1S1     = zeros(1, nQ);   x1S2 = zeros(1, nQ);
x2S1     = zeros(1, nQ);   x2S2 = zeros(1, nQ);
omegaModes = zeros(nModes, nQ);

for k = 1:nQ
    peak = exciton_peak_observables(uaPath(k), ubPath(k), p);
    Eminus(k)   = peak.energy_eV(1);   Eplus(k)  = peak.energy_eV(2);
    thMinus(k)  = peak.axis_deg(1);    thPlus(k) = peak.axis_deg(2);
    oscLower(k) = peak.oscillator_strength(1);
    oscUpper(k) = peak.oscillator_strength(2);
    x1Dolp(k)   = peak.dolp(1);        x2Dolp(k) = peak.dolp(2);
    x1S1(k)     = peak.S1(1);          x1S2(k) = peak.S2(1);
    x2S1(k)     = peak.S1(2);          x2S2(k) = peak.S2(2);

    for im = 1:nModes
        omegaModes(im, k) = raman_mode_frequency(uaPath(k), ubPath(k), p, im);
    end
end

% Fig 6: Exciton energies
fig = figure('Color','w','Position',[80 80 760 520]);
plot(uaPath, Eminus, 'LineWidth', 2); hold on;
plot(uaPath, Eplus, 'LineWidth', 2);
xlabel('Easy-axis sliding coordinate u_a'); ylabel('Exciton energy (eV)');
title('Fig 6: Sliding-modulated two-peak PL exciton energies');
legend('X1 lower-energy peak','X2 higher-energy peak','Location','best');
grid on; box on;
saveas(fig, fullfile(outDir, 'Fig6_exciton_energy_vs_sliding.png'));

% Fig 7: Exciton polarization axes
fig = figure('Color','w','Position',[80 80 760 520]);
plot(uaPath, thMinus, 'LineWidth', 2); hold on;
plot(uaPath, thPlus, 'LineWidth', 2);
xlabel('Easy-axis sliding coordinate u_a'); ylabel('Exciton polarization axis (deg)');
title('Fig 7: Peak-resolved ReS2 exciton polarization axes');
legend('X1 axis','X2 axis','Location','best');
grid on; box on;
saveas(fig, fullfile(outDir, 'Fig7_exciton_axis_vs_sliding.png'));

% Fig 8: Raman mode frequency shift vs sliding
fig = figure('Color','w','Position',[80 80 760 520]);
hold on;
colors = lines(nModes);
for im = 1:nModes
    domega = omegaModes(im, :) - p.ramanModes(im).omega0;
    plot(uaPath, domega, 'LineWidth', 2, 'Color', colors(im,:));
end
xlabel('Easy-axis sliding coordinate u_a'); ylabel('\Delta\omega (cm^{-1})');
title('Fig 8: 2D stacking-dependent phonon frequency shift');
legendStr = arrayfun(@(im) sprintf('Mode %d (%.0f cm^{-1})', im, p.ramanModes(im).omega0), ...
    1:nModes, 'UniformOutput', false);
legend(legendStr, 'Location', 'best');
grid on; box on;
saveas(fig, fullfile(outDir, 'Fig8_raman_frequency_vs_sliding.png'));

% Fig 9: Peak-resolved DOLP and oscillator strengths
fig = figure('Color','w','Position',[80 80 760 520]);
yyaxis left;
plot(uaPath, x1Dolp, 'LineWidth', 2); hold on;
plot(uaPath, x2Dolp, 'LineWidth', 2);
ylabel('Peak-resolved DOLP');
yyaxis right;
plot(uaPath, oscLower ./ (oscUpper + eps), 'LineWidth', 2);
ylabel('X1 / X2 oscillator-strength ratio');
xlabel('Easy-axis sliding coordinate u_a');
title('Fig 9: Two-peak PL polarization, not a merged DOLP');
legend('X1 DOLP','X2 DOLP','X1/X2 oscillator ratio','Location','best');
grid on; box on;
saveas(fig, fullfile(outDir, 'Fig9_dolp_vs_sliding.png'));

% Fig 10: Stokes-plane trajectories for both PL peaks
fig = figure('Color','w','Position',[80 80 620 560]);
plot(x1S1, x1S2, 'LineWidth', 2); hold on;
plot(x2S1, x2S2, 'LineWidth', 2);
scatter(x1S1(1), x1S2(1), 60, 'filled');
scatter(x2S1(1), x2S2(1), 60, 'filled');
xlabel('S_1/S_0'); ylabel('S_2/S_0'); axis equal; grid on; box on;
title('Fig 10: Peak-resolved PL Stokes trajectories for X1 and X2');
legend('X1 trajectory', 'X2 trajectory', 'X1 start', 'X2 start', 'Location','best');
saveas(fig, fullfile(outDir, 'Fig10_Stokes_trajectory.png'));

% Fig 14: Ultralow-frequency Raman modes along the sliding path
obsPath = bilayer_response_observables(uaPath, ubPath, Efield(:), p);
fig = figure('Color','w','Position',[80 80 760 520]);
hold on;
ulfLabels = strings(1, numel(p.ulfModes));
for im = 1:numel(p.ulfModes)
    plot(uaPath, obsPath.ulfFrequency(:, im), 'LineWidth', 2);
    ulfLabels(im) = string(p.ulfModes(im).label);
end
xlabel('Easy-axis sliding coordinate u_a');
ylabel('ULF Raman frequency (cm^{-1})');
title('Fig 14: Stacking-sensitive ultralow-frequency Raman modes');
legend(cellstr(ulfLabels), 'Location', 'best');
grid on; box on;
saveas(fig, fullfile(outDir, 'Fig14_ULF_Raman_vs_sliding.png'));

% Fig 15: Tensor SHG angular fingerprints for the two registry states
pumpAngles = (0:2:178)';
fig = figure('Color','w','Position',[80 80 760 560]);
for is = 1:nStates
    scan = shg_angular_scan(uaStates(is), ubStates(is), p, pumpAngles, 'parallel');
    polarplot(deg2rad(scan.angle_deg), normalize01(scan.intensity), 'LineWidth', 2);
    hold on;
end
title('Fig 15: Registry-resolved tensor SHG angular fingerprints');
legend(stateNames, 'Location', 'bestoutside');
saveas(fig, fullfile(outDir, 'Fig15_tensor_SHG_angular_fingerprints.png'));

%% ========== §5  Joint 2D inversion of [ua, ub] from Raman + PL ==========

jointRows = zeros(nStates, 6);
jointDetailRows = zeros(nStates, 10);
for is = 1:nStates
    obsRaman = ramanTable(ramanTable.state_id == is, :);
    obsPL    = readtable(fullfile(outDir, sprintf('synthetic_PL_map_state_%d.csv', is)));
    fitResult = joint_q_fit(obsRaman, obsPL, phi, p);
    jointRows(is, :) = [is, uaStates(is), ubStates(is), fitResult.ua_best, fitResult.ub_best, fitResult.loss_best];
    jointDetailRows(is, :) = [is, fitResult.ua_ci(1), fitResult.ua_ci(2), ...
        fitResult.ub_ci(1), fitResult.ub_ci(2), fitResult.raman_only_ua, ...
        fitResult.raman_only_ub, fitResult.pl_only_ua, fitResult.pl_only_ub, ...
        fitResult.confidence_delta];
end
jointTable = array2table(jointRows, 'VariableNames', ...
    {'state_id','true_ua','true_ub','fitted_ua','fitted_ub','joint_loss'});
writetable(jointTable, fullfile(outDir, 'joint_sliding_coordinate_fit.csv'));
jointDetailTable = array2table(jointDetailRows, 'VariableNames', ...
    {'state_id','ua_ci_low','ua_ci_high','ub_ci_low','ub_ci_high', ...
     'raman_only_ua','raman_only_ub','pl_only_ua','pl_only_ub','confidence_delta'});
writetable(jointDetailTable, fullfile(outDir, 'joint_sliding_coordinate_identifiability.csv'));

disp('Done. Results saved in output/.');
disp(jointTable);
