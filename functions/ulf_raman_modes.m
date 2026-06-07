function ulf = ulf_raman_modes(ua, ub, p)
%ULF_RAMAN_MODES Stacking-sensitive ultralow-frequency Raman modes.

ua = ua(:);
ub = ub(:);
n = numel(ua);
m = numel(p.ulfModes);
freq = zeros(n, m);
intensity = zeros(n, m);
labels = strings(1, m);

for im = 1:m
    mode = p.ulfModes(im);
    labels(im) = string(mode.label);
    freq(:, im) = mode.omega0 + mode.domega_a.*ua + ...
        mode.domega_b.*ub + mode.domega_ab.*ua.*ub;
    intensity(:, im) = mode.intensity0 .* ...
        max(0.05, 1 + mode.anisotropy .* cos(2*pi*ua) + 0.15*sin(2*pi*ub));
end

ulf.frequency_cm1 = freq;
ulf.intensity = intensity;
ulf.labels = labels;
end
