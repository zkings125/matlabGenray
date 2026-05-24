function [gam, dc] = gamma1(z, r, phi, cnz, cnr, cm, B)
%GAMMA1 Angle between N and B, and cos(gam).
%   Port of: gamma1.f

cnt = genray.cnMag(r, cnz, cnr, cm);
gg = cnz * B.bz + cnr * B.br + cm * B.bphi / max(r, 1e-10);
arg = gg / (cnt * max(B.bmod, 1e-30));
arg = max(-1, min(1, arg));
gam = acos(arg);
dc = cos(gam);

end
