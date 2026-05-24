%% run_regression_test10.m — 使用官方回归算例 test10（EC, istart=1）
%
% 算例路径: genray/00_Genray_Regression_Tests/test10/
%   - genray.in
%   - eqdsk_MAST-like  (在 &tokamak/ 中 eqdskin 指定)

setupGenrayMatlab();

repoRoot = fileparts(fileparts(mfilename('fullpath')));
testDir = fullfile(repoRoot, '..', '00_Genray_Regression_Tests', 'test10');

assert(isfile(fullfile(testDir, 'genray.in')), ...
    '缺少 genray.in: %s', testDir);
assert(isfile(fullfile(testDir, 'eqdsk_MAST-like')), ...
    '缺少 eqdsk: %s', testDir);

fprintf('=== GENRAY MATLAB 集成测试: test10 ===\n');
fprintf('目录: %s\n', testDir);

result = genray('genray.in', 'WorkDir', testDir, 'MaxRays', 5, 'Verbose', true);

fprintf('\n摘要: 成功追踪 %d 条射线\n', result.nrayTraced);
for k = 1:numel(result.rays)
    tr = result.rays{k};
    fprintf('  ray %d: %d 轨迹点, iraystop=%d, 步数=%d\n', ...
        tr.iray, size(tr.u, 1), tr.traceInfo.iraystop, tr.traceInfo.nstep);
end

if ~isempty(result.rays)
    figure('Name', 'GENRAY MATLAB test10');
    hold on;
    for k = 1:numel(result.rays)
        u = result.rays{k}.u;
        plot(u(:, 2) * result.eq.r0x, u(:, 1) * result.eq.r0x, '.-', ...
            'DisplayName', sprintf('ray %d', k));
    end
    xlabel('R [m]'); ylabel('Z [m]');
    title('test10 — poloidal projection');
    legend('Location', 'best'); grid on; axis equal;
end

outMat = fullfile(testDir, [char(result.cfg.genr.mnemonic), '_matlab.mat']);
if isfile(outMat)
    fprintf('结果已保存: %s\n', outMat);
end
