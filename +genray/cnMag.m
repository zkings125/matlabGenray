function cnt = cnMag(r, cnz, cnr, cm)
%CNMAG Refractive index magnitude |N|.
%   Port of: cn.f

r2 = max(r^2, 1e-20);
cnt = sqrt(cnz^2 + cnr^2 + cm^2 / r2);

end
