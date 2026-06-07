function report = validate_model_v4(p, outDir)
%VALIDATE_MODEL_V4 Deep validation for the research-guided ReS2 model.
%
% This validation layer checks whether the V4 model obeys symmetry,
% resolvability, parity decomposition, and claim-boundary constraints.  It is
% intentionally conservative and is meant to support manuscript-level theory
% writing without overclaiming quantitative predictive power.

if nargin < 1 || isempty(p)
    p = default_res2_params();
end
if exist('apply_research_guided_v3_constraints', 'file') == 2
    p = apply_research_guided_v3_constraints(p);
end
if nargin < 2 || isempty(outDir)
    outDir = fullfile(pwd, 'output', 'validation_v4');
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

states = registry_state_catalog(p);
ua = states.ua(:);
ub = states.ub(:);
E = zeros(size(ua));

pz4 = sliding_polarization_v4(ua, ub, p);
basis = symmetry_adapted_registry_basis(ua, ub, p);
tr4 = transport_pv_response_v4(ua, ub, E, p);

% Opposite-polar partner check using default or user-defined operation.
uaP = basis.partner_ua;
ubP = basis.partner_ub;
pz4P = sliding_polarization_v4(uaP, ubP, p);
pzParityErr = local_relative_error(pz4P.Pz, -pz4.Pz);

% ULF sensitivity check across cataloged states.
ulf = zeros(numel(ua), numel(p.ulfModes));
for i = 1:numel(ua)
    u = ulf_raman_modes(ua(i), ub(i), p);
    ulf(i,:) = u.frequency_cm1;
end
ulfRelativeSpan = max(max(ulf, [], 1) - min(ulf, [], 1)) ./ max(abs(ulf(:)));

% PL peak resolvability check.
sepOverLine = zeros(numel(ua), 1);
for i = 1:numel(ua)
    peak = exciton_peak_observables(ua(i), ub(i), p);
    sep = abs(diff(peak.energy_eV));
    if isfield(peak, 'gamma_eV')
        line = max(peak.gamma_eV);
    elseif isfield(p, 'exciton') && isfield(p.exciton, 'gamma0')
        line = max(p.exciton.gamma0);
    else
        line = 0.010;
    end
    sepOverLine(i) = sep ./ max(line, eps);
end

% Photocurrent parity check by decomposition rather than total-current sign.
oddNorm = local_norm_channel(tr4.J_dark_odd + tr4.J_shift_out_odd);
evenNorm = local_norm_channel(tr4.J_dark_even + tr4.J_shift_in_even);
mixedNorm = local_norm_channel(tr4.J_shift_in_mixed);

% Claim-level gate.
lowConfidence = true;
if isfield(p, 'model') && isfield(p.model, 'energyMode')
    lowConfidence = strcmpi(p.model.energyMode, 'demo');
end
quantAllowed = ~lowConfidence;
if isfield(p, 'model') && isfield(p.model, 'quantitativeClaimAllowed')
    quantAllowed = logical(p.model.quantitativeClaimAllowed) && ~lowConfidence;
end

checks = {
    'Pz_odd_under_polar_partner', pzParityErr, pzParityErr < 0.25, ...
        'V4 Pz should approximately reverse under the operation connecting opposite polar states.';
    'odd_basis_available', sum(basis.poly.parity == "odd") + sum(basis.fourier.parity == "odd"), ...
        (sum(basis.poly.parity == "odd") + sum(basis.fourier.parity == "odd")) >= 2, ...
        'At least two odd basis functions are available for ferroelectric response.';
    'ULF_registry_sensitivity', ulfRelativeSpan, ulfRelativeSpan > 0.02, ...
        'ULF Raman modes must respond measurably to registry to support structural inversion.';
    'X1_X2_PL_resolvability', min(sepOverLine), min(sepOverLine) > 1.0, ...
        'Peak-resolved PL claims require X1/X2 separation larger than linewidth.';
    'photocurrent_parity_decomposed', oddNorm + evenNorm + mixedNorm, ...
        all(isfield(tr4, {'J_dark_even','J_dark_odd','J_shift_out_odd','J_shift_in_even','J_shift_in_mixed'})), ...
        'PV/transport response is split into even, odd, and mixed channels.';
    'quantitative_claim_gate', double(quantAllowed), ~quantAllowed, ...
        'Default demo mode should block quantitative material-constant-level claims.';
    };

