function [u, info] = initRayFromAngles(zst, rst, phist, alfast, betast, cnteta, cnphi, cfg, eq, prof, dispObj)
%INITRAYFROMANGLES Initialize ray state u from antenna angles.
%   Port of: dinit_1ray (istart=1 EC) — cold plasma N from angles.
%
%   alfast, betast: toroidal and poloidal launch angles [rad] at antenna.
%   cnteta, cnphi: initial N_theta, N_phi (may be updated).

u = zeros(6, 1);
u(1) = zst / eq.r0x;
u(2) = rst / eq.r0x;
u(3) = phist;
info.iraystop = 0;

B = eq.bfield(u(1), u(2), u(3));
if B.rho > 1.01
    info.iraystop = 1;
    return;
end

% Wave vector direction from angles (cone_ec / dinit convention)
st = sin(betast);
ct = cos(betast);
cp = cos(alfast);
sp = sin(alfast);
nr = st * cp;
nph = st * sp;
nz = ct;
% Map to (N_z, N_r, r*N_phi) in cylindrical basis — approximate using poloidal plane
thetapol = atan2(u(1) - eq.yma, u(2) - eq.xma);
cnz = nz;
cnr = nr * cos(thetapol) + nz * sin(thetapol) * 0; %#ok<NASGU>
% Use cnteta as |N| poloidal component hint if provided
if nargin >= 6 && cnteta > 0
    nmag = cnteta;
else
    % Solve cold dispersion for |N| at launch (id=2)
    gam = atan2(hypot(nr, nph), nz);
    [ad, bd, cd] = genray.abcCoeffs(u(1), u(2), u(3), gam, prof, eq, cfg.dispers.ib);
    ioxm = cfg.wave.ioxm;
    disc = max(0, bd^2 - 4*ad*cd);
    n2 = (-bd + ioxm*sqrt(disc)) / (2*ad);
    nmag = sqrt(max(n2, 1e-6));
end
dir = [nz; nr*cos(thetapol); nr*sin(thetapol)];
dir = dir / norm(dir);
u(4) = nmag * dir(1);
u(5) = nmag * dir(2);
u(6) = nmag * dir(3) * u(2);
if nargin >= 7 && cnphi ~= 0
    u(6) = cnphi * u(2);
end

H = dispObj.eval(u);
if abs(H) > 0.1
    warning('genray:initRay', 'Launch point H=%.4e (expected ~0)', H);
end

end
