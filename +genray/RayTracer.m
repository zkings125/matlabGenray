classdef RayTracer < handle
    %RAYTRACER Runge-Kutta ray tracer (Hamiltonian formulation).
    %   Port of: drkgs2.f, outpt (subset), genray.f main loop.

    properties
        cfg
        eq
        prof
        disp
        prmt
        maxSteps = 50000
    end

    methods
        function obj = RayTracer(cfg, eq, prof, dispObj)
            obj.cfg = cfg;
            obj.eq = eq;
            obj.prof = prof;
            obj.disp = dispObj;
            obj.prmt = [cfg.numercl.prmt1, cfg.numercl.prmt2, cfg.numercl.prmt3, ...
                cfg.numercl.prmt4, cfg.numercl.prmt6, cfg.numercl.prmt9];
            if isfield(cfg.numercl, 'maxsteps_rk')
                obj.maxSteps = cfg.numercl.maxsteps_rk;
            end
        end

        function [traj, info] = traceRay(obj, u0, powIni)
            % u0 = [z;r;phi;nz;nr;r*nphi] normalized units
            if nargin < 3, powIni = 1; end
            t = obj.prmt(1);
            tEnd = obj.prmt(2);
            dt = obj.prmt(3);
            dsOut = obj.prmt(5);
            delPow = obj.cfg.wave.delpwrmn;

            u = u0(:);
            traj.t = t;
            traj.u = u.';
            traj.pow = powIni;
            traj.H = obj.disp.eval(u);
            nrefl = 0;
            ireflm = obj.cfg.wave.ireflm;
            sPrev = 0;
            info.iraystop = 0;
            info.nstep = 0;
            info.nrefl = 0;

            for step = 1:obj.maxSteps
                if t >= tEnd
                    info.iraystop = 2;
                    break;
                end
                B = obj.eq.bfield(u(1), u(2), u(3));
                if B.rho > 1.02 && obj.cfg.wave.no_reflection == 0
                    if nrefl >= ireflm
                        info.iraystop = 3;
                        break;
                    end
                    u = obj.reflectLCFS(u, B);
                    nrefl = nrefl + 1;
                    continue;
                end
                k1 = obj.disp.rside(u);
                k2 = obj.disp.rside(u + 0.5*dt*k1);
                k3 = obj.disp.rside(u + 0.5*dt*k2);
                k4 = obj.disp.rside(u + dt*k3);
                uNew = u + (dt/6) * (k1 + 2*k2 + 2*k3 + k4);
                t = t + dt;
                u = uNew;
                H = obj.disp.eval(u);
                pow = powIni; % absorption not yet: constant power
                s = obj.poloidalDistance(u, traj.u(end,:).');
                if s - sPrev >= dsOut
                    traj.t(end+1, 1) = t; %#ok<AGROW>
                    traj.u(end+1, :) = u.'; %#ok<AGROW>
                    traj.pow(end+1, 1) = pow; %#ok<AGROW>
                    traj.H(end+1, 1) = H; %#ok<AGROW>
                    sPrev = s;
                end
                if pow < delPow * powIni
                    info.iraystop = 4;
                    break;
                end
                info.nstep = step;
            end
            info.nrefl = nrefl;
            if info.iraystop == 0
                info.iraystop = 1;
            end
        end

        function u = reflectLCFS(obj, u, B)
            % Simplified LCFS reflection (mirror N component w.r.t. grad psi)
            [~, dpsidr, dpsidz] = obj.eq.psiAndGrad(u(2), u(1));
            grad = [dpsidz; dpsidr];
            grad = grad / (norm(grad) + 1e-30);
            nvec = [u(4); u(5)];
            nperp = dot(nvec, grad) * grad;
            npar = nvec - nperp;
            u(4:5) = npar - nperp;
            % shift slightly inside
            u(1) = u(1) - 1e-4 * grad(1);
            u(2) = u(2) - 1e-4 * grad(2);
        end

        function s = poloidalDistance(obj, u, u0)
            dr = u(2) - u0(2);
            dz = u(1) - u0(1);
            s = hypot(dr, dz);
        end
    end
end
