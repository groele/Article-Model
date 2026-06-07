# Theory Notes for the Registry-Resolved ReS2 Sliding Model

## 1. Coordinates and Symmetry Convention

The sliding coordinate is a two-component in-plane registry vector

```text
u = [u_a, u_b].
```

`u_a` is the model easy axis and is mapped to the experimentally discussed
anisotropy-confined ReS2 sliding direction.  `u_b` is the hard-axis shear
coordinate.  This convention is explicit because a physically useful model must
state how its mathematical axes relate to crystallographic axes.

The model is phenomenological.  Its symmetry content is:

- inversion breaking is controlled by interlayer registry;
- `P_z` changes sign between opposite polar stackings;
- low-symmetry in-plane anisotropy permits mixed `u_a u_b` terms;
- periodic registry terms represent the lattice rather than an unbounded
  polynomial displacement.

## 2. ReS2 Material Parameters and Physical Scaling

ReS2 is not treated as a generic anisotropic 2D semiconductor.  The parameter
layer stores material-specific anchors:

```text
a ~= 6.51 A
b ~= 6.41 A
gamma ~= 119 deg
direct gap ~= 1.5-1.6 eV
X1/X2 binding energies ~= 118/83 meV
AA/AB ULF shear reference ~= 13/20 cm^-1
```

The low symmetry comes from distorted Re-Re chains.  This produces two related
effects that the model keeps separate:

1. **structural anisotropy**: the sliding path is easier along the chain-like
   direction than transverse to it;
2. **optical anisotropy**: X1 and X2 excitons have distinct linearly polarized
   transition dipoles.

The dimensionless coordinates are converted to physical scales by

```text
u_a,A = u_a * b
u_b,A = u_b * a
E_z,kV/cm = E_norm * E_c0
P_z,uC/cm2 = P_z,norm * P_scale.
```

The physical polarization scale is deliberately conservative.  It is used to
estimate a sheet-charge proxy and charge transfer per in-plane unit cell:

```text
sigma = P_z / e
Delta q_cell = sigma * A_cell.
```

These conversions make the outputs interpretable while preserving the warning
that default parameters are not fitted constants.

## 3. Hybrid Free Energy

The free energy is

```text
F(u_a,u_b,E_z,T) = U_local(u_a,u_b,T) + w U_reg(u_a,u_b) - E_z P_z(u_a,u_b).
```

The local Landau part is

```text
U_local =
  ax(T)/2 u_a^2 + bx/4 u_a^4 + cx/6 u_a^6
  + ky/2 u_b^2 + kxy u_a u_b.
```

The polarization proxy is

```text
P_z = p1a u_a + p1b u_b + p3a u_a^3.
```

The registry potential is a Fourier series:

```text
U_reg = sum_n A_n [1 - cos(2 pi (G_na u_a + G_nb u_b) + phi_n)].
```

This term is the key upgrade.  It allows discrete registry states, barriers,
and periodic stacking landscapes.  The current Fourier coefficients are
literature-guided defaults and should be replaced by DFT or fitted SHG/Raman
data for quantitative work.

## 4. Switching and Doping

Switching is computed by overdamped gradient descent:

```text
du_a/dt = -dF/du_a
du_b/dt = -dF/du_b.
```

Sulfur vacancies and carrier doping are represented as barrier and coercive
field modifiers:

```text
E_c = E_c0 + alpha_v (vacancy_fraction / vacancy_reference)
      + alpha_n |n| / 1e13 cm^-2.
```

This follows the physical lesson from doping-dependent coercive-field
enhancement in ReS2 sliding ferroelectrics: sliding barriers can increase with
charge doping, unlike the simplest displacement-type ferroelectric expectation.

## 5. Raman

High-frequency Raman modes use a real low-symmetry tensor

```text
R_m = R0 + u_a R1a + u_b R1b + u_a^2 R2a + u_b^2 R2b.
```

The parallel/cross intensity is

```text
I_m(theta) = |e_s(theta)^T R_m e_i(theta)|^2 + background.
```

An exciton-resonance multiplier is included because ReS2 Raman intensity can be
strongly enhanced near anisotropic exciton resonances.

Ultralow-frequency Raman modes are added as stacking-sensitive shear and
breathing proxies:

```text
omega_ULF = omega0 + a u_a + b u_b + c u_a u_b.
```

These are especially important because ULF shear modes directly test interlayer
coupling and stacking order.

## 6. Exciton and PL

The anisotropic exciton model remains a two-state Hamiltonian:

```text
H_X = E0(u) I + [ Delta(u)/2, K(u); K(u), -Delta(u)/2 ].
```

The upgrade adds:

- stacking-dependent band-edge shift;
- screening reduction of `Delta` and `K`;
- Boltzmann population factors;
- temperature-dependent linewidth.

Transition dipoles are obtained by projecting basis dipoles through the
Hamiltonian eigenvectors.  The two eigenstates are reported as two PL peaks:

```text
X1 = lower-energy exciton peak
X2 = higher-energy exciton peak
```

Each peak has its own energy, linewidth, oscillator strength, thermal
population, polarization axis, DOLP, and Stokes coordinates.  The model should
not interpret ReS2 PL as one merged DOLP channel.  The old aggregate field
`obs.dolp` is retained only as a compatibility alias for `obs.X1DOLP`.

## 7. SHG

SHG is now tensorial:

```text
P_i(2w) = sum_jk chi_ijk^(2)(u) E_j(w) E_k(w).
```

The detected amplitude is

```text
chi_eff = e_out dot P(2w).
```

The code returns complex amplitude, intensity, phase, and the full effective
2D tensor.  This is required for angular SHG fingerprints and phase-sensitive
registry readout.

## 8. Transport and Photovoltaic Proxies

The transport layer computes:

- Schottky barrier shift;
- thermionic current proxy;
- band-offset proxy;
- type-V alignment weight;
- shift-current proxy;
- combined photocurrent.

These are not device simulations.  They expose how a single registry coordinate
can drive multiple correlated electrical and optical channels.

## 9. Validation Logic

`validate_model_physics` checks:

- registry state count;
- positive pairwise barriers;
- finite gradient-descent paths;
- polarization switching;
- `kxy = 0` limiting behavior;
- high-temperature paraelectric local limit;
- analytic gradient consistency;
- registry periodicity;
- grid-detected minima;
- X1/X2 PL peak resolution and axis separation;
- physical scale sanity checks;
- parameter provenance.

The generated audit report marks the model as semi-quantitative unless real
calibration data replace the default coefficients.
