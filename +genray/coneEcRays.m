function rays = coneEcRays(ec)
%CONEECRAYS EC antenna cone ray angles and power weights.
%   Port of: cone_ec.f (simplified: one cone, na1*na2+1 rays).

pi = atan(1) * 4;
% GENRAY namelist angles are in degrees
alpha1 = ec.alpha1 * pi / 180;
alpha2 = ec.alpha2 * pi / 180;
na1 = round(ec.na1);
na2 = round(ec.na2);
phin = ec.alfast * pi / 180;
tetan = ec.betast * pi / 180;
phist = ec.phist * pi / 180;
powtot = ec.powtot;

nray = na1 * na2 + 1;
alphaj = zeros(nray, 1);
betaj = zeros(nray, 1);
powj = zeros(nray, 1);

ct = cos(tetan);
st = sin(tetan);
cp = cos(phin);
sp = sin(phin);

iray = 1;
alphaj(1) = phin;
betaj(1) = 0.5*pi - tetan;
if na1 == 0
    powj(1) = 1;
else
    da1 = alpha1 / na1;
    powj(1) = 2*pi * (1 - cos(0.5*da1));
end

if na1 > 0
    da1 = alpha1 / na1;
    da2 = 2*pi / na2;
    for i = 2:na1+1
        a1i = da1 * (i-1);
        for j = 1:na2
            iray = iray + 1;
            a2j = da2 * (j-1);
            stt = sin(tetan + a1i*cos(a2j));
            ctt = cos(tetan + a1i*cos(a2j));
            srr = sin(a1i*sin(a2j));
            crr = cos(a1i*sin(a2j));
            nr = stt*cp + ctt*srr*sp;
            nph = stt*sp - ctt*srr*cp;
            nz = ctt*crr;
            alphaj(iray) = atan2(nph, nr);
            betaj(iray) = atan2(nz, hypot(nr, nph));
            powj(iray) = 2*pi*(cos(tetan+0.5*da1) - cos(tetan+da1)) / max(na1*na2, 1);
        end
    end
end

powj = powj / sum(powj) * powtot;
rays = struct('nray', nray, 'alphaj', alphaj, 'betaj', betaj, 'powj', powj, ...
    'rst', ec.rst, 'zst', ec.zst, 'phist', phist);

end
