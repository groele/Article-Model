%% Run all ReS2 sliding-ferroelectric model programs
% One-entry launcher for the original Raman-PL demo, the bilayer dynamic
% modulation model, and the deep physical mechanism figure.

clear; clc; close all;
isLauncherRunning = true; %#ok<NASGU> Used by scripts executed through run().

rootDir = fileparts(mfilename('fullpath'));
if isempty(rootDir)
    rootDir = pwd;
end
cd(rootDir);
addpath(genpath('functions'));

fprintf('Running original sliding-coordinate Raman-PL demo...\n');
run('main_demo_ReS2_sliding_theory.m');

fprintf('Running bilayer dynamic modulation model...\n');
run('main_bilayer_ReS2_dynamic_modulation.m');

fprintf('Generating deep physical mechanism figure...\n');
make_deep_mechanism_figure(rootDir);

fprintf('Running physics validation and audit report...\n');
p = default_res2_params();
validate_model_physics(p, fullfile(rootDir, 'output', 'validation'));

clear isLauncherRunning;
fprintf('\nAll available programs finished. Outputs are in:\n%s\n', fullfile(rootDir, 'output'));

function make_deep_mechanism_figure(rootDir)
scriptPath = fullfile(rootDir, 'scripts', 'make_deep_mechanism_figure.py');
if ~exist(scriptPath, 'file')
    warning('Deep mechanism figure script not found: %s', scriptPath);
    return;
end

pythonCandidates = {
    fullfile(getenv('USERPROFILE'), '.cache', 'codex-runtimes', ...
        'codex-primary-runtime', 'dependencies', 'python', 'python.exe')
    'python'
    'py'
    };

for i = 1:numel(pythonCandidates)
    pythonExe = pythonCandidates{i};
    cmd = sprintf('"%s" "%s"', pythonExe, scriptPath);
    [status, output] = system(cmd);
    if status == 0
        fprintf('%s\n', strtrim(output));
        return;
    end
end

warning(['Could not regenerate Fig12_deep_physical_mechanism.png from MATLAB. ', ...
    'The existing output image is still available if it was generated earlier.']);
end
