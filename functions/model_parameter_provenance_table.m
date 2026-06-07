function T = model_parameter_provenance_table(p)
%MODEL_PARAMETER_PROVENANCE_TABLE Convert provenance struct to a table.

prov = p.provenance(:);
n = numel(prov);
name = strings(n, 1);
value = zeros(n, 1);
unit = strings(n, 1);
source = strings(n, 1);
fit_status = strings(n, 1);
confidence = strings(n, 1);
for i = 1:n
    name(i) = string(prov(i).name);
    value(i) = prov(i).value;
    unit(i) = string(prov(i).unit);
    source(i) = string(prov(i).source);
    fit_status(i) = string(prov(i).fit_status);
    confidence(i) = string(prov(i).confidence);
end
T = table(name, value, unit, source, fit_status, confidence);
end
