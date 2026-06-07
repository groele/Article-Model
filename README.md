# Article-Model: Bilayer 1T'-ReS2 Sliding-Ferroelectric Theory Framework

`Article-Model` is a MATLAB-based theoretical and diagnostic framework for bilayer 1T'-ReS2 sliding ferroelectricity.  The model treats the interlayer registry vector

```text
u = (u_a, u_b)
```

as the hidden structural order parameter connecting ferroelectric polarization, SHG, Raman/ultralow-frequency Raman, anisotropic excitonic PL, electrical transport, and photovoltaic response channels.

The current version has evolved from a simple demonstration into a **symmetry-configurable, DFT-calibratable, kinetics-aware, exciton-phonon-coupled, multi-channel invertible registry framework**.

---

## 1. What this repository does

The repository can be used to:

1. simulate a 2D sliding-registry free-energy landscape;
2. map registry states to out-of-plane polarization proxies;
3. simulate high-frequency Raman and ultralow-frequency Raman fingerprints;
4. simulate tensorial SHG angular fingerprints;
5. simulate two-branch anisotropic PL from X1/X2 excitons;
6. decompose transport and photovoltaic response into even, odd, and mixed parity channels;
7. import DFT registry-grid and NEB switching-path data;
8. compare scalar-polarization, 1D-sliding, and 2D-registry model hierarchies;
9. invert hidden registry coordinates from multi-channel optical/electrical targets;
10. run V4/V5/V6 validation and audit workflows;
11. generate manuscript-style theoretical figures.

---

## 2. Claim boundary

This repository is intentionally conservative about physical claims.

### Safe claim

The default model is a registry-resolved, symmetry-constrained phenomenological framework for testing whether multiple optical and electrical responses can be interpreted as readouts of the same hidden interlayer sliding coordinate.

### Conditional claim

The model can become semi-quantitative or quasi-quantitative after replacing default parameters with:

- DFT stacking-energy surface `U_reg(u_a,u_b)`;
- Berry-phase polarization `P_z(u_a,u_b)`;
- NEB switching barriers;
- experimental SHG/Raman/ULF Raman/PL fitting;
- sweep-rate-dependent hysteresis data;
- excitation-energy-dependent resonant Raman data.

### Unsafe claim without calibration

Do **not** use the default parameters as predictive material constants for coercive field, switching barrier, absolute polarization, Raman intensity, photocurrent magnitude, or exciton energy shifts.

---

## 3. Repository structure

```text
Article-Model/
├── main_run_all_ReS2_sliding_model.m        # Original one-entry launcher
├── main_demo_ReS2_sliding_theory.m          # Main 2D sliding/Raman/PL/SHG demo
├── main_bilayer_ReS2_dynamic_modulation.m   # Dynamic modulation demo
├── run_model_smoke_tests.m                  # Lightweight original smoke tests
├── functions/                               # Core model functions
├── scripts/                                 # Audit and figure-generation workflows
├── data/                                    # Calibration templates and manifests
├── output/                                  # Generated outputs
├── README.md                                # This file
├── MODEL_RESEARCH_UPGRADE_V3.md             # V3 upgrade rationale
├── THEORETICAL_FRAMEWORK_V4.md              # V4 theoretical framework
└── PAPER_THEORY_MODEL_DERIVATION.md         # Paper-style derivation, if present
```

---

## 4. Requirements

- MATLAB R2019b or newer is recommended.
- No special MATLAB toolbox is required for the core scripts.
- Python is optional and only needed for selected figure scripts such as `scripts/make_deep_mechanism_figure.py`.

Recommended workflow:

```matlab
cd Article-Model
addpath(genpath('functions'))
```

---

## 5. Quick start

### 5.1 Run the original full model

```matlab
main_run_all_ReS2_sliding_model
```

This runs:

- `main_demo_ReS2_sliding_theory.m`
- `main_bilayer_ReS2_dynamic_modulation.m`
- `scripts/make_deep_mechanism_figure.py`, if Python is available
- `validate_model_physics(...)`

Main outputs are written to:

```text
output/
output/validation/
```

### 5.2 Run lightweight smoke tests

```matlab
run_model_smoke_tests
```

