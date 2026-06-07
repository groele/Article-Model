function dft = load_dft_registry_grid(path)
%LOAD_DFT_REGISTRY_GRID Load DFT registry-grid calibration data.
%
% Expected columns, if available:
%   ua, ub, energy_meV_per_cell, Pz_uC_cm2, charge_transfer_e,
%   band_gap_eV, band_offset_eV
%
% Only ua, ub, and energy_meV_per_cell are strictly required for fitting the
% registry-energy surface.  The other columns are optional calibration
% targets for polarization, charge transfer, exciton/transport proxies, and
% band alignment.

if nargin < 1 || isempty(path)
    path = fullfile(pwd, 'data', 'dft_registry_grid_template.csv');
end

if ~exist(path, 'file')
    error(['DFT registry grid file not found: %s\n', ...
        'Create it using data/dft_registry_grid_template.csv as a guide.'], path);
end

T = readtable(path);
required = {'ua','ub','energy_meV_per_cell'};
for i = 1:numel(required)
    if ~ismember(required{i}, T.Properties.VariableNames)
        error('Missing required DFT grid column: %s', required{i});
    end
end

dft.table = T;
dft.ua = T.ua(:);
dft.ub = T.ub(:);
dft.energy_meV_per_cell = T.energy_meV_per_cell(:);
dft.energy_zeroed_meV = dft.energy_meV_per_cell - min(dft.energy_meV_per_cell);
dft.hasPz = ismember('Pz_uC_cm2', T.Properties.VariableNames);
dft.hasChargeTransfer = ismember('charge_transfer_e', T.Properties.VariableNames);
dft.hasBandGap = ismember('band_gap_eV', T.Properties.VariableNames);
dft.hasBandOffset = ismember('band_offset_eV', T.Properties.VariableNames);
if dft.hasPz; dft.Pz_uC_cm2 = T.Pz_uC_cm2(:); end
if dft.hasChargeTransfer; dft.charge_transfer_e = T.charge_transfer_e(:); end
if dft.hasBandGap; dft.band_gap_eV = T.band_gap_eV(:); end
if dft.hasBandOffset; dft.band_offset_eV = T.band_offset_eV(:); end

dft.sourcePath = path;
dft.nPoints = height(T);
dft.claimLevel = 'calibration data container; quantitative status depends on DFT convergence and structural relaxation settings';
end
