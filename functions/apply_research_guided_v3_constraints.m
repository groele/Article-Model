function p = apply_research_guided_v3_constraints(p)
%APPLY_RESEARCH_GUIDED_V3_CONSTRAINTS Add V3 metadata and claim gates.
%
% This helper does not change the numerical defaults.  It annotates the
% existing ReS2 sliding model with research-guided metadata required for a
% calibration-ready manuscript workflow: claim level, parity tags,
% provenance status, and validation thresholds.
%
% Usage:
%   p = default_res2_params();
%   p = apply_research_guided_v3_constraints(p);
%
% The annotations are intentionally conservative.  Quantitative claims are
% only allowed when the corresponding parameters are fitted to same-device
% experimental data or DFT/NEB calculations.

if nargin < 1 || isempty(p)
    p = default_res2_params();
end

%% Model-level claim gates
p.model.version = '3.0.0-research-guided';
p.model.framework = 'registry-resolved, symmetry-constrained, calibration-ready phenomenological model';
p.model.energyMode = 'demo';  % demo | fit | DFT
p.model.quantitativeClaimAllowed = false;
p.model.quantitativeClaimGate = [ ...
    'Quantitative prediction requires calibrated registry energy, ', ...
    'Pz(u), optical tensors, and transport/PV coefficients.'];
p.model.recommendedManuscriptClaim = [ ...
    'The model tests whether SHG, Raman/ULF Raman, PL, and electrical ', ...
    'responses can be consistently interpreted as readouts of one ', ...
    'interlayer sliding-registry coordinate.'];

%% Symmetry/parity metadata
p.symmetry.polarStateOperation = 'u_a -> -u_a and u_b -> -u_b unless replaced by crystallographic operation';
p.symmetry.requiresUserDefinedOperation = true;
p.symmetry.observableParity.Pz = 'odd';
p.symmetry.observableParity.SHG_polar_contrast = 'mixed';
p.symmetry.observableParity.HF_Raman_frequency = 'mixed';
p.symmetry.observableParity.ULF_Raman_frequency = 'mixed';
p.symmetry.observableParity.PL_energy = 'mixed';
p.symmetry.observableParity.PL_axis = 'mixed';
p.symmetry.observableParity.transport_dark_current = 'mixed';
p.symmetry.observableParity.photocurrent_out_of_plane = 'odd_candidate';
p.symmetry.observableParity.photocurrent_in_plane = 'even_or_mixed_candidate';

%% Calibration confidence labels
p.calibration.registryEnergy.status = 'placeholder';
p.calibration.registryEnergy.confidence = 'low';
p.calibration.registryEnergy.action = 'Fit Fourier coefficients to DFT stacking-energy grid or SHG/ULF inversion.';

p.calibration.switchingBarrier.status = 'proxy';
p.calibration.switchingBarrier.confidence = 'low';
p.calibration.switchingBarrier.action = 'Replace straight-path barrier by NEB-calibrated barrier.';

p.calibration.Pz.status = 'phenomenological';
p.calibration.Pz.confidence = 'medium-low';
p.calibration.Pz.action = 'Fit Pz(u) using Berry-phase DFT or calibrated SHG/ferroelectric data.';

p.calibration.ULFRaman.status = 'literature-guided';
p.calibration.ULFRaman.confidence = 'medium';
p.calibration.ULFRaman.action = 'Use sample-specific ULF Raman frequencies as the strongest registry constraint.';

p.calibration.HFRaman.status = 'phenomenological tensor';
p.calibration.HFRaman.confidence = 'low';
p.calibration.HFRaman.action = 'Fit mode-specific Raman tensors from polarization-resolved Raman maps.';

p.calibration.PL.status = 'phenomenological two-peak exciton Hamiltonian';
p.calibration.PL.confidence = 'medium';
p.calibration.PL.action = 'Fit X1/X2 energy, linewidth, axis, DOLP, and oscillator strength from PL maps.';

p.calibration.SHG.status = 'effective tensor';
p.calibration.SHG.confidence = 'low';
p.calibration.SHG.action = 'Fit SHG tensor or replace by first-principles nonlinear susceptibility.';

p.calibration.transport.status = 'proxy';
p.calibration.transport.confidence = 'proxy';
p.calibration.transport.action = 'Decompose photocurrent into odd/even/mixed symmetry channels before assigning switchability.';

%% V3 validation thresholds
p.validationV3.minRegistryStates = 4;
p.validationV3.minPzSwitchingRange = 0.2;
p.validationV3.maxHighTLowFieldPz = 0.5;
p.validationV3.maxGradientError = 1e-4;
p.validationV3.maxPeriodicityError = 1e-10;
p.validationV3.minULFRelativeChange = 0.02;
p.validationV3.minExcitonSeparationOverLinewidth = 1.0;
p.validationV3.requireCompleteProvenance = true;
p.validationV3.blockQuantitativeClaimsForLowConfidence = true;

%% Recommended inverse-problem weights
p.inverseWeights.SHG = 1.0;
p.inverseWeights.ULF_Raman = 2.0;
p.inverseWeights.HF_Raman = 0.8;
p.inverseWeights.PL_energy = 0.8;
p.inverseWeights.PL_axis = 0.8;
p.inverseWeights.transport = 0.3;
p.inverseWeights.note = 'ULF Raman and SHG should dominate registry inversion when available; PL mainly constrains excitonic readout.';

end
