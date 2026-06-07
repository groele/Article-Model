function m = default_res2_material_constants()
%DEFAULT_RES2_MATERIAL_CONSTANTS Literature-guided ReS2 material constants.
%
% Values are anchors for physical scaling, not final fitted constants.

m.material = '1T''-ReS2';
m.structure = 'distorted octahedral / triclinic';
m.lattice_a_A = 6.51;
m.lattice_b_A = 6.41;
m.lattice_gamma_deg = 119.0;
m.monolayer_thickness_A = 6.2;
m.bilayer_spacing_A = 6.2;
m.unit_cell_area_A2 = m.lattice_a_A * m.lattice_b_A * sind(m.lattice_gamma_deg);

m.bandgap_direct_eV = 1.55;
m.bandgap_range_eV = [1.50, 1.60];
m.exciton_binding_X1_meV = 118;
m.exciton_binding_X2_meV = 83;
m.exciton_bohr_radius_nm = 1.5;
m.relative_dielectric_inplane = 7.0;
m.relative_dielectric_out_of_plane = 4.0;

m.effective_mass_hole_chain_m0 = 0.35;
m.effective_mass_hole_transverse_m0 = 1.40;
m.effective_mass_electron_chain_m0 = 0.45;
m.effective_mass_electron_transverse_m0 = 0.95;
m.chain_axis = 'Re-Re chain / b-axis-like anisotropy direction';

m.raman_reference_cm1 = [151.2, 211.8, 234.1];
m.ultralow_shear_AA_cm1 = 13.0;
m.ultralow_shear_AB_cm1 = 20.0;
m.pl_peak_reference_eV = [1.54, 1.56];
m.pl_peak_axis_reference_deg = [85, 175];

m.default_polarization_uC_cm2 = 0.12;
m.default_coercive_field_kVcm = 330;
m.notes = ['Constants combine room-temperature ReS2 sliding-ferroelectric, ', ...
    'stacking-optics, exciton-binding, and anisotropic-band literature anchors.'];
end
