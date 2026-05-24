classdef DispersionCold < handle
    %DISPERSIONCOLD Cold-plasma dispersion for ray tracing.
    %   Port of: hamilt1.f, abc.f, rside1.f (idif=1 analytic branch).

    properties
        cfg
        eq
        prof
        B   % cached B struct at current point
    end

    methods
        function obj = DispersionCold(cfg, eq, prof)
            obj.cfg = cfg;
            obj.eq = eq;
            obj.prof = prof;
        end

        function H = eval(obj, u)
            z = u(1); r = u(2); phi = u(3);
            obj.B = obj.eq.bfield(z, r, phi);
            H = genray.hamiltonian(z, r, phi, u(4), u(5), u(6), obj);
        end

        function deru = rside(obj, u)
            % Port of: rside1.f — Hamiltonian ray equations (numeric derivatives)
            obj.B = obj.eq.bfield(u(1), u(2), u(3));
            deru = genray.rsideNumeric(obj, u);
        end
    end
end
