%% RUN_CODE_HEALTH_CHECKS
% Static and lightweight runtime health checks for Article-Model.
%
% This script checks syntax availability, core function calls, input-shape
% robustness, and V4-V6 module coupling. It is intentionally lightweight and
% does not require real DFT data.

clear; clc;
rootDir = fileparts(fileparts(mfilename('fullpath')));
if isempty(rootDir); rootDir = pwd; end
addpath(genpath(fullfile(rootDir, 'functions')));
outDir = fullfile(rootDir, 'output', 'code_health');
if ~exist(outDir, 'dir'); mkdir(outDir); end

checks = {};
addCheck('default_res2_params', @() default_res2_params());

p = default_res2_params();
if exist('apply_research_guided_v3_constraints', 'file') == 2
    p = apply_research_guided_v3_constraints(p);
end
p.symmetry.polarOperation = default_res2_symmetry_config();

addCheck('registry_state_catalog', @() registry_state_catalog(p));
addCheck('polar_partner_operation', @() identify_polar_partner_registry([-1;1], [0.14;-0.14], p));
addCheck('symmetry_basis_Mu_plus_t', @() symmetry_adapted_registry_basis([-1;1], [0.14;-0.14], p));
addCheck('sliding_polarization_v4', @() sliding_polarization_v4([-1;1], [0.14;-0.14], p));
addCheck('transport_pv_response_v4', @() transport_pv_response_v4([-1;1], [0.14;-0.14], [0;0], p));
addCheck('validate_model_v4', @() validate_model_v4(p, fullfile(outDir, 'validation_v4')));
addCheck('resonant_raman_manyE_oneU', @() resonant_raman_matrix_element_v6(linspace(1.42,1.70,5)', -1, 0.14, p, 1));
addCheck('resonant_raman_oneE_manyU', @() resonant_raman_matrix_element_v6(1.55, [-1;1], [0.14;-0.14], p, 1));
addCheck('kramers_switching_rate', @() switching_rate_kramers_model(50, linspace(-1,1,5)', 300, struct()));
addCheck('rate_dependent_hysteresis', @() simulate_rate_dependent_hysteresis(p, 50, struct('Emax',1.2,'nPoints',41,'sweepRate_norm_per_s',0.02,'T_K',300), struct()));
addCheck('parameter_sensitivity', @() parameter_sensitivity_analysis(p));
addCheck('DFT_template_loader', @() load_dft_registry_grid(fullfile(rootDir, 'data', 'dft_registry_grid_template.csv')));
addCheck('NEB_template_loader', @() import_neb_barrier_path(fullfile(rootDir, 'data', 'neb_barrier_path_template.csv')));
addCheck('ablation_workflow', @() run_ablation_scalarP_vs_registry2D(p, fullfile(outDir, 'ablation')));

T = cell2table(checks, 'VariableNames', {'check_name','passed','message'});
writetable(T, fullfile(outDir, 'code_health_checks.csv'));

nFail = sum(~T.passed);
if nFail > 0
    disp(T(~T.passed,:));
    error('%d code health checks failed. See output/code_health/code_health_checks.csv', nFail);
else
    fprintf('All %d code health checks passed.\n', height(T));
end

function addCheck(name, fun)
    try
        fun();
        assignin('caller', 'checks', [evalin('caller','checks'); {name, true, 'OK'}]);
    catch ME
        assignin('caller', 'checks', [evalin('caller','checks'); {name, false, ME.message}]);
    end
end
