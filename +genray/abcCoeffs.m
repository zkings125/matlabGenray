function [ad, bd, cd] = abcCoeffs(z, r, phi, gam, prof, eq, ib)
%ABCCOEFFS Cold plasma dispersion coefficients (scaled A,B,C).
%   Port of: abc.f — ad,bd,cd multiply (1-Y_ib).

ds2 = sin(gam)^2;
dc2 = cos(gam)^2;
pc = 1 + dc2;
[s1, s2, s3, s4, s6, s7] = genray.plasmaSums(z, r, phi, prof, eq, ib);
ibmx = min(ib, prof.nbulk);

xib = prof.Xratio(z, r, phi, ibmx, eq);
yib = prof.Yratio(z, r, phi, ibmx, eq);
delib = 1 - yib;

if ib == 1
    xe = xib;
    ye = yib;
    peyp = xe / (1 + ye);
    a0e = -peyp * ds2;
    a1e = s7 * ds2 + s4 * dc2;
    b0e = s4 * peyp * pc + xe * (s6 - peyp) * ds2;
    b1e = -s4 * s7 * pc - s3 * (s6 - peyp) * ds2;
    c0e = -xe * s4 * (s6 - peyp);
    c1e = s4 * s3 * (s6 - peyp);
    ad = delib * a1e + a0e;
    bd = delib * b1e + b0e;
    cd = delib * c1e + c0e;
elseif ib > 1
    xe = prof.Xratio(z, r, phi, 1, eq);
    ye = prof.Yratio(z, r, phi, 1, eq);
    peyp = xe / (1 + ye);
    peym2 = peyp / (1 - ye);
    pbyp = xib / (1 + yib);
    a0b = -pbyp * ds2;
    a1b = (s1 - peym2) * ds2 + s4 * dc2;
    b0b = s4 * pbyp * pc + xib * (s3 - xe/(1-ye)) * ds2;
    b1b = -s4 * (s1 - peym2) * pc - (s2 - peyp) * (s3 - xe/(1-ye)) * ds2;
    c0b = -xib * s4 * (s3 - xe/(1-ye));
    c1b = s4 * (s2 - peyp) * (s3 - xe/(1-ye));
    ad = delib * a1b + a0b;
    bd = delib * b1b + b0b;
    cd = delib * c1b + c0b;
else
    ad = 0; bd = 0; cd = 0;
end

end
