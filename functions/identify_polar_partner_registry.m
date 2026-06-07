function partner = identify_polar_partner_registry(ua, ub, p)
%IDENTIFY_POLAR_PARTNER_REGISTRY Map registry coordinates to polar partners.
%
% V5 helper for explicit polar-state operations.
%
%   partner = identify_polar_partner_registry(ua, ub, p)
%
% returns the registry coordinates related to (ua,ub) by the configured
% polar-state operation u_partner = M*u + t.  The configuration is read from
% p.symmetry.polarOperation when available; otherwise it falls back to
% default_res2_symmetry_config().

ua = ua(:);
ub = ub(:);

sym = default_res2_symmetry_config();
if nargin >= 3 && isstruct(p) && isfield(p, 'symmetry')
    if isfield(p.symmetry, 'polarOperation')
        sym = p.symmetry.polarOperation;
    elseif isfield(p.symmetry, 'polarTransformMatrix')
        sym.M = p.symmetry.polarTransformMatrix;
        sym.t = [0; 0];
    end
end

M = sym.M;
t = sym.t(:);
if ~isequal(size(M), [2 2])
    error('Polar operation M must be a 2x2 matrix.');
end
if numel(t) ~= 2
    error('Polar operation translation t must contain two elements.');
end

U = M * [ua.'; ub.'] + t;
uaP = U(1,:).';
ubP = U(2,:).';

if isfield(sym, 'wrapToFundamentalCell') && sym.wrapToFundamentalCell
    period = [2; 2];
    if isfield(sym, 'wrapPeriod') && numel(sym.wrapPeriod) == 2
        period = sym.wrapPeriod(:);
    end
    uaP = local_wrap_centered(uaP, period(1));
    ubP = local_wrap_centered(ubP, period(2));
end

partner.ua = uaP;
partner.ub = ubP;
partner.operation = sym;
partner.operationString = sprintf('u_partner = M*u + t, M=[%.3g %.3g; %.3g %.3g], t=[%.3g %.3g]', ...
    M(1,1), M(1,2), M(2,1), M(2,2), t(1), t(2));
end

function xw = local_wrap_centered(x, period)
xw = mod(x + period/2, period) - period/2;
end
