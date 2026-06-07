# Bilayer 1T'-ReS2 Sliding-Ferroelectric Model

This MATLAB package implements a registry-resolved phenomenological model for
bilayer 1T'-ReS2 sliding ferroelectricity and its coupled optical/electrical
readouts.

The model is no longer a purely polynomial toy model.  It now combines:

- local Landau sliding free energy for intuition;
- periodic registry energy from Fourier harmonics;
- labeled multistate registry catalog;
- tensorial SHG response;
- high-frequency and ultralow-frequency Raman channels;
- two-peak anisotropic exciton/PL model for X1 and X2 with separate
  polarization axes, DOLP values, thermal populations, and screening terms;
- Schottky, band-offset, shift-current, and photocurrent proxies;
- sulfur-vacancy/doping control of switching barrier and coercive field;
- ReS2 material constants and unit conversion from model coordinates to
  Angstrom, kV/cm, uC/cm^2, sheet charge, and charge transfer per unit cell;
- validation and audit outputs that separate qualitative and quantitative
  claims.

## Claim Boundary

The default parameters are semi-quantitative and literature-guided.  They are
not a substitute for DFT, SHG image calibration, Raman fitting, PL fitting, or
PFM coercive-field measurements.

Use the model as:

- a mechanism-resolved simulation framework;
- a guide for which observables should co-vary with the same sliding coordinate;
- a fitting scaffold once real data are placed in `data/`.

Do not use the default numbers as predictive material constants.

## Main Literature Anchors

- Wan et al., *Phys. Rev. Lett.* 128, 067601 (2022): room-temperature
  ferroelectricity in 1T'-ReS2 multilayers.
- Fu et al., *Nano Letters* (2026): SHG imaging of discrete interlayer sliding
  in 1T'-ReS2.
- Liu et al., *Phys. Rev. B* 111, 104110 (2025): sulfur-vacancy/doping
  enhancement of coercive field in sliding-ferroelectric ReS2.
- Ge et al., *Phys. Rev. Applied* 25, 044016 (2026): bilayer 1T'-ReS2
  multistate ferroelectricity and photovoltaic response.
- Ji et al., *Phys. Rev. Lett.* 130, 146801 (2023): general bilayer stacking
  ferroelectricity theory.
- He et al., ultralow-frequency Raman study of ReS2 stacking order.
- Zhou et al., *Advanced Materials* 32, 1908311 (2020): stacking-driven optical
  properties and carrier dynamics in ReS2.
- Das et al., *ACS Photonics* 12, 4731 (2025): resonant Raman enhancement via
  anisotropic excitons in ReS2.

See `data/literature_constraints.csv` for the calibration manifest.

For a paper-ready theory narrative with formula derivations, use
`PAPER_THEORY_MODEL_DERIVATION.md`.

## Running

In MATLAB:

```matlab
main_run_all_ReS2_sliding_model
```

This runs:

- `main_demo_ReS2_sliding_theory.m`
- `main_bilayer_ReS2_dynamic_modulation.m`
- `scripts/make_deep_mechanism_figure.py`
- `validate_model_physics(...)`

Outputs are written under `output/`.

For a faster non-figure check:

```matlab
run_model_smoke_tests
```

## Important Outputs

- `output/registry_state_catalog.csv`
- `output/registry_barriers.csv`
- `output/validation/registry_minima_grid.csv`
- `output/validation/material_parameter_table.csv`
- `output/parameter_provenance.csv`
- `output/joint_sliding_coordinate_fit.csv`
- `output/joint_sliding_coordinate_identifiability.csv`
- `output/Fig14_ULF_Raman_vs_sliding.png`
- `output/Fig15_tensor_SHG_angular_fingerprints.png`
- `output/validation/MODEL_AUDIT_REPORT.md`

## Model Layers

1. Sliding coordinate:
   `u_a` is the model easy axis, mapped to the reported ReS2
   anisotropy-confined sliding direction, especially b-axis sliding in SHG/Raman
   imaging.  `u_b` is the transverse hard-axis coordinate.

2. Free energy:
   `F = U_local + w U_registry - E_z P_z`.
   `U_registry` is periodic, so discrete stackings and barriers can be exposed.
   Dimensionless registry coordinates are scaled by ReS2 lattice constants:
   `u_a` maps to the b-axis-like sliding period and `u_b` maps to the
   transverse period.

3. Optical readouts:
   Raman and PL remain low-dimensional, but now include ULF modes, exciton
   resonance, thermal linewidths, tensor SHG angular fingerprints, and
   peak-resolved ReS2 PL polarization.  `obs.dolp` is retained only as a
   compatibility alias for X1 DOLP; use `obs.X1DOLP` and `obs.X2DOLP` for
   physical interpretation.

4. Electrical/PV readouts:
   Photocurrent is a proxy combining polarization, field, Schottky barrier,
   band-offset, and shift-current contributions.

5. Validation:
   `validate_model_physics` writes a structured audit.  Failed checks mean the
   model should not be interpreted physically until the issue is fixed.
