function H = hamiltonian(z, r, phi, cnz, cnr, cm, dispObj)
%HAMILTONIAN Dispersion relation H (should be ~0 on ray).
%   Port of: hamilt1.f — id=1,2,3 cold cases.

cfg = dispObj.cfg;
prof = dispObj.prof;
eq = dispObj.eq;
id = cfg.dispers.id;
ioxm = cfg.wave.ioxm;
ib = cfg.dispers.ib;

[gam, ~] = genray.gamma1(z, r, phi, cnz, cnr, cm, dispObj.B);
ds2 = sin(gam)^2;
dc2 = cos(gam)^2;
cnt = genray.cnMag(r, cnz, cnr, cm);
cn2 = cnt^2;

if id == 3
    % Appleton-Hartree
    xi = prof.Xratio(z, r, phi, 1, eq);
    yi = prof.Yratio(z, r, phi, 1, eq);
    py2 = yi^2;
    py4 = py2^2;
    px = 1 - xi;
    px2 = px^2;
    sqrdet = sqrt(py4 * ds2^2 + 4 * py2 * px2 * dc2);
    pz = 2*px - py2*ds2 + ioxm*sqrdet;
    H = cn2 - (1 - 2*xi*px/pz);
    return;
end

if id == 1 || id == 2
    [ad, bd, cd] = genray.abcCoeffs(z, r, phi, gam, prof, eq, ib);
    d4 = ad;
    d2 = bd;
    d0 = cd;
    if id == 1
        H = d4*cn2^2 + d2*cn2 + d0;
        return;
    end
    % id == 2: N^2 = (-b + ioxm*sqrt(b^2-4ac))/(2a)
    ibmx = min(ib, prof.nbulk);
    yib = prof.Yratio(z, r, phi, ibmx, eq);
    delib = 1 - yib;
    sign_del = sign(delib + 1e-30);
    oxm = ioxm * sign_del;
    disc = d2*d2 - 4*d4*d0;
    if disc < 0
        disc = 0;
    end
    H = cn2 + (d2 - oxm*sqrt(disc)) / (2*d4);
    return;
end

error('genray:hamiltonian', 'dispersion id=%d not implemented in MATLAB port', id);

end
