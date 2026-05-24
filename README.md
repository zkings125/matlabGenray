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
