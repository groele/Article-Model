function fit = fit_raman_tensor(thetaDeg, intensity)
%FIT_RAMAN_TENSOR  Fits a general 2D symmetric Raman tensor in parallel geometry.
%
%  Model (see THEORY_DERIVATIONS.md §2):
%
%  For a symmetric 2×2 Raman tensor  R = [a, b; b, d],  the parallel-
%  polarized intensity at analyzer angle θ is:
%
%    I(θ) = scale · (a cos²θ + 2b sinθ cosθ + d sin²θ)²  +  bg
%
%  The five free parameters {a, b, d, bg, scale} are fitted by
%  Nelder–Mead simplex (fminsearch) to avoid Optimization Toolbox
%  dependency.  A weak L2 regularization on {a, b, d} prevents
%  overfitting to noise.
%
%  Outputs:
%    fit.params       — [1×5] optimized parameters
%    fit.thetaMax_deg — angle of maximum intensity (mod 180°)
%    fit.anisotropy   — I_max / I_min
%    fit.rmse         — root mean square fit residual
%    fit.modelFun     — function handle for the fitted model

thetaDeg = thetaDeg(:);
y = intensity(:);
y = y ./ max(y + eps);    % normalize for stable optimization

% Initial guess: [a, b, d, bg, scale]
x0  = [1, 0.1, 0.5, 0.05, 1];
obj = @(x) mean((ramanModel(thetaDeg, x) - y).^2) + 1e-4*sum(x(1:3).^2);

opts = optimset('Display', 'off', 'MaxIter', 4000, 'MaxFunEvals', 12000);
x = fminsearch(obj, x0, opts);

% Evaluate fit quality on fine grid
thFine = linspace(0, 180, 720)';
yFine  = ramanModel(thFine, x);
[imax, idxMax] = max(yFine);
imin = min(yFine);

fit.params       = x;
fit.thetaMax_deg = mod(thFine(idxMax), 180);
fit.anisotropy   = imax / (imin + eps);
fit.rmse         = sqrt(mean((ramanModel(thetaDeg, x) - y).^2));
fit.modelFun     = @(theta) ramanModel(theta, x);

end


function y = ramanModel(thetaDeg, x)
%RAMANMODEL  Parallel-polarized Raman intensity from tensor parameters.
%  I(θ) = scale · (a cos²θ + 2b sinθ cosθ + d sin²θ)²  +  |bg|

a = x(1);  b = x(2);  d = x(3);  bg = abs(x(4));  scale = abs(x(5));
th  = deg2rad(thetaDeg(:));
amp = a*cos(th).^2 + 2*b*sin(th).*cos(th) + d*sin(th).^2;
y   = scale * amp.^2 + bg;

end
