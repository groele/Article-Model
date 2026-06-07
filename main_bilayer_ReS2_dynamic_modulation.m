%% Bilayer ReS2 field-switchable 2D sliding-ferroelectric response map
%  This script builds a mechanism-level modulation diagram for bilayer ReS2
%  using 2D sliding coordinates [ua, ub].
%
%  Physical picture:
%    E_z selects polar stacking  →  ua, ub switch  →  five response channels
%    all modulate in a correlated manner.

if ~exist('isLauncherRunning', 'var')
    clear; clc; close all;
end
addpath(genpath('functions'));

rootDir = fileparts(mfilename('fullpath'));
if isempty(rootDir); rootDir = pwd; end
outDir = fullfile(rootDir, 'output');
if ~exist(outDir, 'dir'); mkdir(outDir); end

p = default_res2_params();
coercive = coercive_field_model(p);

%% ========== §1  Electric-field sweep with 2D hysteresis ==========

Eup   = linspace(-1.25, 1.25, 180)';
Edown = linspace(1.25, -1.25, 180)';

% Initial state: start from negative easy well
ua0_neg = -sqrt(abs(p.landau.ax) / p.landau.bx);
ub0_neg = (Eup(1) * p.landau.p1b - p.landau.kxy * ua0_neg) / p.landau.ky;

% Start from positive easy well
ua0_pos = sqrt(abs(p.landau.ax) / p.landau.bx);
ub0_pos = (Edown(1) * p.landau.p1b - p.landau.kxy * ua0_pos) / p.landau.ky;

[uaUp, ubUp, PUp] = track_sliding_branch(Eup, p, ua0_neg, ub0_neg);
[uaDown, ubDown, PDown] = track_sliding_branch(Edown, p, ua0_pos, ub0_pos);

Eloop = [Eup; Edown];
uaLoop = [uaUp; uaDown];
ubLoop = [ubUp; ubDown];
PLoop = [PUp; PDown];

obsUp   = bilayer_response_observables(uaUp, ubUp, Eup, p);
obsDown = bilayer_response_observables(uaDown, ubDown, Edown, p);
obsLoop = bilayer_response_observables(uaLoop, ubLoop, Eloop, p);

%% ========== §2  Comprehensive dynamic-response overview (4×3) ==========

fig = figure('Color','w','Position',[60 40 1280 900]);
tiledlayout(4, 3, 'Padding','compact', 'TileSpacing','compact');

% --- Row 1 ---
nexttile;
plot(Eup, uaUp, 'b-', 'LineWidth', 2); hold on;
plot(Edown, uaDown, 'b--', 'LineWidth', 2);
plot(Eup, ubUp, 'r-', 'LineWidth', 1.5);
plot(Edown, ubDown, 'r--', 'LineWidth', 1.5);
xlabel('E_z'); ylabel('Sliding coordinates');
title('Sliding coordinates u_a, u_b (E_z)');
legend('u_a up', 'u_a down', 'u_b up', 'u_b down', 'Location', 'best');
grid on; box on;

nexttile;
plot(Eup, PUp, 'LineWidth', 2); hold on;
plot(Edown, PDown, 'LineWidth', 2);
xlabel('E_z'); ylabel('P_z(u_a, u_b)');
title('Switchable polarization P_z');
grid on; box on;

nexttile;
plot(Eup, obsUp.shgIntensity, 'LineWidth', 2); hold on;
plot(Edown, obsDown.shgIntensity, 'LineWidth', 2);
xlabel('E_z'); ylabel('I_{2\omega} = |\chi^{(2)}|^2');
title('SHG intensity');
grid on; box on;

% --- Row 2 ---
nexttile;
plot(Eup, obsUp.shgPhase, 'LineWidth', 2); hold on;
plot(Edown, obsDown.shgPhase, 'LineWidth', 2);
xlabel('E_z'); ylabel('\Delta\phi (rad)');
title('SHG phase (encodes P_z sign)');
ylim([-0.5 pi+0.5]);
grid on; box on;

nexttile;
plot(Eup, obsUp.ramanThetaDeg, 'LineWidth', 2); hold on;
plot(Edown, obsDown.ramanThetaDeg, 'LineWidth', 2);
xlabel('E_z'); ylabel('\theta_R (deg)');
title('Raman polar-axis rotation');
grid on; box on;

nexttile;
plot(Eup, obsUp.ramanAnisotropy, 'LineWidth', 2); hold on;
plot(Edown, obsDown.ramanAnisotropy, 'LineWidth', 2);
xlabel('E_z'); ylabel('I_{max}/I_{min}');
title('Raman anisotropy');
grid on; box on;

% --- Row 3 ---
nexttile;
plot(Eup, obsUp.ramanFreqShift(:,1), 'LineWidth', 2); hold on;
plot(Edown, obsDown.ramanFreqShift(:,1), 'LineWidth', 2);
xlabel('E_z'); ylabel('\Delta\omega_1 (cm^{-1})');
title('Raman mode 1 frequency shift');
grid on; box on;

