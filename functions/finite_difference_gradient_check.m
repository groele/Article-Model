function result = finite_difference_gradient_check(p, ua, ub, E)
%FINITE_DIFFERENCE_GRADIENT_CHECK Compare analytic and numeric gradients.

if nargin < 2
    ua = 0.37;
end
if nargin < 3
    ub = -0.22;
end
if nargin < 4
    E = 0.18;
end

h = 1e-5;
[ga, gb] = sliding_gradient(ua, ub, E, p);
fa_plus = sliding_free_energy(ua + h, ub, E, p);
fa_minus = sliding_free_energy(ua - h, ub, E, p);
fb_plus = sliding_free_energy(ua, ub + h, E, p);
fb_minus = sliding_free_energy(ua, ub - h, E, p);

gna = (fa_plus - fa_minus) ./ (2*h);
gnb = (fb_plus - fb_minus) ./ (2*h);
err = max(abs([ga - gna, gb - gnb]));

result.analytic = [ga, gb];
result.numeric = [gna, gnb];
result.max_abs_error = err;
result.passed = err < 1e-5;
end