This checks the original physics validation, registry periodicity, gradient consistency, SHG scan, and X1/X2 PL peak structure.

### 5.3 Run V5 audit

```matlab
run('scripts/run_v5_model_audit.m')
```

This checks:

- polar-state operation consistency;
- DFT registry-grid fitting;
- NEB barrier import;
- scalar-P versus 2D-registry ablation;
- joint registry inversion;
- leave-one-channel-out stability.

Outputs:

```text
output/v5_audit/
```

### 5.4 Run V6 audit

```matlab
run('scripts/run_v6_model_audit.m')
```

This adds:

- resonant Raman V6 profile;
- Kramers-like rate-dependent switching;
- parameter sensitivity analysis;
- manuscript-style theory figure generation.

Outputs:

```text
output/v6_audit/
output/figures_v6/
```

### 5.5 Run code health checks

```matlab
run('scripts/run_code_health_checks.m')
```

This performs lightweight runtime checks across major V1-V6 modules and writes:

```text
output/code_health/code_health_checks.csv
```

---

## 6. Model evolution: V1 to V6

### V1: Sliding-coordinate Raman/PL demo

Core idea:

```text
u_a, u_b -> Raman / PL observables
```

The early model demonstrated that sliding coordinates can modulate Raman polar plots and excitonic PL response.

### V2: Registry-resolved bilayer response

Added:

- periodic registry energy;
- multistate registry catalog;
- barrier extraction;
- SHG response;
- ULF Raman modes;
- transport/PV proxies;
- material constants and physical-unit conversion.

### V3: Research-guided claim gates

Added:

- explicit claim boundary;
- calibration confidence labels;
- literature constraint manifest;
- conservative validation thresholds;
- inverse-problem channel weights.

Important file:

```text
functions/apply_research_guided_v3_constraints.m
```

### V4: Symmetry-adapted registry theory

Added:

- symmetry-adapted basis functions;
- odd/even/mixed parity classification;
- polarization decomposition into Landau, Berry-like, and charge-transfer channels;
- parity-resolved transport/PV response;
- V4 validation/audit.

Important files:

```text
functions/symmetry_adapted_registry_basis.m
functions/sliding_polarization_v4.m
functions/transport_pv_response_v4.m
functions/validate_model_v4.m
THEORETICAL_FRAMEWORK_V4.md
```

### V5: DFT-calibratable and invertible registry model

Added:

- configurable polar-state operation `u_partner = M*u + t`;
- DFT registry-grid loader;
- Fourier fitting from DFT energy grids;
- Berry-phase polarization fitting;
- NEB barrier path import;
- scalar-P versus 1D sliding versus 2D registry ablation;
- grid-based joint registry inversion;
- leave-one-channel-out stability test.

Important files:

```text
functions/default_res2_symmetry_config.m
functions/identify_polar_partner_registry.m
functions/check_polar_state_operation.m
functions/load_dft_registry_grid.m
functions/fit_registry_fourier_from_dft.m
functions/fit_polarization_from_berry_dft.m
functions/import_neb_barrier_path.m
functions/compare_model_hierarchy.m
functions/run_ablation_scalarP_vs_registry2D.m
functions/joint_registry_inversion_grid.m
functions/leave_one_channel_out_test.m
scripts/run_v5_model_audit.m
```

### V6: Kinetics-aware and exciton-phonon-coupled framework

Added:

- branch-resolved resonant Raman model;
- registry-dependent exciton-phonon coupling proxy;
- Kramers-like switching-rate model;
- sweep-rate-dependent hysteresis simulation;
- local parameter sensitivity analysis;
- manuscript-style theory figure generation;
- code health checks.

Important files:

```text
functions/exciton_phonon_coupling_tensor.m
functions/resonant_raman_matrix_element_v6.m
functions/switching_rate_kramers_model.m
functions/simulate_rate_dependent_hysteresis.m
functions/parameter_sensitivity_analysis.m
scripts/make_manuscript_theory_figures_v6.m
scripts/run_v6_model_audit.m
scripts/run_code_health_checks.m
```

---

## 7. Physical model layers

### 7.1 Registry coordinate

The hidden structural coordinate is:

```text
u = (u_a, u_b)
```

