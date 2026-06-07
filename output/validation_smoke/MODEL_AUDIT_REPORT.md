# ReS2 Sliding Model Audit Report

Claim level: semi-quantitative unless a parameter is explicitly calibrated.

## Validation checks

- PASS: registry_state_count (metric = 4). At least four labeled registry states are exposed.
- PASS: registry_barrier_positive (metric = 0.0295). Straight-path barriers are positive.
- PASS: finite_sliding_path (metric = 1.216). Gradient descent returns finite states.
- PASS: polarization_switches (metric = 2.297). Field sweep changes Pz appreciably.
- PASS: kxy_limiting_case (metric = 0.1068). kxy=0 limiting case remains bounded.
- PASS: high_temperature_small_signal (metric = 0.08015). Paraelectric high-T local model has small low-field Pz.

## Registry states

- Pminus_AA_like: ua=-1.000, ub=0.140, Pz=-0.915, F0=-0.059
- Pplus_AB_like: ua=1.000, ub=-0.140, Pz=0.915, F0=-0.067
- Pminus_shear: ua=-0.420, ub=0.480, Pz=-0.244, F0=0.354
- Pplus_shear: ua=0.420, ub=-0.480, Pz=0.244, F0=0.383

## Claim boundary

This model should be cited as a registry-resolved phenomenological framework. Quantitative claims require replacing the default amplitudes and couplings with DFT or experimental fits.
