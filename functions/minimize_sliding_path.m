function [uaPath, ubPath, PPath] = minimize_sliding_path(Efield, p)
%MINIMIZE_SLIDING_PATH Track a metastable sliding branch by 2D descent.

uaPath = zeros(size(Efield));
ubPath = zeros(size(Efield));
PPath  = zeros(size(Efield));

ua = -sqrt(abs(p.landau.ax) / p.landau.bx);
ub = (Efield(1) * p.landau.p1b - p.landau.kxy * ua) / p.landau.ky;
eta = p.landau.relaxRate;

for i = 1:numel(Efield)
    E = Efield(i);
    for k = 1:p.landau.nRelax
        [dF_dua, dF_dub] = sliding_gradient(ua, ub, E, p);
        ua = ua - eta * dF_dua;
        ub = ub - eta * dF_dub;
        ua = max(min(ua, 2.0), -2.0);
        ub = max(min(ub, 2.0), -2.0);
    end
    uaPath(i) = ua;
    ubPath(i) = ub;
    PPath(i) = sliding_polarization(ua, ub, p);
end
end
