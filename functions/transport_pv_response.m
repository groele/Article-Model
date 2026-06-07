function tr = transport_pv_response(ua, ub, E, p)
%TRANSPORT_PV_RESPONSE Schottky and photovoltaic response proxies.

Pz = sliding_polarization(ua, ub, p);
kBT = 8.617333262e-5 * p.transport.temperatureK;

schottky_eV = p.transport.schottky0_eV - ...
    p.transport.lambda_P .* Pz - p.transport.lambda_E .* E;
thermionic = p.transport.darkCurrentScale .* exp(-schottky_eV ./ max(kBT, eps));

bandOffset_eV = p.transport.bandOffset0_eV + p.transport.bandOffset_P .* Pz;
typeVWeight = 1 ./ (1 + exp(-(abs(bandOffset_eV) - ...
    p.transport.typeVThreshold_eV) ./ 0.015));

shiftCurrent = p.transport.shiftCurrent0 + p.transport.shiftCurrent_P .* Pz;
photocurrent = p.transport.J0 + p.transport.eta_P .* Pz + ...
    p.transport.eta_E .* E + 0.08 .* normalize_signed(thermionic) + shiftCurrent;

tr.Pz = Pz;
tr.schottky_eV = schottky_eV;
tr.thermionicProxy = thermionic;
tr.bandOffset_eV = bandOffset_eV;
tr.typeVWeight = typeVWeight;
tr.shiftCurrentProxy = shiftCurrent;
tr.photocurrent = photocurrent;
end

function y = normalize_signed(x)
x = x(:);
r = max(x) - min(x);
if r < eps
    y = zeros(size(x));
else
    y = 2*((x - min(x))./r) - 1;
end
end
