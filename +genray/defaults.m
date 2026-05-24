function cfg = defaults()
%DEFAULTS Default GENRAY namelist values (MKSA-oriented).
%   Port of: default_in / read_write_genray_input.f (subset).

cfg.genr.mnemonic = 'genray';
cfg.genr.rayop = 'both';
cfg.genr.dielectric_op = 'disabled';
cfg.genr.r0x = 1.0;
cfg.genr.b0 = 1.0;
cfg.genr.outdat = 'zrn.dat';
cfg.genr.stat = 'new';
cfg.genr.partner = 'disabled';
cfg.genr.outnetcdf = 'enabled';
cfg.genr.outprint = 'enabled';
cfg.genr.outxdraw = 'enabled';

cfg.tokamak.eqdskin = 'equilib.dat';
cfg.tokamak.indexrho = 2;
cfg.tokamak.ipsi = 1;
cfg.tokamak.ionetwo = 0;
cfg.tokamak.ieffic = 3;
cfg.tokamak.psifactr = 0.99;
cfg.tokamak.deltripl = 0;
cfg.tokamak.nloop = 0;
cfg.tokamak.i_ripple = 1;
cfg.tokamak.NR = 101;
cfg.tokamak.n_wall = 0;

cfg.wave.frqncy = 1e11;
cfg.wave.ioxm = 1;
cfg.wave.ioxm_n_npar = 0;
cfg.wave.ireflm = 1;
cfg.wave.jwave = 2;
cfg.wave.istart = 1;
cfg.wave.delpwrmn = 1e-3;
cfg.wave.ibw = 0;
cfg.wave.i_vgr_ini = 1;
cfg.wave.no_reflection = 0;

cfg.scatnper.iscat = 0;
cfg.scatnper.scatd = 0;
cfg.scatnper.rhoscat = 0;
cfg.scatnper.iscat_lh_nicola = 0;

cfg.dispers.ib = 1;
cfg.dispers.id = 2;
cfg.dispers.iherm = 1;
cfg.dispers.iabsorp = 4;
cfg.dispers.iswitch = 0;
cfg.dispers.iflux = 1;
cfg.dispers.i_geom_optic = 1;
cfg.dispers.ray_direction = 1;
cfg.dispers.refl_loss = 0;
cfg.dispers.ion_absorption = 'enabled';

cfg.numercl.irkmeth = 2;
cfg.numercl.ndim1 = 6;
cfg.numercl.isolv = 1;
cfg.numercl.idif = 1;
cfg.numercl.nrelt = 0;
cfg.numercl.prmt1 = 0;
cfg.numercl.prmt2 = 1e6;
cfg.numercl.prmt3 = 1e-4;
cfg.numercl.prmt4 = 1e-4;
cfg.numercl.prmt6 = 0.01;
cfg.numercl.prmt9 = 0;
cfg.numercl.icorrect = 1;
cfg.numercl.maxsteps_rk = 50000;

cfg.output.iwcntr = 0;
cfg.output.i_plot_b = 0;
cfg.output.itools = 0;

cfg.plasma.nbulk = 1;
cfg.plasma.izeff = 2;
cfg.plasma.idens = 0;
cfg.plasma.ndens = 21;
cfg.plasma.temp_scale = 1;
cfg.plasma.den_scale = 1;
cfg.plasma.nonuniform_profile_mesh = 'disabled';

cfg.species.charge = [1, 1, 6];
cfg.species.dmas = [1, 3674, 22044];

cfg.emission.i_emission = 0;
cfg.emission.nfreq = 1;

cfg.ox.i_ox = 0;

cfg.eccone.ncone = 1;
cfg.eccone.zst = 0;
cfg.eccone.rst = 1.5;
cfg.eccone.phist = 0;
cfg.eccone.betast = 90;
cfg.eccone.alfast = 0;
cfg.eccone.alpha1 = 0.1;
cfg.eccone.alpha2 = 0;
cfg.eccone.na1 = 0;
cfg.eccone.na2 = 0;
cfg.eccone.powtot = 1e6;
cfg.eccone.raypatt = 'cone';

cfg.denprof.dense0 = 3e19;
cfg.denprof.denseb = 1e19;
cfg.denprof.rn1de = 2;
cfg.denprof.rn2de = 1;

cfg.tprof.ate0 = 2;
cfg.tprof.ateb = 0.1;
cfg.tprof.rn1te = 2;
cfg.tprof.rn2te = 1;

cfg.tpopprof.tp0 = 1;
cfg.tpopprof.tpb = 1;
cfg.tpopprof.rn1tp = 2;
cfg.tpopprof.rn2tp = 1;

cfg.zprof.zeff0 = 1;
cfg.zprof.zeffb = 1;
cfg.zprof.rn1zeff = 2;
cfg.zprof.rn2zeff = 1;

cfg.varden.var0 = 0;

end
