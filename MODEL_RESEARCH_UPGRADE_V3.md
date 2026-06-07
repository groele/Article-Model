# Research-guided V3 upgrade for the bilayer 1T'-ReS2 sliding-ferroelectric model

This note upgrades the current model from a useful semi-quantitative demonstration into a more falsifiable, calibration-ready theoretical framework. The central principle is unchanged: the interlayer registry vector `u = (u_a, u_b)` is the hidden structural order parameter, and SHG, Raman, ultralow-frequency Raman, PL, transport, and photovoltaic observables are different readouts of the same registry state.

The recommended V3 model should not claim material-constant-level prediction until the stacking-energy surface, polarization, optical tensors, and transport coefficients are replaced by DFT or experimentally fitted values.

---

## 1. Current model diagnosis

The repository already has a strong architecture:

- A 2D sliding coordinate rather than a single scalar polarization.
- A hybrid free energy combining a local Landau term and a lattice-periodic registry potential.
- Registry-state catalog and barrier extraction.
- Peak-resolved PL for X1 and X2 instead of a merged DOLP channel.
- Tensorial SHG, high-frequency Raman, ULF Raman, and transport/PV proxies.
- Validation/audit outputs to separate qualitative mechanism from quantitative prediction.

The main limitation is not conceptual, but calibration hierarchy. Some parameters are physically motivated but not yet tagged as one of the following:

1. literature-anchored constants;
2. experiment-fitted observables;
3. DFT/NEB-derived quantities;
4. qualitative proxy parameters only.

V3 should make this hierarchy explicit and enforce it in code and writing.

---

## 2. Literature-grounded physical constraints

### 2.1 Bilayer stacking ferroelectricity symmetry constraint

General bilayer stacking ferroelectricity theory shows that a bilayer can become ferroelectric through stacking translation/rotation even when the monolayer is centrosymmetric. Therefore, the V3 model should not treat `P_z` as an independent scalar order parameter. `P_z` must be a symmetry-filtered function of interlayer registry:

```text
P_z = P_z(u_a, u_b)
```

Recommended upgrade:

```text
P_z(u) = sum_i p_i f_i(u)
```

where each basis function `f_i(u)` must be tagged by parity under the operation connecting opposite polar states. Terms that do not change sign between opposite polar states should not be included in the ferroelectric polarization channel.

Primary anchor:

- Ji, Xu, and Xiang, General Theory for Bilayer Stacking Ferroelectricity, Phys. Rev. Lett. 130, 146801 (2023); arXiv:2210.16542.

### 2.2 Periodic registry potential and DFT replacement

The current Fourier registry potential is the right structural form because registry is periodic. However, the amplitudes and phases should be treated as placeholders unless fitted to DFT or experimental inversion.

Recommended V3 free-energy hierarchy:

```text
F(u,E,T,n,c_v) = U_DFT_or_Fourier(u,n,c_v) + U_local(u,T) - E_z P_z(u,n,c_v)
```

with three modes:

- `demo`: current default Fourier coefficients;
- `fit`: Fourier coefficients fitted to SHG/Raman/ULF data;
- `DFT`: Fourier coefficients fitted to a DFT stacking-energy grid and NEB barriers.

For paper claims, only `fit` and `DFT` modes should be used for quantitative statements.

### 2.3 ULF Raman as the strongest experimental registry constraint

Ultralow-frequency Raman is more direct for registry than high-frequency Raman or PL because it probes interlayer shear and breathing modes. Literature reports that bilayer/few-layer ReS2 has rich Raman modes below 50 cm^-1 and two non-degenerate shear modes, which directly reflect in-plane lattice distortion and stacking order.

Recommended upgrade:

```text
Loss_total = w_SHG Loss_SHG + w_ULF Loss_ULF + w_HF_Raman Loss_HF_Raman + w_PL Loss_PL
```

with `w_ULF` assigned the highest default structural weight when ULF Raman data are available.

Primary anchors:

- He et al., Coupling and stacking order of ReS2 atomic layers revealed by ultralow-frequency Raman spectroscopy, Nano Lett. 16, 1404 (2016); arXiv:1512.00092.
- Qiao et al., Polytypism and Unexpected Strong Interlayer Coupling of two-Dimensional Layered ReS2, Nanoscale 9, 8324-8332 (2016); arXiv:1512.08935.