where:

- `u_a` is the easy-axis sliding coordinate;
- `u_b` is the transverse/hard-axis sliding coordinate.

In the default parameter file, these dimensionless coordinates are mapped to approximate ReS2 lattice periods through:

```matlab
p.units.u_a_period_A
p.units.u_b_period_A
```

### 7.2 Free energy

The recommended V4/V5/V6 free-energy hierarchy is:

```text
F(u,E_z,T,n,c_v)
  = U_reg(u,n,c_v)
  + U_local(u,T)
  - E_z P_z(u,n,c_v)
  + U_defect(u,n,c_v)
```

In the default demo model:

```text
F = U_local + w U_registry - E_z P_z
```

where `U_registry` is a Fourier-like periodic registry surface.

### 7.3 Polarization

The original model uses:

```text
P_z = p1a u_a + p1b u_b + p3a u_a^3
```

The V4/V6 model extends this to:

```text
P_z(u) = P_Landau(u) + P_Berry-like(u) + P_charge-transfer(u)
```

This is implemented in:

```text
functions/sliding_polarization_v4.m
```

Interpretation:

- `P_Landau`: local odd sliding-channel component;
- `P_Berry-like`: registry-periodic Berry-phase-like contribution;
- `P_charge-transfer`: interlayer charge-transfer proxy.

Only calibrated Berry-phase DFT or electrostatic data can make this quantitatively predictive.

### 7.4 Symmetry and parity

V5 uses an explicit polar-state operation:

```text
u_partner = M*u + t
```

Default:

```matlab
sym.M = -eye(2);
sym.t = [0;0];
```

This default is a placeholder.  For quantitative ReS2-specific claims, replace it with the actual transformation connecting the relaxed positive and negative polar stacking registries.

Parity classes:

```text
odd   -> may represent switchable ferroelectric-like response
even  -> stacking-sensitive but not switchable by polarization reversal
mixed -> cannot be assigned without further symmetry/calibration analysis
```

### 7.5 Raman and ULF Raman

High-frequency Raman is treated through registry-dependent Raman tensors.

ULF Raman is treated as a stronger registry fingerprint because interlayer shear and breathing modes are directly sensitive to stacking order.

### 7.6 Resonant Raman and exciton-phonon coupling

V6 adds branch-resolved resonant Raman:

```text
M_m(E_L,u) = sum_j C_mj |e_in · d_j(u)|^2 |e_out · d_j(u)|^2 /
             [(E_L - E_j(u))^2 + Gamma_j^2]
```

where `j = X1, X2`.

Implemented in:

```text
functions/exciton_phonon_coupling_tensor.m
functions/resonant_raman_matrix_element_v6.m
```

### 7.7 Excitonic PL

The model keeps X1 and X2 as separate branches:

```text
X1: E1, Gamma1, oscillator1, theta1, DOLP1
X2: E2, Gamma2, oscillator2, theta2, DOLP2
```

Peak-resolved interpretation requires:

```text
|E_X2 - E_X1| > max(Gamma_X1, Gamma_X2)
```

If this is not satisfied, interpret only integrated PL.

### 7.8 Transport and photovoltaic response

V4/V6 decomposes current into parity channels:

```text
J_total
  = J_dark_even
  + J_dark_odd
  + J_shift_out_odd
  + J_shift_in_even
  + J_shift_in_mixed
```

Only odd candidate terms can be discussed as switchable by ferroelectric reversal, and only after calibration.

### 7.9 Switching kinetics

V6 adds a Kramers-like switching proxy:

```text
Gamma(E,T) = f0 exp[-DeltaF(E)/(kBT)]
```

Implemented in:

```text
functions/switching_rate_kramers_model.m
functions/simulate_rate_dependent_hysteresis.m
```

This is a kinetic proxy unless NEB barriers and attempt frequencies are calibrated.

---

## 8. Calibration data formats

### 8.1 DFT registry-grid template

File:

```text
data/dft_registry_grid_template.csv
```

Required columns:

```text
ua, ub, energy_meV_per_cell
```

Optional columns:

```text
Pz_uC_cm2, charge_transfer_e, band_gap_eV, band_offset_eV
```

Example:

