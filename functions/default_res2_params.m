function p = default_res2_params()
%DEFAULT_RES2_PARAMS Parameters for the bilayer 1T'-ReS2 sliding model.
%
% The defaults are semi-quantitative literature-guided values.  They are
% intended to preserve the original demo while exposing explicit calibration
% hooks for registry, SHG, Raman, PL, transport, doping, and provenance.

p.model.name = 'Bilayer 1T''-ReS2 registry-resolved sliding-ferroelectric model';
p.model.version = '2.0.0';
p.model.claimLevel = 'semi-quantitative; requires experiment/DFT calibration';
p.model.literatureCutoff = '2026-06-04';
p.material = default_res2_material_constants();

%% Crystal convention
p.crystal.material = '1T''-ReS2';
p.crystal.layerGroup = 'P-1 monolayer reference, bilayer stacking breaks inversion';
p.crystal.easyAxisModel = 'u_a';
p.crystal.easyAxisPhysical = 'ReS2 b-axis / anisotropy-confined sliding direction';
p.crystal.hardAxisModel = 'u_b';
p.crystal.hardAxisPhysical = 'in-plane direction transverse to the sliding channel';
p.crystal.coordinateUnit = 'fractional registry coordinate; one period is approx. one low-energy slip repeat';

%% 1. Local Landau potential
p.landau.ax0        = -3.00;
p.landau.Tc         = 405;       % K, PRL 2022 bilayer estimate from SHG
p.landau.T          = 300;       % K
p.landau.ax         = p.landau.ax0 * (1 - p.landau.T / p.landau.Tc);
p.landau.bx         =  1.10;
p.landau.cx         =  0.12;
p.landau.ky         =  2.50;
p.landau.kxy        =  0.35;
p.landau.p1a        =  0.85;
p.landau.p1b        =  0.25;
p.landau.p3a        =  0.10;
p.landau.relaxRate  =  0.030;
p.landau.nRelax     =  1800;
p.landau.useRegistryPotential = true;
p.landau.registryWeight = 0.22;

%% 2. Periodic registry potential U_reg(ua, ub)
% Harmonics are dimensionless reciprocal vectors in the model coordinates.
% They make U_stack periodic and allow more than two discrete registry states.
p.registry.harmonicsG = [
     1,  0;
     0,  1;
     1,  1;
     2, -1
    ];
p.registry.amplitude = [0.32, 0.18, 0.11, 0.07];
p.registry.phaseRad  = [0.00, 0.35*pi, -0.20*pi, 0.50*pi];
p.registry.dopingBarrierScale = true;
p.registry.stateLabels = {'Pminus_AA_like','Pplus_AB_like','Pminus_shear','Pplus_shear'};
p.registry.stateUa = [-1.00, 1.00, -0.42, 0.42];
p.registry.stateUb = [ 0.14,-0.14,  0.48,-0.48];
p.registry.stateDescription = {
    'negative-polar low-energy registry';
    'positive-polar translated registry';
    'negative-polar hard-axis sheared registry';
    'positive-polar hard-axis sheared registry'
    };

%% 3. Doping and vacancy control of the switching barrier
p.doping.enabled = true;
p.doping.carrierDensity_cm2 = 0.0;
p.doping.sulfurVacancyFraction = 0.0;
p.doping.referenceVacancyFraction = 0.01;
p.doping.barrierScalePerReference = 0.35;
p.doping.coerciveField0_kVcm = 330;
p.doping.coerciveFieldPerReference_kVcm = 870;

%% 3b. Unit conversion from dimensionless model coordinates
p.units.u_a_period_A = p.material.lattice_b_A;
p.units.u_b_period_A = p.material.lattice_a_A;
p.units.E_norm_to_kVcm = p.doping.coerciveField0_kVcm;
p.units.P_norm_to_uCcm2 = p.material.default_polarization_uC_cm2;

%% 4. Raman modes
p.raman.useExcitonResonance = true;
p.raman.excitationEnergy_eV = 1.96;
p.raman.resonanceStrength = 0.08;
p.raman.resonanceGamma_eV = 0.08;

