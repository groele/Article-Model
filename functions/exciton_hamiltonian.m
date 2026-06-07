function [evals, thetaDeg, osc, H, dipoles] = exciton_hamiltonian(ua, ub, p)
%EXCITON_HAMILTONIAN Two-state anisotropic exciton model.

E0 = p.exciton.E0 + p.exciton.E0_a1*ua + p.exciton.E0_a2*ua^2 + ...
     p.exciton.E0_b1*ub + p.exciton.E0_b2*ub^2 + ...
     p.exciton.bandEdge_a1*ua + p.exciton.bandEdge_b1*ub;
Delta = p.exciton.Delta0 + p.exciton.Delta_a1*ua + p.exciton.Delta_a2*ua^2 + ...
        p.exciton.Delta_b1*ub + p.exciton.Delta_b2*ub^2;
K = p.exciton.K0 + p.exciton.K_a1*ua + p.exciton.K_a2*ua^2 + ...
    p.exciton.K_b1*ub + p.exciton.K_b2*ub^2;

screening = 1 ./ (1 + p.exciton.screeningCoeff .* abs(sliding_polarization(ua, ub, p)));
Delta = Delta .* screening;
K = K .* screening;

H = [E0 + Delta/2, K; K, E0 - Delta/2];
[V, D] = eig(H);
[evals, order] = sort(diag(D), 'ascend');
V = V(:, order);

mu = p.exciton.mu;
alpha = p.exciton.basisAngleDeg;
thetaDeg = zeros(1, 2);
osc = zeros(1, 2);
dipoles.dx = zeros(1, 2);
dipoles.dy = zeros(1, 2);

for j = 1:2
    dx = V(1,j) * mu(1) * cosd(alpha(1)) + V(2,j) * mu(2) * cosd(alpha(2));
    dy = V(1,j) * mu(1) * sind(alpha(1)) + V(2,j) * mu(2) * sind(alpha(2));
    dipoles.dx(j) = dx;
    dipoles.dy(j) = dy;
    osc(j) = max(dx^2 + dy^2, 0.01);
    thetaDeg(j) = mod(atan2d(dy, dx), 180);
end
end