```csv
ua,ub,energy_meV_per_cell,Pz_uC_cm2,charge_transfer_e,band_gap_eV,band_offset_eV
-1.0,0.14,0.0,-0.20,-0.002,1.47,-0.05
1.0,-0.14,0.0,0.20,0.002,1.47,0.05
```

Functions:

```matlab
dft = load_dft_registry_grid('data/dft_registry_grid_template.csv');
energyFit = fit_registry_fourier_from_dft(dft, p);
polarFit = fit_polarization_from_berry_dft(dft, p);
```

### 8.2 NEB switching-path template

File:

```text
data/neb_barrier_path_template.csv
```

Required columns:

```text
image_id, ua, ub, energy_meV_per_cell
```

Optional columns:

```text
reaction_coordinate, Pz_uC_cm2
```

Example:

```csv
image_id,ua,ub,energy_meV_per_cell,reaction_coordinate,Pz_uC_cm2
1,-1.0,0.14,0.0,0.00,-0.20
4,0.00,0.00,48.0,0.50,0.00
7,1.0,-0.14,0.0,1.00,0.20
```

Function:

```matlab
neb = import_neb_barrier_path('data/neb_barrier_path_template.csv');
```

---

## 9. Important outputs

### Original model outputs

```text
output/registry_state_catalog.csv
output/registry_barriers.csv
output/parameter_provenance.csv
output/fitted_Raman_tensor_summary.csv
output/fitted_PL_Stokes_summary.csv
output/joint_sliding_coordinate_fit.csv
output/joint_sliding_coordinate_identifiability.csv
output/validation/MODEL_AUDIT_REPORT.md
```

### V4 outputs

```text
output/validation_v4/v4_validation_checks.csv
output/validation_v4/v4_polarization_decomposition.csv
output/validation_v4/v4_photocurrent_parity_decomposition.csv
output/validation_v4/MODEL_V4_AUDIT_REPORT.md
```

### V5 outputs

```text
output/v5_audit/polar_state_operation_check.csv
output/v5_audit/dft_registry_energy_fourier_fit.csv
output/v5_audit/berry_polarization_fit.csv
output/v5_audit/neb_barrier_path.csv
output/v5_audit/ablation/ablation_scalarP_vs_registry2D.csv
output/v5_audit/joint_registry_inversion_best.csv
output/v5_audit/leave_one_channel_out_registry_inversion.csv
```

### V6 outputs

```text
output/v6_audit/resonant_raman_v6_profile.csv
output/v6_audit/rate_dependent_hysteresis_v6.csv
output/v6_audit/parameter_sensitivity_v6.csv
output/v6_audit/MODEL_V6_AUDIT_SUMMARY.md
output/figures_v6/FigT1_registry_energy_landscape.png
output/figures_v6/FigT2_polarization_decomposition.png
output/figures_v6/FigT3_resonant_raman_profile.png
output/figures_v6/FigT4_rate_dependent_hysteresis.png
output/figures_v6/FigT5_joint_inversion_confidence_basin.png
output/figures_v6/FigT6_parameter_sensitivity.png
```

---

## 10. Common workflows

### 10.1 Check polar-state operation

```matlab
p = default_res2_params();
p.symmetry.polarOperation = default_res2_symmetry_config();
check = check_polar_state_operation(p, fullfile(pwd,'output','validation_v5'));
```

### 10.2 Fit registry energy from DFT

```matlab
p = default_res2_params();
dft = load_dft_registry_grid('data/dft_registry_grid_template.csv');
fit = fit_registry_fourier_from_dft(dft, p);
```

### 10.3 Fit Berry-phase polarization

```matlab
p = default_res2_params();
dft = load_dft_registry_grid('data/dft_registry_grid_template.csv');
fitP = fit_polarization_from_berry_dft(dft, p);
```

### 10.4 Import NEB barrier

```matlab
neb = import_neb_barrier_path('data/neb_barrier_path_template.csv');
```

### 10.5 Compare scalar-P and 2D-registry models

```matlab
p = default_res2_params();
result = run_ablation_scalarP_vs_registry2D(p, fullfile(pwd,'output','ablation_v5'));
```

### 10.6 Invert hidden registry from target observables