p.ramanModes(1).label = 'Ag-like 151 cm-1';
p.ramanModes(1).R0 = [1.00, 0.22; 0.22, 0.45];
p.ramanModes(1).R1a = [0.12, 0.06; 0.06,-0.04];
p.ramanModes(1).R1b = [0.03, 0.02; 0.02, 0.01];
p.ramanModes(1).R2a = [0.05,-0.03;-0.03, 0.02];
p.ramanModes(1).R2b = [0.01, 0.00; 0.00, 0.01];
p.ramanModes(1).bg = 0.03;
p.ramanModes(1).omega0 = 151.2;
p.ramanModes(1).domega_a1 = 0.8;
p.ramanModes(1).domega_a2 = 0.3;
p.ramanModes(1).domega_b1 = 0.25;
p.ramanModes(1).domega_b2 = 0.10;

p.ramanModes(2).label = 'Ag-like 212 cm-1';
p.ramanModes(2).R0 = [0.48,-0.34;-0.34, 0.98];
p.ramanModes(2).R1a = [-0.07, 0.10; 0.10, 0.13];
p.ramanModes(2).R1b = [ 0.02,-0.01;-0.01,-0.03];
p.ramanModes(2).R2a = [ 0.03, 0.04; 0.04,-0.02];
p.ramanModes(2).R2b = [ 0.01, 0.01; 0.01, 0.00];
p.ramanModes(2).bg = 0.025;
p.ramanModes(2).omega0 = 211.8;
p.ramanModes(2).domega_a1 = -0.5;
p.ramanModes(2).domega_a2 = 0.4;
p.ramanModes(2).domega_b1 = -0.15;
p.ramanModes(2).domega_b2 = 0.12;

p.ramanModes(3).label = 'Ag-like 234 cm-1';
p.ramanModes(3).R0 = [0.70, 0.15; 0.15, 0.78];
p.ramanModes(3).R1a = [0.03,-0.14;-0.14,-0.02];
p.ramanModes(3).R1b = [-0.01, 0.04; 0.04, 0.01];
p.ramanModes(3).R2a = [0.02, 0.02; 0.02, 0.03];
p.ramanModes(3).R2b = [0.00, 0.01; 0.01, 0.00];
p.ramanModes(3).bg = 0.02;
p.ramanModes(3).omega0 = 234.1;
p.ramanModes(3).domega_a1 = 0.3;
p.ramanModes(3).domega_a2 = -0.2;
p.ramanModes(3).domega_b1 = 0.10;
p.ramanModes(3).domega_b2 = -0.05;

%% 5. Ultralow-frequency Raman shear and breathing modes
p.ulfModes(1).label = 'shear-low';
p.ulfModes(1).omega0 = 13.0;
p.ulfModes(1).domega_a = 1.2;
p.ulfModes(1).domega_b = 2.4;
p.ulfModes(1).domega_ab = 0.8;
p.ulfModes(1).intensity0 = 1.0;
p.ulfModes(1).anisotropy = 0.55;

p.ulfModes(2).label = 'shear-high';
p.ulfModes(2).omega0 = 20.0;
p.ulfModes(2).domega_a = -0.8;
p.ulfModes(2).domega_b = 1.6;
p.ulfModes(2).domega_ab = -0.5;
p.ulfModes(2).intensity0 = 0.75;
p.ulfModes(2).anisotropy = -0.40;

p.ulfModes(3).label = 'breathing';
p.ulfModes(3).omega0 = 38.0;
p.ulfModes(3).domega_a = 0.25;
p.ulfModes(3).domega_b = 0.45;
p.ulfModes(3).domega_ab = 0.0;
p.ulfModes(3).intensity0 = 0.55;
p.ulfModes(3).anisotropy = 0.10;

%% 6. Exciton Hamiltonian and PL
p.exciton.E0 = 1.545;
p.exciton.E0_a1 = -0.006;
p.exciton.E0_a2 = 0.003;
p.exciton.E0_b1 = -0.002;
p.exciton.E0_b2 = 0.001;
p.exciton.bandEdge_a1 = 0.0025;
p.exciton.bandEdge_b1 = -0.0015;
p.exciton.screeningCoeff = 0.05;
p.exciton.temperatureK = 78;

p.exciton.Delta0 = 0.030;
p.exciton.Delta_a1 = 0.010;
p.exciton.Delta_a2 = -0.004;
p.exciton.Delta_b1 = 0.003;
p.exciton.Delta_b2 = -0.001;

p.exciton.K0 = 0.004;
p.exciton.K_a1 = 0.006;
p.exciton.K_a2 = 0.001;
p.exciton.K_b1 = 0.002;
p.exciton.K_b2 = 0.0005;