nexttile;
plot(Eup, 1e3*(obsUp.X1Energy - p.exciton.E0), 'LineWidth', 2); hold on;
plot(Eup, 1e3*(obsUp.X2Energy - p.exciton.E0), 'LineWidth', 2);
plot(Edown, 1e3*(obsDown.X1Energy - p.exciton.E0), '--', 'LineWidth', 2);
plot(Edown, 1e3*(obsDown.X2Energy - p.exciton.E0), '--', 'LineWidth', 2);
xlabel('E_z'); ylabel('\DeltaE_X (meV)');
title('Two PL peak energy tuning');
grid on; box on;

nexttile;
plot(Eup, obsUp.X1AxisDeg, 'LineWidth', 2); hold on;
plot(Eup, obsUp.X2AxisDeg, 'LineWidth', 2);
plot(Edown, obsDown.X1AxisDeg, '--', 'LineWidth', 2);
plot(Edown, obsDown.X2AxisDeg, '--', 'LineWidth', 2);
xlabel('E_z'); ylabel('\theta_X (deg)');
title('X1/X2 polarization axes');
grid on; box on;

% --- Row 4 ---
nexttile;
plot(Eup, obsUp.X1DOLP, 'LineWidth', 2); hold on;
plot(Eup, obsUp.X2DOLP, 'LineWidth', 2);
plot(Edown, obsDown.X1DOLP, '--', 'LineWidth', 2);
plot(Edown, obsDown.X2DOLP, '--', 'LineWidth', 2);
xlabel('E_z'); ylabel('DOLP');
title('Peak-resolved PL DOLP');
grid on; box on;

nexttile;
plot(Eup, obsUp.photocurrent, 'LineWidth', 2); hold on;
plot(Edown, obsDown.photocurrent, 'LineWidth', 2);
xlabel('E_z'); ylabel('J_{ph} proxy');
title('Photocurrent / PV readout');
grid on; box on;

nexttile;
scatter(obsLoop.X1S1, obsLoop.X1S2, 16, Eloop, 'filled'); hold on;
scatter(obsLoop.X2S1, obsLoop.X2S2, 16, Eloop, 'filled', 'Marker', 's');
xlabel('S_1/S_0'); ylabel('S_2/S_0');
title('X1/X2 PL Stokes-plane trajectories');
axis equal; grid on; box on; colorbar;

saveas(fig, fullfile(outDir, 'Fig11_bilayer_dynamic_response_map.png'));

%% ========== §3  Mechanism network diagram ==========

fig = figure('Color','w','Position',[100 90 1120 560]);
axis off;
nodes = {
    [0.05 0.62 0.16 0.14], 'Vertical field E_z';
    [0.28 0.62 0.18 0.14], '2D Sliding (u_a, u_b)';
    [0.53 0.72 0.17 0.12], 'Interlayer charge transfer';
    [0.76 0.72 0.17 0.12], 'Out-of-plane P_z';
    [0.53 0.48 0.17 0.12], 'Stacking-dependent hybridization';
    [0.76 0.48 0.17 0.12], 'Band edge / exciton tuning';
    [0.28 0.28 0.18 0.12], 'Low-symmetry Raman tensor';
    [0.53 0.24 0.17 0.12], 'SHG amplitude and phase';
    [0.76 0.24 0.17 0.12], 'PL polarization / photocurrent';
    };
for i = 1:size(nodes,1)
    annotation('textbox', nodes{i,1}, 'String', nodes{i,2}, ...
        'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
        'FontSize', 11, 'LineWidth', 1.2, 'BackgroundColor', [0.96 0.97 0.99]);
end
arrow([0.21 0.69], [0.28 0.69]);
arrow([0.46 0.69], [0.53 0.77]);
arrow([0.70 0.78], [0.76 0.78]);
arrow([0.46 0.66], [0.53 0.54]);
arrow([0.70 0.54], [0.76 0.54]);
arrow([0.36 0.62], [0.36 0.40]);
arrow([0.46 0.34], [0.53 0.30]);
arrow([0.70 0.30], [0.76 0.30]);
arrow([0.84 0.72], [0.84 0.60]);
annotation('textbox', [0.08 0.05 0.84 0.11], ...
    'String', {'Bilayer ReS2: two polar sliding states connected by anisotropy-confined 2D translation.', ...
    sprintf('E_z selects the lower-energy state through -E_z P_z(ua, ub). Vacancy proxy Ec = %.0f kV/cm.', coercive.coerciveField_kVcm)}, ...
    'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
    'FontSize', 10.5, 'LineStyle','none');
saveas(fig, fullfile(outDir, 'Fig12_bilayer_mechanism_network.png'));

%% ========== §4  Animated field-sweep modulation in 2D landscape ==========

