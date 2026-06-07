function scan = shg_angular_scan(ua, ub, p, pumpAnglesDeg, analyzerMode)
%SHG_ANGULAR_SCAN Compute tensor-SHG angular fingerprints.

if nargin < 4 || isempty(pumpAnglesDeg)
    pumpAnglesDeg = (0:2:178)';
end
if nargin < 5 || isempty(analyzerMode)
    analyzerMode = 'parallel';
end

pumpAnglesDeg = pumpAnglesDeg(:);
intensity = zeros(size(pumpAnglesDeg));
phase = zeros(size(pumpAnglesDeg));
chi = complex(zeros(size(pumpAnglesDeg)));

for i = 1:numel(pumpAnglesDeg)
    pump = pumpAnglesDeg(i);
    switch lower(analyzerMode)
        case 'cross'
            analyzer = pump + 90;
        case 'fixed-x'
            analyzer = 0;
        case 'fixed-y'
            analyzer = 90;
        otherwise
            analyzer = pump;
    end
    shg = shg_response(ua, ub, p, pump, analyzer);
    intensity(i) = shg.intensity;
    phase(i) = shg.phase_rad;
    chi(i) = shg.chi;
end

scan.angle_deg = pumpAnglesDeg;
scan.intensity = intensity;
scan.phase_rad = unwrap(phase);
scan.chi = chi;
scan.analyzer_mode = analyzerMode;
end
