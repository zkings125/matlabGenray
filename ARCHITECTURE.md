# GENRAY MATLAB — Architecture map (Fortran → MATLAB)

This document maps the Fortran codebase to the MATLAB package for incremental porting.

## Layer 1 — I/O (done in v0.1)

| Fortran | MATLAB |
|---------|--------|
| `read_write_genray_input.f` | `readGenrayIn.m`, `+genray/private/parseNamelists.m` |
| `equilib.f` → `input` | `readEqdsk.m` |
| `default_in` | `+genray/defaults.m` |

## Layer 2 — Equilibrium & profiles (done in v0.1)

| Fortran | MATLAB |
|---------|--------|
| `equilib.f`, `dinitr` | `+genray/Equilibrium.m` |
| `b.f` | `Equilibrium.bfield` |
| `rhospl.f` | `Equilibrium.rhoAt`, `rhoOfPsi` |
| `dense.f`, `spldens.f` | `+genray/PlasmaProfiles.m` |
| `x.f`, `y.f`, `s.f` | `Xratio`, `Yratio`, `plasmaSums.m` |

## Layer 3 — Dispersion & ray RHS (done in v0.1, cold only)

| Fortran | MATLAB |
|---------|--------|
| `abc.f` | `abcCoeffs.m` |
| `hamilt1.f` | `hamiltonian.m` |
| `rside1.f` | `DispersionCold.rside` → `rsideNumeric.m` |
| `gamma1.f`, `cn.f` | `gamma1.m`, `cnMag.m` |
| `tensrcld.f`, `forest.f`, `abhay_disp.f` | *planned v0.3* |

## Layer 4 — Time integration (done in v0.1, basic)

| Fortran | MATLAB |
|---------|--------|
| `drkgs2.f`, `drkgs.f` | `+genray/RayTracer.m` (RK4 + simple LCFS reflect) |
| `output.f` → `outpt` | *planned* — absorption, output mesh |
| `scatperp.f` | *planned* |

## Layer 5 — Launch & driver (partial v0.1)

| Fortran | MATLAB |
|---------|--------|
| `cone_ec.f` | `coneEcRays.m` |
| `dinit.f` → `dinit_1ray` | `initRayFromAngles.m` |
| `dinit_mr` | *planned* — full multi-ray setup |
| `grill_lh.f` | *planned v0.2* — `istart=2` |
| `genray.f` | `genray.m` |

## Layer 6 — Post-processing (not started)

| Fortran | MATLAB |
|---------|--------|
| `write3d.f`, `netcdfr3d.f` | MAT/netCDF export |
| `emission.f` | *planned* |
| `oxb.f` | *planned* |
| `adj_*.f` | *planned* |
| MPI inserts in `genray.f` | optional `parfor` / external |

## Class diagram (MATLAB)

```
genray.m
  ├── readGenrayIn → cfg struct
  ├── genray.Equilibrium(eqFile, r0x, b0)
  ├── genray.PlasmaProfiles(cfg, eq)
  ├── genray.DispersionCold(cfg, eq, prof)
  └── genray.RayTracer.traceRay(u0)
```

## Adding a new dispersion ID

1. Implement tensor/dispersion in new file (e.g. `+genray/hamiltonianHot.m`).
2. Branch in `hamiltonian.m` on `cfg.dispers.id`.
3. Ensure `rsideNumeric` or analytic derivatives remain consistent.
4. Add test in `tests/` comparing H≈0 on known launch point.