p.exciton.mu = [1.00, 0.72];
p.exciton.basisAngleDeg = [0, 90];
p.exciton.peakLabels = {'X1_low_energy','X2_high_energy'};
p.exciton.peakDOLP0 = [0.93, 0.90];
p.exciton.peakDOLP_ub = [0.03, 0.04];
p.exciton.gamma0 = [0.010, 0.013];
p.exciton.gamma_u = [0.001, -0.001];
p.exciton.gamma_T_coeff = [1.0e-5, 1.4e-5];
p.exciton.bg = 0.015;

%% 7. Tensor SHG
p.shg.chi_bg = 0.12;
p.shg.chi_a1 = 0.95;
p.shg.chi_a2 = 0.18;
p.shg.chi_b1 = 0.28;
p.shg.chi_b2 = 0.05;
p.shg.tensor_bg = makeTensor2([0.12, 0.02, 0.02, -0.04], 0.00);
p.shg.tensor_a1 = makeTensor2([0.95, 0.28, 0.28, -0.36], 0.06);
p.shg.tensor_b1 = makeTensor2([0.20, -0.18, -0.18, 0.44], -0.04);
p.shg.tensor_a2 = makeTensor2([0.18, 0.05, 0.05, 0.08], 0.02);
p.shg.tensor_b2 = makeTensor2([0.05, 0.02, 0.02, 0.03], 0.01);
p.shg.defaultPumpDeg = 0;
p.shg.defaultAnalyzerDeg = 0;

%% 8. Transport and photovoltaic proxies
p.transport.J0 = 1.0;
p.transport.eta_P = 0.45;
p.transport.eta_E = 0.08;
p.transport.lambda_P = 0.035;
p.transport.lambda_E = 0.010;
p.transport.schottky0_eV = 0.42;
p.transport.temperatureK = 300;
p.transport.darkCurrentScale = 1.0;
p.transport.bandGap_eV = 1.47;
p.transport.bandOffset0_eV = 0.12;
p.transport.bandOffset_P = 0.055;
p.transport.shiftCurrent0 = 0.020;
p.transport.shiftCurrent_P = 0.035;
p.transport.typeVThreshold_eV = 0.16;

%% 9. Literature/provenance records used by the model.
p.provenance = default_provenance();

end

function T = makeTensor2(v, phase)
%MAKETENSOR2 Create a 2x2x2 effective in-plane SHG tensor.
% v = [xxx, xyy, yxx, yyy].  Symmetry in the two input fields is enforced.
T = complex(zeros(2, 2, 2));
z = exp(1i * phase);
T(1,1,1) = v(1) * z;
T(1,2,2) = v(2) * z;
T(2,1,1) = v(3) * z;
T(2,2,2) = v(4) * z;
T(1,1,2) = 0.5 * (v(2) + v(3)) * z;
T(1,2,1) = T(1,1,2);
T(2,1,2) = 0.5 * (v(2) - v(3)) * z;
T(2,2,1) = T(2,1,2);
end

function prov = default_provenance()
prov(1) = provenance_row('Tc', 405, 'K', ...
    'Wan et al., Phys. Rev. Lett. 128, 067601 (2022)', ...
    'literature anchor', 'medium');
prov(2) = provenance_row('ULF shear mode separation', 13, 'cm^-1 scale', ...
    'He et al., arXiv:1512.00092 / Nano Lett. stacking Raman study', ...
    'qualitative calibration', 'medium');
prov(3) = provenance_row('PL stacking shift', 5, 'meV scale', ...
    'Fu et al., Nano Lett. 2026 optical imaging of interlayer sliding', ...
    'qualitative calibration', 'medium');
prov(4) = provenance_row('doping coercive-field enhancement', 870, 'kV/cm', ...
    'Liu et al., Phys. Rev. B 111, 104110 (2025)', ...
    'literature anchor', 'medium');
prov(5) = provenance_row('multistate bilayer registry', 4, 'states', ...
    'Ge et al., Phys. Rev. Applied 25, 044016 (2026)', ...
    'qualitative calibration', 'low');
end

function row = provenance_row(name, value, unit, source, fitStatus, confidence)
row.name = name;
row.value = value;
row.unit = unit;
row.source = source;
row.fit_status = fitStatus;
row.confidence = confidence;
end
