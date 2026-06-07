function T = material_parameter_table(p)
%MATERIAL_PARAMETER_TABLE Convert ReS2 material constants to a table.

m = p.material;
name = [
    "lattice_a";
    "lattice_b";
    "lattice_gamma";
    "unit_cell_area";
    "monolayer_thickness";
    "bilayer_spacing";
    "direct_bandgap";
    "bandgap_min";
    "bandgap_max";
    "exciton_binding_X1";
    "exciton_binding_X2";
    "exciton_bohr_radius";
    "epsilon_inplane";
    "epsilon_out_of_plane";
    "hole_mass_chain";
    "hole_mass_transverse";
    "electron_mass_chain";
    "electron_mass_transverse";
    "AA_shear_ULF";
    "AB_shear_ULF";
    "default_polarization";
    "default_coercive_field"
    ];
value = [
    m.lattice_a_A;
    m.lattice_b_A;
    m.lattice_gamma_deg;
    m.unit_cell_area_A2;
    m.monolayer_thickness_A;
    m.bilayer_spacing_A;
    m.bandgap_direct_eV;
    m.bandgap_range_eV(1);
    m.bandgap_range_eV(2);
    m.exciton_binding_X1_meV;
    m.exciton_binding_X2_meV;
    m.exciton_bohr_radius_nm;
    m.relative_dielectric_inplane;
    m.relative_dielectric_out_of_plane;
    m.effective_mass_hole_chain_m0;
    m.effective_mass_hole_transverse_m0;
    m.effective_mass_electron_chain_m0;
    m.effective_mass_electron_transverse_m0;
    m.ultralow_shear_AA_cm1;
    m.ultralow_shear_AB_cm1;
    m.default_polarization_uC_cm2;
    m.default_coercive_field_kVcm
    ];
unit = [
    "A";
    "A";
    "deg";
    "A^2";
    "A";
    "A";
    "eV";
    "eV";
    "eV";
    "meV";
    "meV";
    "nm";
    "relative";
    "relative";
    "m0";
    "m0";
    "m0";
    "m0";
    "cm^-1";
    "cm^-1";
    "uC/cm^2";
    "kV/cm"
    ];
source_level = repmat("literature-guided default", numel(name), 1);
T = table(name, value, unit, source_level, ...
    'VariableNames', {'name','value','unit','source_level'});
end