gifFile = fullfile(outDir, 'Fig13_bilayer_dynamic_modulation.gif');
fig = figure('Color','w','Position',[120 80 980 620],'Visible','off');

% Grid for 2D Potential Energy Surface contour
uaGridAnim = linspace(-1.6, 1.6, 150);
ubGridAnim = linspace(-0.8, 0.8, 80);
[UA, UB] = meshgrid(uaGridAnim, ubGridAnim);

frameIds  = round(linspace(1, numel(Eloop), 80));

for jj = 1:numel(frameIds)
    i = frameIds(jj);
    clf(fig);
    tiledlayout(2, 2, 'Padding','compact', 'TileSpacing','compact');

    % 1. Contour of time-dependent 2D PES
    nexttile;
    F = sliding_free_energy(UA, UB, Eloop(i), p);
    contourf(UA, UB, F, 20, 'LineColor', 'none'); colormap(sky); hold on;
    % Overlay path up to now
    plot(uaLoop(1:i), ubLoop(1:i), 'r-', 'LineWidth', 2);
    scatter(uaLoop(i), ubLoop(i), 80, 'y', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.2);
    xlabel('u_a'); ylabel('u_b');
    title(sprintf('PES Contour, E_z = %.2f', Eloop(i)));
    grid on; box on;

    % 2. Easy axis path
    nexttile;
    plot(Eloop(1:i), uaLoop(1:i), 'LineWidth', 2); hold on;
    scatter(Eloop(i), uaLoop(i), 60, 'filled');
    xlabel('E_z'); ylabel('u_a');
    title('Easy axis u_a path');
    xlim([-1.3 1.3]); ylim([-1.5 1.5]); grid on; box on;

    % 3. Polarization path
    nexttile;
    plot(Eloop(1:i), PLoop(1:i), 'LineWidth', 2, 'Color', [0.1 0.6 0.2]); hold on;
    scatter(Eloop(i), PLoop(i), 60, 'filled', 'MarkerFaceColor', [0.1 0.6 0.2]);
    xlabel('E_z'); ylabel('P_z');
    title('Polarization switching');
    xlim([-1.3 1.3]); ylim([-1.5 1.5]); grid on; box on;

    % 4. Instantaneous readouts
    nexttile;
    currentObs = bilayer_response_observables(uaLoop(i), ubLoop(i), Eloop(i), p);
    bar([currentObs.shgIntensity, currentObs.ramanAnisotropy, ...
        1e3*abs(currentObs.lowerExcitonEnergy - p.exciton.E0), currentObs.photocurrent]);
    set(gca, 'XTickLabel', {'SHG','Raman','PL meV','J_{ph}'});
    ylabel('Response proxy');
    title('Instantaneous readouts');
    grid on; box on;

    drawnow;
    
    % Headless-safe frame capture.  Unique temporary files plus retry avoid
    % transient OneDrive/Windows PNG read races after print().
    tmpFile = fullfile(outDir, sprintf('temp_frame_%03d.png', jj));
    if exist(tmpFile, 'file')
        delete(tmpFile);
    end
    print(fig, tmpFile, '-dpng', '-r150');
    img = read_png_with_retry(tmpFile, 5);
    [A, map] = rgb2ind(img, 256);
    if jj == 1
        imwrite(A, map, gifFile, 'gif', 'LoopCount', inf, 'DelayTime', 0.08);
    else
        imwrite(A, map, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.08);
    end
end

% Cleanup temporary frame files
for f = dir(fullfile(outDir, 'temp_frame_*.png'))'
    delete(fullfile(f.folder, f.name));
end

disp('Bilayer dynamic modulation figures saved in output/.');

%% ===== Local helpers =====

function [uaPath, ubPath, PPath] = track_sliding_branch(Efield, p, ua0, ub0)
uaPath = zeros(size(Efield));
ubPath = zeros(size(Efield));
PPath  = zeros(size(Efield));
ua = ua0;
ub = ub0;
eta = p.landau.relaxRate;
for i = 1:numel(Efield)
    E = Efield(i);
    for k = 1:p.landau.nRelax
        [dF_dua, dF_dub] = sliding_gradient(ua, ub, E, p);
        ua = ua - eta*dF_dua;
        ub = ub - eta*dF_dub;
        ua = max(min(ua, 2.0), -2.0);
        ub = max(min(ub, 2.0), -2.0);
    end
    uaPath(i) = ua;
    ubPath(i) = ub;
    PPath(i)  = sliding_polarization(ua, ub, p);
end
end

function arrow(startPt, endPt)
annotation('arrow', [startPt(1), endPt(1)], [startPt(2), endPt(2)], ...
    'LineWidth', 1.3, 'HeadLength', 8, 'HeadWidth', 8);
end

function img = read_png_with_retry(path, maxAttempts)
lastErr = [];
for attempt = 1:maxAttempts
    try
        img = imread(path);
        return;
    catch err
        lastErr = err;
        pause(0.15 * attempt);
    end
end
rethrow(lastErr);
end
