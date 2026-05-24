classdef PlasmaProfiles < handle
    %PLASMAPROFILES Radial plasma profiles and v/w frequency ratios.
    %   Port of: dense.f, dinit.f (v0,w0), x.f, y.f

    properties
        cfg
        nbulk
        charge
        dmas
        v   % (omega_p/omega)^2 prefactor per species
        w   % omega_c/omega per species
        frqncy
        idens
        rhoGrid
        neInterp
        teInterp
        zeffInterp
    end

    methods
        function obj = PlasmaProfiles(cfg, eq)
            obj.cfg = cfg;
            obj.nbulk = cfg.plasma.nbulk;
            obj.charge = cfg.species.charge(1:obj.nbulk);
            obj.dmas = cfg.species.dmas(1:obj.nbulk);
            obj.frqncy = cfg.wave.frqncy;
            obj.idens = cfg.plasma.idens;
            obj.setupFrequencyRatios(cfg.genr.b0);
            obj.buildProfiles(cfg, eq);
        end

        function setupFrequencyRatios(obj, b0)
            % dinit.f: v0=806.2/frqncy^2, w0=28*b0/frqncy (frqncy in Hz)
            v0 = 806.2 / obj.frqncy^2;
            w0 = 28.0 * b0 / obj.frqncy;
            obj.v = zeros(1, obj.nbulk);
            obj.w = zeros(1, obj.nbulk);
            obj.v(1) = v0;
            obj.w(1) = w0;
            for i = 2:obj.nbulk
                obj.v(i) = v0 * obj.charge(i)^2 / obj.dmas(i);
                obj.w(i) = w0 * obj.charge(i) / obj.dmas(i);
            end
        end

        function buildProfiles(obj, cfg, eq)
            nd = cfg.plasma.ndens;
            obj.rhoGrid = linspace(0, 1, nd)';
            if obj.idens == 0
                ne = obj.analyticProfile(cfg.denprof, 1);
                te = obj.analyticProfile(cfg.tprof, 1);
                ze = obj.analyticZeff(cfg.zprof);
            else
                ne = obj.readTableProfile(cfg, 'dentab', 1);
                te = obj.readTableProfile(cfg, 'temtab', 1);
                ze = ones(nd, 1);
            end
            scale = cfg.plasma.den_scale(1);
            if numel(scale) == 1, scale = scale(1); end
            ne = ne * scale;
            obj.neInterp = griddedInterpolant(obj.rhoGrid, ne, 'linear', 'nearest');
            obj.teInterp = griddedInterpolant(obj.rhoGrid, te, 'linear', 'nearest');
            obj.zeffInterp = griddedInterpolant(obj.rhoGrid, ze, 'linear', 'nearest');
        end

        function prof = analyticProfile(obj, p, ispec)
            rho = obj.rhoGrid;
            n0 = p.dense0(ispec);
            nb = p.denseb(ispec);
            a = p.rn1de(ispec);
            b = p.rn2de(ispec);
            if isfield(p, 'ate0')
                n0 = p.ate0(ispec);
                nb = p.ateb(ispec);
                a = p.rn1te(ispec);
                b = p.rn2te(ispec);
            end
            prof = (n0 - nb) .* (1 - rho.^a).^b + nb;
        end

        function ze = analyticZeff(obj, p)
            rho = obj.rhoGrid;
            ze = (p.zeff0 - p.zeffb) .* (1 - rho.^p.rn1zeff).^p.rn2zeff + p.zeffb;
        end

        function prof = readTableProfile(obj, cfg, tabName, ispec)
            % Uniform mesh table: prof(nbulk*ndens) row-major in Fortran
            nd = cfg.plasma.ndens;
            rho = obj.rhoGrid;
            if isfield(cfg, tabName) && isfield(cfg.(tabName), 'prof')
                data = cfg.(tabName).prof(:);
                if numel(data) >= nd
                    prof = data((ispec-1)*nd + (1:nd))';
                else
                    prof = genray.PlasmaProfiles.fallbackAnalytic(cfg, ispec, nd);
                end
            else
                prof = genray.PlasmaProfiles.fallbackAnalytic(cfg, ispec, nd);
            end
        end

        function n = density(obj, z, r, phi, ispec, eq)
            B = eq.bfield(z, r, phi);
            n = obj.neInterp(B.rho);
            n = max(n, 0);
        end

        function x = Xratio(obj, z, r, phi, ispec, eq)
            n = obj.density(z, r, phi, ispec, eq);
            x = obj.v(ispec) * n;
            x = max(x, 1e-6);
        end

        function y = Yratio(obj, z, r, phi, ispec, eq)
            B = eq.bfield(z, r, phi);
            y = obj.w(ispec) * B.bmod;
            if abs(y) < 1e-8, y = sign(y + eps) * 1e-8; end
        end
    end

    methods (Static)
        function prof = fallbackAnalytic(cfg, ispec, nd)
            rho = linspace(0, 1, nd)';
            p = cfg.denprof;
            prof = (p.dense0(ispec) - p.denseb(ispec)) .* (1 - rho.^p.rn1de(ispec)).^p.rn2de(ispec) + p.denseb(ispec);
        end
    end
end
