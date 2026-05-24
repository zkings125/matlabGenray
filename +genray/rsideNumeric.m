function deru = rsideNumeric(dispObj, u)
%RSIDENUMERIC Numerical Hamiltonian derivatives for ray RHS.
%   Port of: rside1.f idif=2 branch.

step = 1e-5;
z = u(1); r = u(2); phi = u(3);
cnz = u(4); cnr = u(5); cm = u(6);

H0 = genray.hamiltonian(z, r, phi, cnz, cnr, cm, dispObj);
Hz = genray.hamiltonian(z+step, r, phi, cnz, cnr, cm, dispObj);
Hr = genray.hamiltonian(z, r+step, phi, cnz, cnr, cm, dispObj);
Hph = genray.hamiltonian(z, r, phi+step, cnz, cnr, cm, dispObj);
Hnz = genray.hamiltonian(z, r, phi, cnz+step, cnr, cm, dispObj);
Hnr = genray.hamiltonian(z, r, phi, cnz, cnr+step, cm, dispObj);
Hm  = genray.hamiltonian(z, r, phi, cnz, cnr, cm+step, dispObj);

dHdz = (Hz - H0) / step;
dHdr = (Hr - H0) / step;
dHdph = (Hph - H0) / step;
dHdcnz = (Hnz - H0) / step;
dHdcnr = (Hnr - H0) / step;
dHdcm = (Hm - H0) / step;

% dH/domega via frequency perturbation (port of rside1 / wf=frqncy)
epsf = 1e-6;
f0 = dispObj.prof.frqncy;
dispObj.prof.frqncy = f0 * (1 + epsf);
dispObj.prof.setupFrequencyRatios(dispObj.cfg.genr.b0);
Hf = genray.hamiltonian(z, r, phi, cnz, cnr, cm, dispObj);
dispObj.prof.frqncy = f0;
dispObj.prof.setupFrequencyRatios(dispObj.cfg.genr.b0);
dHdw = (Hf - H0) / (f0 * epsf);
if abs(dHdw) < 1e-18
    dHdw = sign(dHdw + eps) * 1e-18;
end

deru = zeros(6, 1);
deru(1) = -dHdcnz / dHdw;
deru(2) = -dHdcnr / dHdw;
deru(3) = -dHdcm / dHdw;
deru(4) = dHdz / dHdw;
deru(5) = dHdr / dHdw;
deru(6) = dHdph / dHdw;

end
