function result = genray(inputFile, varargin)
%GENRAY MATLAB port of GENRAY tokamak ray tracing (cold plasma core).
%   RESULT = genray('genray.in') reads namelists, equilibrium, traces rays.
%   Port of: genray.f main program (subset).
%
%   Name-value options:
%     'WorkDir'   - directory containing genray.in and equilib.dat (default: pwd)
%     'Verbose'   - logical (default true)
%     'MaxRays'   - limit rays for debugging
%
%   RESULT fields: cfg, eq, prof, disp, rays (cell array of trajectories)

p = inputParser;
addRequired('inputFile', @(x) ischar(x) || isstring(x));
addParameter('WorkDir', '', @(x) ischar(x) || isstring(x));
addParameter('Verbose', true, @islogical);
addParameter('MaxRays', inf, @(x) isnumeric(x) && isscalar(x));
parse(p, inputFile, varargin{:});
opts = p.Results;

matlabRoot = fileparts(mfilename('fullpath'));
addpath(matlabRoot);

wd = char(opts.WorkDir);
if isempty(wd), wd = pwd; end
oldDir = pwd;
cleanup = onCleanup(@() cd(oldDir));
cd(wd);

inPath = inputFile;
if ~isfile(inPath)
    if isfile(fullfile(wd, 'genray.in'))
        inPath = fullfile(wd, 'genray.in');
    elseif isfile(fullfile(wd, 'genray.dat'))
        inPath = fullfile(wd, 'genray.dat');
    else
        error('genray:NoInput', 'No genray.in/dat in %s', wd);
    end
end

cfg = readGenrayIn(inPath);
if opts.Verbose
    fprintf('GENRAY-MATLAB: read %s (mnemonic=%s)\n', inPath, cfg.genr.mnemonic);
end

eqFile = fullfile(wd, cfg.tokamak.eqdskin);
if ~isfile(eqFile)
    error('genray:NoEqdsk', 'Equilibrium file not found: %s', eqFile);
end

eq = genray.Equilibrium(eqFile, cfg.genr.r0x, cfg.genr.b0);
prof = genray.PlasmaProfiles(cfg, eq);
dispObj = genray.DispersionCold(cfg, eq, prof);
tracer = genray.RayTracer(cfg, eq, prof, dispObj);

rays = {};
nray = 1;
powj = 1;

if cfg.wave.istart == 1
    if ~isfield(cfg, 'eccone')
        error('genray:NoEccone', 'istart=1 requires &eccone/ namelist');
    end
    ec = cfg.eccone;
    cone = genray.coneEcRays(ec);
    nray = min(cone.nray, opts.MaxRays);
    zst = ec.zst / eq.r0x;
    rst = ec.rst / eq.r0x;
    phist = ec.phist * pi / 180;
    for ir = 1:nray
        [u0, initInfo] = genray.initRayFromAngles(zst, rst, phist, ...
            cone.alphaj(ir), cone.betaj(ir), 0, 0, cfg, eq, prof, dispObj);
        if initInfo.iraystop ~= 0
            if opts.Verbose
                fprintf('  ray %d: bad initial conditions (iraystop=%d)\n', ir, initInfo.iraystop);
            end
            continue;
        end
        [traj, info] = tracer.traceRay(u0, cone.powj(ir));
        traj.iray = ir;
        traj.initInfo = initInfo;
        traj.traceInfo = info;
        rays{end+1} = traj; %#ok<AGROW>
        if opts.Verbose
            fprintf('  ray %d: steps=%d, points=%d, iraystop=%d\n', ...
                ir, info.nstep, size(traj.u, 1), info.iraystop);
        end
    end
else
    error('genray:Istart', 'MATLAB port v0.1 supports istart=1 (EC cone) only. Got istart=%d', cfg.wave.istart);
end

result = struct();
result.cfg = cfg;
result.eq = eq;
result.prof = prof;
result.disp = dispObj;
result.rays = rays;
result.nrayTraced = numel(rays);
result.workDir = wd;

if strcmpi(cfg.genr.outnetcdf, 'enabled')
    try
        genray.writeResultMat(result, fullfile(wd, [char(cfg.genr.mnemonic), '_matlab.mat']));
    catch ME
        warning('genray:SaveFailed', '%s', ME.message);
    end
end

if opts.Verbose
    fprintf('GENRAY-MATLAB: finished %d rays.\n', result.nrayTraced);
end

end