### 2.4 Peak-resolved anisotropic exciton model should remain mandatory

Recent ReS2 exciton studies support a robust anisotropic-exciton picture. The current two-peak X1/X2 PL treatment is therefore a strength and should not be collapsed into one empirical DOLP.

Recommended upgrade:

- Keep `X1` and `X2` as independent emissive branches.
- Add a confidence penalty if the two peaks overlap strongly relative to linewidth.
- Add a fitting mode that extracts `E_X1`, `E_X2`, `Gamma_X1`, `Gamma_X2`, `theta_X1`, `theta_X2`, `DOLP_X1`, and `DOLP_X2` from experimental PL maps.
- Add a warning if only integrated PL is supplied, because integrated PL cannot uniquely resolve the two excitonic axes.

Primary anchors:

- Chowdhury et al., Robust coherent dynamics of homogeneously limited anisotropic excitons in two-dimensional layered ReS2, arXiv:2411.13695.
- Das et al., Giant Resonance Raman Scattering via Anisotropic Excitons in ReS2, arXiv:2507.15327.

### 2.5 Resonant Raman coupling should be energy-resolved

The current model includes an exciton-resonance multiplier for Raman. V3 should make this energy-resolved rather than a single scalar correction:

```text
M_res(m, E_laser, u) = 1 + sum_j C_mj |e_Raman · d_j(u)|^2 / [(E_laser - E_j(u))^2 + gamma_j^2]
```

This allows different Raman modes to couple differently to X1 and X2.

### 2.6 Transport/PV proxy must be split into symmetry-allowed channels

Sliding ferroelectrics can show photovoltaic responses that are not all switched by polarization reversal; theory distinguishes switchable out-of-plane BPVE and potentially unswitchable in-plane BPVE components depending on symmetry.

Recommended upgrade:

```text
J_z^shift = eta_z P_z(u) I_light
J_x^shift = eta_x_even g_even(u) I_light + eta_x_odd g_odd(u) I_light
```

The model should report whether a simulated current is odd, even, or mixed under polarization reversal. This prevents overclaiming that every photocurrent component is ferroelectrically switchable.

Primary anchor:

- Xiao et al., Switchable and unswitchable bulk photovoltaic effect in two-dimensional interlayer-sliding ferroelectrics, npj Computational Materials 8, 138 (2022); arXiv:2201.04980.

### 2.7 ReS2 stacking also affects non-optical channels

Recent work on stacking-engineered thermal transport in ReS2 reinforces the broader physical point that registry is a real structural control knob, not merely an optical fitting parameter. This does not need to be added as a core output, but it can be used as a cross-disciplinary motivation for registry-resolved modeling.

Primary anchor:

- Zhou et al., Stacking-Engineered Thermal Transport and Phonon Filtering in Rhenium Disulfide, arXiv:2602.15002.

---

## 3. Recommended V3 model architecture

### Layer A: registry and symmetry

Inputs:

```text
u = (u_a, u_b)
crystal convention
opposite-polar-state operation
allowed basis functions
```

Outputs:

```text
P_z(u)
parity labels for every observable
registry-state catalog
symmetry report
```

New requirement: every observable should carry a parity tag under polarization reversal:

```text
odd / even / mixed / unknown
```

### Layer B: free energy and switching

Recommended model:

```text
F = U_reg(u) + U_local(u,T) - E_z P_z(u) + U_defect(u,c_v,n)
```

Upgrade points:

- Add `energyMode = demo | fit | DFT`.
- Add NEB-compatible input/output for switching barriers.
- Add rate-dependent switching using a Kramers-like escape probability for sweep-rate dependence:

```text
Gamma_switch(E,T) = f0 exp[-DeltaF(E)/(k_B T)]
```

Use this only as a kinetic proxy unless attempt frequencies and barriers are calibrated.

### Layer C: optical readouts

Required outputs:

```text
SHG tensor fingerprint
HF Raman tensor fingerprint
ULF Raman frequencies and intensities
X1/X2 PL energy, linewidth, oscillator strength, axis, DOLP, Stokes coordinates
```

Upgrade points:

- Give ULF Raman the highest registry-identification weight.
- Make Raman resonance mode-dependent and exciton-branch-dependent.
- Penalize PL interpretations when X1/X2 peak separation is smaller than the linewidth criterion.

