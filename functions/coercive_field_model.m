function out = coercive_field_model(p)
%COERCIVE_FIELD_MODEL Vacancy/doping proxy for sliding coercive field.

ref = max(p.doping.referenceVacancyFraction, eps);
vacancyRatio = p.doping.sulfurVacancyFraction / ref;
carrierTerm = abs(p.doping.carrierDensity_cm2) / 1e13;
Ec = p.doping.coerciveField0_kVcm + ...
     p.doping.coerciveFieldPerReference_kVcm * vacancyRatio + ...
     80 * carrierTerm;

out.vacancyRatio = vacancyRatio;
out.carrierTerm = carrierTerm;
out.coerciveField_kVcm = Ec;
out.barrierScale = 1 + p.doping.barrierScalePerReference * vacancyRatio;
end
