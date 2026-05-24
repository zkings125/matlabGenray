%% run_single_ray.m — Example GENRAY MATLAB ray trace
%
% 注意: MATLAB v0.1 仅支持 istart=1 (EC 锥)。不要用 test7 (LH, istart=2)。
% 推荐算例: test10 或 ci-tests/test-EC-ITER-Centra-CD

setupGenrayMatlab();

repoRoot = fileparts(fileparts(mfilename('fullpath')));
testDir = fullfile(repoRoot, '..', '00_Genray_Regression_Tests', 'test10');

if ~isfile(fullfile(testDir, 'genray.in'))
    fprintf(['Test directory not found: %s\n' ...
        'Use examples/run_regression_test10.m or set testDir manually.\n'], testDir);
    return;
end

fprintf('Running genray in: %s\n', testDir);
result = genray('genray.in', 'WorkDir', testDir, 'MaxRays', 3);

if ~isempty(result.rays)
    traj = result.rays{1};
    figure;
    plot(traj.u(:, 2) * result.eq.r0x, traj.u(:, 1) * result.eq.r0x, 'b.-');
    xlabel('R [m]'); ylabel('Z [m]');
    title(sprintf('Ray 1 (%d points)', size(traj.u, 1)));
    grid on; axis equal;
end
