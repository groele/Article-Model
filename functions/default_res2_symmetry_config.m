function sym = default_res2_symmetry_config()
%DEFAULT_RES2_SYMMETRY_CONFIG Default polar-state operation for ReS2 V5.
%
% The default operation is intentionally conservative.  It uses u -> -u as
% a placeholder for the operation connecting opposite polar registries.  For
% quantitative ReS2 analysis, replace M and t with the crystallographic
% layer-group operation obtained from the relaxed bilayer structures.
%
% Polar partner convention:
%   u_partner = M * u + t
%
% where u = [ua; ub] is expressed in the repository's dimensionless registry
% coordinates.

sym.material = 'bilayer 1T''-ReS2';
sym.coordinateSystem = 'dimensionless registry coordinate used by Article-Model';
sym.operationName = 'placeholder inversion-like polar partner';
sym.M = -eye(2);
sym.t = [0; 0];
sym.wrapPeriod = [2; 2];
sym.wrapToFundamentalCell = false;
sym.status = 'placeholder';
sym.confidence = 'medium-low';
sym.requiredForQuantitativeClaims = true;
sym.recommendedAction = [ ...
    'Replace this default with the exact crystallographic transformation ', ...
    'connecting the two relaxed polar stacking registries.'];
sym.claimBoundary = [ ...
    'The default u -> -u operation is adequate for symmetry testing and ', ...
    'model development, but not for quantitative ReS2-specific polar-state ', ...
    'assignment without structural calibration.'];
end
