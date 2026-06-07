function sim = simulate_rate_dependent_hysteresis(p, barrier_meV, sweepSpec, kineticParams)
%SIMULATE_RATE_DEPENDENT_HYSTERESIS Rate-dependent sliding-switching proxy.
%
% This function converts a static barrier into a sweep-rate-dependent
% switching probability using a Kramers-like hazard integral.  It is designed
% to connect NEB barriers to experimentally measured hysteresis trends.

if nargin < 1 || isempty(p)
    p = default_res2_params();
end
if nargin < 2 || isempty(barrier_meV)
    barrier_meV = 50;
end
if nargin < 3 || isempty(sweepSpec)
    sweepSpec.Emax = 1.2;
    sweepSpec.nPoints = 301;
    sweepSpec.sweepRate_norm_per_s = 0.02;
    sweepSpec.T_K = p.landau.T;
end
if nargin < 4
    kineticParams = struct();
end

Eup = linspace(-sweepSpec.Emax, sweepSpec.Emax, sweepSpec.nPoints)';
Edown = linspace(sweepSpec.Emax, -sweepSpec.Emax, sweepSpec.nPoints)';
E = [Eup; Edown(2:end)];
dE = abs([diff(E); E(end)-E(end-1)]);
dt = dE ./ max(sweepSpec.sweepRate_norm_per_s, eps);

state = -ones(size(E));
Psw = zeros(size(E));
hazard = zeros(size(E));
currentState = -1;
cumulativeHazard = 0;

for i = 1:numel(E)
    rate = switching_rate_kramers_model(barrier_meV, E(i), sweepSpec.T_K, kineticParams);
    % Only allow switching when field opposes the current state.
    fieldOpposes = sign(E(i)) ~= currentState && abs(E(i)) > 0;
    if fieldOpposes
        h = rate.Gamma_Hz .* dt(i);
    else
        h = 0;
    end
    cumulativeHazard = cumulativeHazard + h;
    prob = 1 - exp(-cumulativeHazard);
    if prob > 0.5
        currentState = sign(E(i));
        cumulativeHazard = 0;
    end
    state(i) = currentState;
    Psw(i) = prob;
    hazard(i) = h;
end

sim.E = E;
sim.state = state;
sim.Pswitch = Psw;
sim.hazard = hazard;
sim.sweepSpec = sweepSpec;
sim.kineticParams = kineticParams;
sim.barrier_meV = barrier_meV;
sim.claimLevel = 'Rate-dependent hysteresis proxy; quantitative use requires calibrated barrier and attempt frequency.';
end