### Layer D: electrical and photovoltaic readouts

Required outputs:

```text
Schottky/barrier proxy
band-offset proxy
shift-current odd/even decomposition
photocurrent confidence level
```

Upgrade point:

Do not report a single scalar photocurrent as a direct ferroelectric readout unless its odd/even symmetry under `P_z -> -P_z` has been evaluated.

### Layer E: inverse problem and identifiability

Recommended joint loss:

```text
Loss_total(u) =
  w_SHG Loss_SHG(u)
+ w_ULF Loss_ULF(u)
+ w_Raman Loss_Raman(u)
+ w_PL Loss_PL(u)
+ w_IV Loss_IV(u)
```

Recommended identifiability outputs:

- best-fit `u`;
- confidence basin area;
- parameter correlation matrix;
- channel consistency score;
- leave-one-channel-out registry stability;
- warning if Raman-only and PL-only minima disagree.

---

## 4. Calibration manifest required for quantitative use

Create or maintain a CSV manifest with these fields:

```text
parameter_group, parameter_name, current_value, unit, source_type, source, calibration_status, confidence, recommended_action
```

Confidence rules:

- `high`: directly fitted from the same device or from DFT/NEB generated for the same stacking geometry.
- `medium`: literature value from comparable ReS2 thickness/stacking/temperature.
- `low`: physically motivated placeholder.
- `proxy`: qualitative parameter only; not valid for quantitative prediction.

---

## 5. New validation checks for V3

Add these checks to `validate_model_physics` or a separate `validate_model_v3` function:

1. `symmetry_parity_check`: `P_z(+u)` and `P_z(-u)` have opposite signs under the defined polar-state operation.
2. `registry_periodicity_check_2D`: `U_reg(u + integer lattice vector) = U_reg(u)`.
3. `ULF_registry_sensitivity`: at least one ULF mode changes measurably between registry states.
4. `X1_X2_resolvability`: `|E_X2 - E_X1| > max(Gamma_X1, Gamma_X2)` for peak-resolved PL claims.
5. `photocurrent_parity_check`: current channels are tagged as odd/even/mixed under polarization reversal.
6. `joint_fit_consistency`: Raman-only, PL-only, and SHG/ULF-only registry estimates agree within a defined tolerance.
7. `parameter_provenance_complete`: every nontrivial parameter has a source type and confidence label.
8. `claim_level_gate`: quantitative claims are blocked if key parameters remain low-confidence placeholders.

---

## 6. Paper-ready claim boundaries

### Strong and defensible

```text
We construct a registry-resolved phenomenological framework in which the interlayer sliding vector acts as a common structural coordinate linking ferroelectric polarization, tensorial SHG, Raman/ULF Raman fingerprints, anisotropic X1/X2 excitonic emission, and transport/PV proxies.
```

```text
The model is designed to test whether multiple optical and electrical observables can be consistently interpreted as readouts of the same sliding-registry coordinate.
```

### Only after calibration

```text
The model quantitatively predicts coercive fields, switching barriers, and photovoltaic currents.
```

This requires DFT/NEB or same-device experimental calibration.

### Avoid

```text
The default model proves the microscopic switching path.
```

The default model proposes a physically constrained and falsifiable path; it does not prove the atomic pathway without DFT/NEB or direct structural imaging.

---

## 7. Immediate implementation checklist

1. Add `apply_research_guided_v3_constraints.m` to tag parameters and observables by confidence and parity.
2. Add `literature_constraints_v3.csv` as a calibration manifest.
3. Extend `validate_model_physics` with V3 checks listed above.
4. Add `energyMode = demo | fit | DFT` to parameter structures.
5. Add a PL resolvability warning based on X1/X2 separation and linewidth.
6. Add odd/even/mixed photocurrent parity decomposition.
7. Add leave-one-channel-out fitting stability for hidden registry inversion.

---

## 8. Recommended final model positioning

The best positioning is:

```text
registry-resolved, symmetry-constrained, calibration-ready phenomenological model
```

This is stronger than calling it a toy model, but more rigorous than overclaiming a predictive first-principles theory. It is exactly the right level for a manuscript section that wants to provide mechanism-level physical insight while staying honest about which parameters remain to be calibrated.
