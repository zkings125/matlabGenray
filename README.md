# GENRAY MATLAB Port

MATLAB reimplementation of the [GENRAY](https://www.compxco.com/genray.html) tokamak ray-tracing code. Fortran sources live in the parent directory; this folder is a **structured port** with a clear path to feature parity.

## Status (v0.1)

| Module | Fortran reference | MATLAB status |
|--------|-------------------|---------------|
| Namelist input | `read_write_genray_input.f` | `readGenrayIn.m` — core sections |
| EQDSK | `equilib.f` | `readEqdsk.m`, `genray.Equilibrium` |
| Profiles | `dense.f`, `dinit.f` | `genray.PlasmaProfiles` — analytic + table |
| Cold dispersion `id=2,3` | `hamilt1.f`, `abc.f`, `s.f` | `genray.DispersionCold` |
| Ray RHS | `rside1.f` | `genray.rside1` |
| RK integration | `drkgs2.f` | `genray.RayTracer` |
| EC cone launch | `cone_ec.f`, `dinit_1ray` | `genray.coneEcRays`, `initRayFromAngles` |
| Hot plasma, emission, MPI, ADJ, wall | many `.f` files | **not yet** |

## Quick start

```matlab
addpath(fullfile(fileparts(mfilename('fullpath'))));  % matlab/
setupGenrayMatlab();

% 单元测试（无需 eqdsk）:
cd tests; runTests

% 集成测试（官方回归 test10, EC istart=1）:
cd examples; run_regression_test10

% 或手动调用:
result = genray('genray.in', 'WorkDir', '/path/to/case');
```

See `examples/run_single_ray.m` and `tests/testColdDispersion.m`.

## Publishing to GitHub

Upstream 仍为 `compxco/genray`（`origin`）。个人 fork 与单独 MATLAB 仓库可按下面操作。

### 推送到 fork：`zkings125/genray`

在仓库根目录执行一次（若已存在同名 remote，可先 `git remote remove zkings`）：

```bash
git remote add zkings https://github.com/zkings125/genray.git
git fetch zkings
git push -u zkings master
```

- 若使用 **HTTPS**，浏览器或凭据管理器会提示登录 GitHub（或配置 [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)）。
- 若使用 **SSH**，将 remote 改为 `git@github.com:zkings125/genray.git` 并确保本机已加载对应密钥。

### 仅 MATLAB 代码：新建仓库 `matlabGenray`

在 **仅包含** `matlab/` 内容的独立仓库中发布（与 Fortran 主仓库历史分离）：

```bash
cd matlab
git init
git add .
git commit -m "Initial MATLAB GENRAY port scaffold"
gh repo create matlabGenray --public --source=. --remote=origin --push
```

将 `matlabGenray` 换成你想要的仓库名；若需建在用户名下：`gh repo create zkings125/matlabGenray --public --source=. --remote=origin --push`。

## Package layout

```
matlab/
  genray.m              % main driver
  readGenrayIn.m        % namelist parser
  readEqdsk.m           % G-EQDSK reader
  +genray/
    Equilibrium.m       % psi(R,Z), B, rho
    PlasmaProfiles.m    % n_e, T, v/w arrays
    DispersionCold.m    % Hamiltonian & ABC
    RayTracer.m         % RK4 ray loop
    rside1.m, hamiltonian.m, bfield.m, ...
    coneEcRays.m, initRayFromAngles.m
  examples/
  tests/
```

## Units

Matches **genray.in (MKSA)**: lengths in meters, `frqncy` in Hz, temperatures in keV, `b0` in Tesla. Internal ray state `u = [z; r; phi; nz; nr; r*nphi]` uses normalized coordinates when `r0x`, `b0` are applied in `Equilibrium` (same convention as Fortran after `transform_genray_in_to_dat`).

## Roadmap

1. **v0.2** — Table profiles (`dentab`), LCFS reflection in `RayTracer`, power deposition (`outpt` subset).
2. **v0.3** — `istart=2` grill LH (`grill_lh.f`), `id=6` hot Hermitian dispersion.
3. **v0.4** — Emission, netCDF export, regression test parity with `00_Genray_Regression_Tests`.

Contributions should mirror Fortran file names in comments (`% Port of: hamilt1.f`).
