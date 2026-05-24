function [s1, s2, s3, s4, s6, s7] = plasmaSums(z, r, phi, prof, eq, ib)
%PLASMASUMS Cold-plasma dispersion sums s1..s7.
%   Port of: s.f

nbulk = prof.nbulk;
ds1 = 0; ds2 = 0; ds3 = 0; ds4 = 0; ds6 = 0; ds7 = 0;

if nbulk > 1
    for i = 2:nbulk
        xi = prof.Xratio(z, r, phi, i, eq);
        yi = prof.Yratio(z, r, phi, i, eq);
        ds3 = ds3 + xi / (1 + yi);
        ds4 = ds4 + xi;
        if ib == 1
            ds6 = ds6 + xi / (1 - yi);
            ds7 = ds7 + xi / (1 - yi * yi);
        end
        if i == ib || ib == 1
            continue;
        end
        ds1 = ds1 + xi / (1 - yi * yi);
        ds2 = ds2 + xi / (1 - yi);
    end
end

xe = prof.Xratio(z, r, phi, 1, eq);
s1 = 1 - ds1;
s2 = 1 - ds2;
s3 = 1 - ds3;
s4 = 1 - ds4 - xe;
s6 = 1 - ds6;
s7 = 1 - ds7;

end
