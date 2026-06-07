function result = registry_periodicity_check(p)
%REGISTRY_PERIODICITY_CHECK Verify integer translations preserve U_registry.

ua = linspace(-1.2, 1.2, 17);
ub = linspace(-0.6, 0.6, 13);
[UA, UB] = meshgrid(ua, ub);
U0 = registry_potential(UA, UB, p);
Ua = registry_potential(UA + 1, UB, p);
Ub = registry_potential(UA, UB + 1, p);
Uab = registry_potential(UA + 1, UB + 1, p);

err = max(abs([U0(:) - Ua(:); U0(:) - Ub(:); U0(:) - Uab(:)]));
result.max_abs_error = err;
result.passed = err < 1e-10;
end
