classdef Equilibrium < handle
    %EQUILIBRIUM Tokamak 2D equilibrium from EQDSK for GENRAY.
    %   Port of: equilib.f, b.f (B-field and rho), rhospl (subset).
    %
    %   Coordinates: R,Z in meters (physical). Internal tables may use
    %   normalized r0x as in Fortran.

    properties
        raw          % struct from readEqdsk
        r0x = 1
        b0 = 1
        xma
        yma
        psimag
        psilim
        toteqd
        dpsign = 1
        psiInterp   % griddedInterpolant (R,Z) -> psi
        fInterp     % interp1 psi -> R*Bphi
        rgrid
        zgrid
    end

    methods
        function obj = Equilibrium(eqFile, r0x, b0)
            if nargin < 2, r0x = 1; end
            if nargin < 3, b0 = 1; end
            obj.r0x = r0x;
            obj.b0 = b0;
            if ischar(eqFile) || isstring(eqFile)
                obj.raw = readEqdsk(eqFile);
            else
                obj.raw = eqFile;
            end
            obj.initFromRaw();
        end

        function initFromRaw(obj)
            r = obj.raw;
            obj.xma = r.rmaxis / obj.r0x;
            obj.yma = r.zmaxis / obj.r0x;
            obj.psimag = r.simag * obj.b0 * obj.r0x^2;
            obj.psilim = r.sibry * obj.b0 * obj.r0x^2;
            obj.toteqd = r.current;
            obj.dpsign = r.dpsign;
            obj.rgrid = r.rgrid / obj.r0x;
            obj.zgrid = r.zgrid / obj.r0x;

            % psi on (R,Z) grid — apply dpsign like equilib.f
            psi = r.psirz * obj.dpsign * obj.b0 * obj.r0x^2;
            [RR, ZZ] = ndgrid(obj.rgrid, obj.zgrid);
            obj.psiInterp = griddedInterpolant(RR, ZZ, psi, 'cubic', 'nearest');

            % F = r*B_phi on uniform psi mesh from psimag to psilim
            psi1d = linspace(obj.psimag, obj.psilim, numel(r.fpol))';
            fpol = r.fpol * obj.b0 * obj.r0x;
            obj.fInterp = griddedInterpolant(psi1d, fpol, 'linear', 'nearest');
        end

        function [psi, dpsidr, dpsidz] = psiAndGrad(obj, r, z)
            r = r(:); z = z(:);
            psi = obj.psiInterp(r, z);
            if nargout > 1
                h = 1e-5;
                dpsidr = (obj.psiInterp(r+h, z) - obj.psiInterp(r-h, z)) / (2*h);
                dpsidz = (obj.psiInterp(r, z+h) - obj.psiInterp(r, z-h)) / (2*h);
            end
        end

        function rho = rhoOfPsi(obj, psi)
            den = obj.psilim - obj.psimag;
            if abs(den) < 1e-30
                rho = zeros(size(psi));
                return;
            end
            rho = sqrt(max(0, (psi - obj.psimag) / den));
            rho = min(rho, 1.5); % allow slight extrapolation outside LCFS
        end

        function [rho, psi] = rhoAt(obj, z, r, phi) %#ok<INUSD>
            psi = obj.psiAndGrad(r, z);
            rho = obj.rhoOfPsi(psi);
            % Geometric rho outside rectangular box (port of b.f iboundb>=1)
            x = r - obj.xma;
            y = z - obj.yma;
            lr = hypot(x, y);
            if lr > 1e-8
                th = atan2(y, x);
                [zb, rb] = obj.pointOnLCFS(th);
                lbc = hypot(rb - obj.xma, zb - obj.yma);
                if lr >= lbc - 1e-10
                    rho = lr / max(lbc, 1e-10);
                end
            end
        end

        function [zb, rb] = pointOnLCFS(obj, theta)
            % Poloidal angle theta; find (R,Z) on psilim surface.
            r0 = obj.xma + 0.3;
            z0 = obj.yma;
            fun = @(x) obj.psiAndGrad(x(1), x(2)) - obj.psilim;
            opts = optimoptions('fsolve', 'Display', 'off');
            try
                x = fsolve(fun, [r0; z0], opts);
                rb = x(1); zb = x(2);
            catch
                rb = obj.xma + 0.5*cos(theta);
                zb = obj.yma + 0.5*sin(theta);
            end
        end

        function B = bfield(obj, z, r, phi) %#ok<INUSD>
            % Port of: b.f — returns struct with Bz, Br, Bphi, bmod, rho, derivatives
            [psi, dpsidr, dpsidz] = obj.psiAndGrad(r, z);
            rho = obj.rhoAt(z, r, phi);
            pp = 1 ./ max(r, 1e-10);
            ffd = obj.fInterp(psi);
            spol = obj.poloidalSign();
            bz = -dpsidr * pp * spol;
            br = dpsidz * pp * spol;
            bphi = ffd * pp;
            bmod = sqrt(bz.^2 + br.^2 + bphi.^2);
            h = 1e-5;
            [~, dpsidr_p, dpsidz_p] = obj.psiAndGrad(r+h, z);
            [~, dpsidr_m, dpsidz_m] = obj.psiAndGrad(r-h, z);
            [~, dpsidr_zp, dpsidz_zp] = obj.psiAndGrad(r, z+h);
            [~, dpsidr_zm, dpsidz_zm] = obj.psiAndGrad(r, z-h);
            dpdrr = (dpsidr_p - dpsidr_m) / (2*h);
            dpdzz = (dpsidz_zp - dpsidz_zm) / (2*h);
            dpdzr = (dpsidz_p - dpsidz_m) / (2*h);
            dbzdz = -pp * dpdzr * spol;
            dbzdr = (pp^2 .* dpsidr - pp .* dpdrr) * spol;
            dbrdz = pp * dpdzz * spol;
            dbrdr = (-pp^2 .* dpsidz + pp .* dpdzr) * spol;
            dres = (obj.fInterp(psi + h) - obj.fInterp(psi - h)) / (2*h);
            dbphdr = pp .* dres .* dpsidr - pp .* bphi ./ max(r, 1e-10);
            dbphdz = pp .* dres .* dpsidz;
            B = struct('psi', psi, 'rho', rho, 'bz', bz, 'br', br, 'bphi', bphi, ...
                'bmod', bmod, 'dbzdz', dbzdz, 'dbzdr', dbzdr, 'dbrdz', dbrdz, ...
                'dbrdr', dbrdr, 'dbphdr', dbphdr, 'dbphdz', dbphdz, ...
                'dbzdph', 0, 'dbrdph', 0, 'dbpdph', 0);
        end

        function s = poloidalSign(obj)
            if obj.toteqd >= 0
                s = -1;
            else
                s = 1;
            end
            if obj.toteqd == 0
                s = -obj.dpsign;
            end
        end
    end
end