```matlab
p = default_res2_params();
states = registry_state_catalog(p);
obs = bilayer_response_observables(states.ua(1), states.ub(1), 0, p);

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
```

### 10.7 Simulate resonant Raman profile

```matlab
p = default_res2_params();
states = registry_state_catalog(p);
E = linspace(1.42, 1.70, 240)';
rr = resonant_raman_matrix_element_v6(E, states.ua(1), states.ub(1), p, 1);
```

### 10.8 Simulate rate-dependent switching

```matlab
p = default_res2_params();
sweep.Emax = 1.2;
sweep.nPoints = 301;
sweep.sweepRate_norm_per_s = 0.02;
sweep.T_K = 300;
sim = simulate_rate_dependent_hysteresis(p, 50, sweep, struct());
```

### 10.9 Generate manuscript-style theory figures

```matlab
make_manuscript_theory_figures_v6
```

---

## 11. Code health and debugging

Run:

```matlab
run('scripts/run_code_health_checks.m')
```

This checks representative calls for:

- default parameter generation;
- registry catalog creation;
- polar partner operation;
- symmetry-adapted basis construction;
- V4 polarization and PV decomposition;
- V4 validation;
- V6 resonant Raman input-shape robustness;
- Kramers-like switching rate;
- rate-dependent hysteresis;
- parameter sensitivity analysis;
- DFT and NEB template loading;
- scalar-P versus 2D-registry ablation.

The script writes:

```text
output/code_health/code_health_checks.csv
```

If any check fails, inspect the `message` column.

---

## 12. Known limitations

1. The default polar-state operation `u -> -u` is a placeholder.  Replace it with the actual crystallographic operation for quantitative ReS2-specific claims.
2. The default Fourier registry potential is not a DFT energy surface.
3. `P_Berry-like` is not a Berry-phase calculation unless calibrated with DFT.
4. The charge-transfer term is a proxy, not a Bader-charge or charge-density-difference calculation.
5. Raman, SHG, PL, and PV coefficients are semi-quantitative until fitted.
6. Kramers-like switching kinetics require calibrated NEB barriers and attempt frequencies.
7. Exciton-phonon coupling and resonant Raman profiles require excitation-energy-dependent Raman calibration.
8. The generated manuscript figures are diagnostic by default; regenerate them after replacing template data with real data.

---

## 13. Recommended paper positioning

Recommended wording:

```text
We developed a symmetry-configurable, DFT-calibratable, and kinetics-aware registry framework in which the interlayer sliding vector serves as a hidden structural coordinate linking ferroelectric polarization, tensorial optical fingerprints, anisotropic excitonic emission, and parity-resolved transport/PV response channels.
```

Conservative wording:

```text
The present implementation provides a symmetry-constrained phenomenological framework.  Quantitative prediction of switching barriers, coercive fields, absolute polarization, Raman intensity, and photocurrent requires DFT/NEB or same-device experimental calibration.
```

Avoid:

```text
The default model quantitatively proves the microscopic switching path.
```

---

## 14. Suggested next steps

1. Replace `data/dft_registry_grid_template.csv` with converged DFT stacking-energy and Berry-phase polarization data.
2. Replace `data/neb_barrier_path_template.csv` with actual NEB results.
3. Fit SHG/Raman/ULF Raman/PL data from the same sample whenever possible.
4. Use `run_ablation_scalarP_vs_registry2D.m` to justify why the full 2D registry coordinate is necessary.
5. Use `joint_registry_inversion_grid.m` and `leave_one_channel_out_test.m` to test multi-channel consistency.
6. Use `parameter_sensitivity_analysis.m` to prioritize which parameters require DFT or experimental calibration.
7. Regenerate `output/figures_v6/` for manuscript-ready theory figures.

---

## 15. Citation and attribution note

This repository is a modeling scaffold.  When using it in a manuscript, cite the experimental and theoretical literature that anchors the specific physical claims, especially bilayer stacking ferroelectricity theory, ReS2 sliding ferroelectric experiments, ULF Raman studies, resonant Raman/exciton studies, and BPVE symmetry analysis.  The repository itself should be described as a calibration-ready phenomenological framework unless all key coefficients are replaced by calibrated values.
