function result = joint_q_fit(obsRaman, obsPL, phiDeg, p)
%JOINT_Q_FIT  Estimates hidden 2D sliding coordinates [ua, ub] from Raman + PL.
%
%  Performs a 2D grid search to minimize the joint loss function:
%    L(ua, ub) = w_R · L_Raman(ua, ub)  +  w_PL · L_PL(ua, ub)
%
%  Inputs:
%    obsRaman — table with columns: mode_id, angle_deg, intensity
%    obsPL    — table with columns: energy_eV, phi_0, phi_10, ...
%    phiDeg   — [M×1] analyzer angles matching PL columns
%    p        — parameter struct
%
%  Output:
%    result — struct with fields:
%             .ua_best, .ub_best (optimal fitted coordinates)
%             .loss_best         (minimum loss)
%             .ua_grid, .ub_grid  (grid vectors)
%             .loss_map          (2D loss surface)

uaGrid = linspace(-1.4, 1.4, 81);
ubGrid = linspace(-0.6, 0.6, 41);
[UA, UB] = meshgrid(uaGrid, ubGrid);
lossMap = zeros(size(UA));
lossRamanMap = zeros(size(UA));
lossPLMap = zeros(size(UA));

% Parse observed PL map
energy = obsPL.energy_eV;
Ypl    = table2array(obsPL(:, 2:end));
Ypl    = Ypl ./ max(Ypl(:) + eps);

modes = unique(obsRaman.mode_id)';
N_modes = numel(modes);

% Pre-parse Raman observed intensities per mode to speed up loop
y_obs = cell(N_modes, 1);
angle_obs = cell(N_modes, 1);
for m_idx = 1:N_modes
    im = modes(m_idx);
    idx = obsRaman.mode_id == im;
    y = obsRaman.intensity(idx);
    y_obs{m_idx} = y ./ max(y + eps);
    angle_obs{m_idx} = obsRaman.angle_deg(idx);
end

for r = 1:size(UA, 1)
    for c = 1:size(UA, 2)
        ua = UA(r, c);
        ub = UB(r, c);

        % --- Raman loss ---
        lr = 0;
        for m_idx = 1:N_modes
            im = modes(m_idx);
            yh = raman_intensity_parallel(angle_obs{m_idx}, ua, ub, p, im);
            yh = yh ./ max(yh + eps);
            lr = lr + mean((y_obs{m_idx} - yh).^2);
        end
        lr = lr / N_modes;

        % --- PL loss ---
        Yh = pl_spectrum_model(energy, phiDeg, ua, ub, p);
        Yh = Yh ./ max(Yh(:) + eps);
        lp = mean((Ypl(:) - Yh(:)).^2);

        % --- Joint loss ---
        lossRamanMap(r, c) = lr;
        lossPLMap(r, c) = lp;
        lossMap(r, c) = 0.55*lr + 0.45*lp;
    end
end

[lossBest, idx] = min(lossMap(:));
[best_r, best_c] = ind2sub(size(lossMap), idx);

result.ua_best   = UA(best_r, best_c);
result.ub_best   = UB(best_r, best_c);
result.loss_best = lossBest;
result.ua_grid   = uaGrid;
result.ub_grid   = ubGrid;
result.loss_map  = lossMap;
result.loss_raman_map = lossRamanMap;
result.loss_pl_map = lossPLMap;

delta = max(2e-4, 0.10 * max(lossBest, eps));
mask = lossMap <= lossBest + delta;
result.confidence_delta = delta;
result.ua_ci = [min(UA(mask)), max(UA(mask))];
result.ub_ci = [min(UB(mask)), max(UB(mask))];

[~, idxR] = min(lossRamanMap(:));
[rR, cR] = ind2sub(size(lossRamanMap), idxR);
[~, idxP] = min(lossPLMap(:));
[rP, cP] = ind2sub(size(lossPLMap), idxP);
result.raman_only_ua = UA(rR, cR);
result.raman_only_ub = UB(rR, cR);
result.pl_only_ua = UA(rP, cP);
result.pl_only_ub = UB(rP, cP);

end
