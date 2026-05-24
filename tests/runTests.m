%% runTests.m — Run GENRAY MATLAB unit tests

setupGenrayMatlab();

fprintf('testHamiltonianOnAxis...\n');
testHamiltonianOnAxis();

fprintf('testReadGenrayIn...\n');
testReadGenrayIn();

fprintf('All tests passed.\n');

function testHamiltonianOnAxis()
    cfg = genray.defaults();
    cfg.wave.frqncy = 110e9;
    cfg.dispers.id = 2;
    cfg.genr.b0 = 2.0;
    raw = fakeEqdsk();
    eq = genray.Equilibrium(raw, 1, cfg.genr.b0);
    prof = genray.PlasmaProfiles(cfg, eq);
    dispObj = genray.DispersionCold(cfg, eq, prof);
    u = [0; eq.xma; 0; 1.5; 0.2; 0];
    H = dispObj.eval(u);
    assert(abs(H) < 0.5, 'Hamiltonian should be near zero, got %g', H);
end

function testReadGenrayIn()
    tpl = fullfile(fileparts(fileparts(mfilename('fullpath'))), ...
        '..', 'genray_templates_archive', 'genray.in_template_MKSA_191207');
    assert(isfile(tpl), 'Template missing: %s', tpl);
    cfg = readGenrayIn(tpl);
    assert(abs(cfg.genr.r0x - 1) < 1e-6);
    assert(isfield(cfg, 'wave'));
end

function raw = fakeEqdsk()
    raw.nw = 65; raw.nh = 65;
    raw.rleft = 0.5; raw.rdim = 1.5; raw.zmid = 0; raw.zdim = 2;
    raw.rmaxis = 1.0; raw.zmaxis = 0;
    raw.simag = 0; raw.sibry = 1; raw.bcentr = 2; raw.current = 1e6;
    raw.dpsign = 1;
    raw.rgrid = linspace(raw.rleft, raw.rleft+raw.rdim, raw.nw)';
    raw.zgrid = linspace(raw.zmid-raw.zdim/2, raw.zmid+raw.zdim/2, raw.nh)';
    [R, Z] = ndgrid(raw.rgrid, raw.zgrid);
    raw.psirz = ((R-raw.rmaxis).^2 + (Z-raw.zmaxis).^2) * 0.5;
    raw.fpol = linspace(2*raw.rmaxis*raw.bcentr, 2.5*raw.bcentr, raw.nw)';
    raw.pres = zeros(raw.nw, 1);
    raw.ffprim = zeros(raw.nw, 1);
    raw.pprime = zeros(raw.nw, 1);
    raw.qpsi = ones(raw.nw, 1);
end