Tchecks = cell2table(checks, 'VariableNames', ...
    {'check_name','metric','passed','interpretation'});

Tpolar = table(ua, ub, pz4.Pz, pz4.P_landau, pz4.P_berry_like, ...
    pz4.P_charge_transfer, repmat(pz4.renormalization, numel(ua), 1), ...
    'VariableNames', {'ua','ub','Pz_total','P_landau','P_berry_like', ...
    'P_charge_transfer','renormalization'});

Tpv = table(ua, ub, tr4.J_dark_even, tr4.J_dark_odd, tr4.J_shift_out_odd, ...
    tr4.J_shift_in_even, tr4.J_shift_in_mixed, tr4.photocurrent, ...
    'VariableNames', {'ua','ub','J_dark_even','J_dark_odd','J_shift_out_odd', ...
    'J_shift_in_even','J_shift_in_mixed','J_total'});

writetable(Tchecks, fullfile(outDir, 'v4_validation_checks.csv'));
writetable(Tpolar, fullfile(outDir, 'v4_polarization_decomposition.csv'));
writetable(Tpv, fullfile(outDir, 'v4_photocurrent_parity_decomposition.csv'));

report = struct();
report.checks = Tchecks;
report.polarization = Tpolar;
report.photocurrent = Tpv;
report.basis = basis;
report.allPassed = all(Tchecks.passed);
report.claimBoundary = 'V4 increases theoretical depth but remains phenomenological until DFT/experiment calibration replaces demo coefficients.';

write_v4_audit(report, fullfile(outDir, 'MODEL_V4_AUDIT_REPORT.md'));
end

function write_v4_audit(report, path)
fid = fopen(path, 'w');
if fid < 0
    warning('Could not write V4 audit report: %s', path);
    return;
end
cleanup = onCleanup(@() fclose(fid));

fprintf(fid, '# ReS2 Sliding Model V4 Audit Report\n\n');
fprintf(fid, '## Claim boundary\n\n%s\n\n', report.claimBoundary);
fprintf(fid, '## V4 validation checks\n\n');
for i = 1:height(report.checks)
    status = 'FAIL';
    if report.checks.passed(i); status = 'PASS'; end
    fprintf(fid, '- %s: %s (metric = %.4g). %s\n', status, ...
        report.checks.check_name{i}, report.checks.metric(i), ...
        report.checks.interpretation{i});
end
fprintf(fid, '\n## Polarization decomposition\n\n');
for i = 1:height(report.polarization)
    fprintf(fid, ['- state %d: ua=%.3f, ub=%.3f, Pz=%.4f ', ...
        '(Landau=%.4f, Berry-like=%.4f, charge-transfer=%.4f)\n'], ...
        i, report.polarization.ua(i), report.polarization.ub(i), ...
        report.polarization.Pz_total(i), report.polarization.P_landau(i), ...
        report.polarization.P_berry_like(i), report.polarization.P_charge_transfer(i));
end
fprintf(fid, '\n## Photocurrent parity decomposition\n\n');
for i = 1:height(report.photocurrent)
    fprintf(fid, ['- state %d: J_total=%.4f, J_odd=%.4f, ', ...
        'J_even=%.4f, J_mixed=%.4f\n'], i, report.photocurrent.J_total(i), ...
        report.photocurrent.J_dark_odd(i)+report.photocurrent.J_shift_out_odd(i), ...
        report.photocurrent.J_dark_even(i)+report.photocurrent.J_shift_in_even(i), ...
        report.photocurrent.J_shift_in_mixed(i));
end
end

function err = local_relative_error(a, b)
err = norm(a(:) - b(:)) ./ max([norm(a(:)), norm(b(:)), eps]);
end

function n = local_norm_channel(x)
n = norm(x(:));
end
