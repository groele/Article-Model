# ReS2 Sliding Model Audit Report

Claim level: semi-quantitative unless a parameter is explicitly calibrated.

## Validation checks

- PASS: registry_state_count (metric = 4). At least four labeled registry states are exposed.
- PASS: registry_barrier_positive (metric = 0.0295). Straight-path barriers are positive.
- PASS: finite_sliding_path (metric = 1.216). Gradient descent returns finite states.
- PASS: polarization_switches (metric = 2.297). Field sweep changes Pz appreciably.
- PASS: kxy_limiting_case (metric = 0.1068). kxy=0 limiting case remains bounded.
- PASS: high_temperature_small_signal (metric = 0.08015). Paraelectric high-T local model has small low-field Pz.
- PASS: analytic_gradient_check (metric = 6.958e-10). Analytic gradient agrees with finite-difference free-energy gradient.
- PASS: registry_periodicity (metric = 1.11e-15). Registry potential is invariant under integer model-coordinate translations.
- PASS: registry_minima_found (metric = 3). Grid scan finds multiple local registry minima.
- PASS: two_pl_peaks_resolved (metric = 15.74). PL readout keeps X1 and X2 as two resolved peaks.
- PASS: two_pl_axes_distinct (metric = 88.35). X1 and X2 retain distinct linear-polarization axes.
- PASS: material_lattice_area_positive (metric = 36.5). ReS2 triclinic in-plane unit-cell area is positive and physical.
- PASS: physical_polarization_scale (metric = 0.1098). Default physical Pz scale remains in a cautious sliding-ferroelectric range.

## Registry states

- Pminus_AA_like: ua=-1.000, ub=0.140, Pz=-0.915, F0=-0.059
- Pplus_AB_like: ua=1.000, ub=-0.140, Pz=0.915, F0=-0.067
- Pminus_shear: ua=-0.420, ub=0.480, Pz=-0.244, F0=0.354
- Pplus_shear: ua=0.420, ub=-0.480, Pz=0.244, F0=0.383

## Grid-detected minima

- minimum 1: ua=0.930, ub=-0.080, Pz=0.851, F0=-0.088
- minimum 2: ua=-0.960, ub=0.060, Pz=-0.889, F0=-0.069
- minimum 3: ua=-0.030, ub=0.000, Pz=-0.026, F0=0.040

## Physical scale for labeled registry states

- Pminus_AA_like: |u|=6.474 A, Pz=-0.1098 uC/cm^2, sheet charge=-6.853e+11 cm^-2, charge transfer=-2.501e-03 e/cell
- Pplus_AB_like: |u|=6.474 A, Pz=0.1098 uC/cm^2, sheet charge=6.853e+11 cm^-2, charge transfer=2.501e-03 e/cell
- Pminus_shear: |u|=4.125 A, Pz=-0.0293 uC/cm^2, sheet charge=-1.831e+11 cm^-2, charge transfer=-6.681e-04 e/cell
- Pplus_shear: |u|=4.125 A, Pz=0.0293 uC/cm^2, sheet charge=1.831e+11 cm^-2, charge transfer=6.681e-04 e/cell

## Material constants used for scaling

- lattice_a = 6.51 A
- lattice_b = 6.41 A
- lattice_gamma = 119 deg
- unit_cell_area = 36.5 A^2
- monolayer_thickness = 6.2 A
- bilayer_spacing = 6.2 A
- direct_bandgap = 1.55 eV
- bandgap_min = 1.5 eV
- bandgap_max = 1.6 eV
- exciton_binding_X1 = 118 meV
- exciton_binding_X2 = 83 meV
- exciton_bohr_radius = 1.5 nm

## Claim boundary

This model should be cited as a registry-resolved phenomenological framework. Quantitative claims require replacing the default amplitudes and couplings with DFT or experimental fits.
