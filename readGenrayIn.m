function cfg = readGenrayIn(filename)
%READGENRAYIN Parse GENRAY genray.in / genray.dat namelist file.
%   CFG = readGenrayIn('genray.in') returns a struct of namelist sections.
%   Port of: read_write_genray_input.f / read_all_namelists (subset).
%
%   Missing sections receive defaults from genray.defaults().

narginchk(1, 1);
if ~isfile(filename)
    error('readGenrayIn:NoFile', 'Input file not found: %s', filename);
end

raw = fileread(filename);
sections = genray.private.parseNamelists(raw);
defs = genray.defaults();

cfg = defs;
fn = fieldnames(sections);
for k = 1:numel(fn)
    sec = fn{k};
    if isfield(cfg, sec)
        cfg.(sec) = genray.private.mergeStruct(cfg.(sec), sections.(sec));
    else
        cfg.(sec) = sections.(sec);
    end
end

cfg.meta.inputFile = char(filename);
cfg.meta.readTime = datetime('now');

% Type coercion for common fields
if isfield(cfg, 'genr')
    cfg.genr.r0x = doubleScalar(cfg.genr, 'r0x', 1.0);
    cfg.genr.b0 = doubleScalar(cfg.genr, 'b0', 1.0);
end
if isfield(cfg, 'wave')
    cfg.wave.frqncy = doubleScalar(cfg.wave, 'frqncy', 1e11);
    cfg.wave.istart = round(doubleScalar(cfg.wave, 'istart', 1));
    cfg.wave.ioxm = round(doubleScalar(cfg.wave, 'ioxm', 1));
    cfg.wave.delpwrmn = doubleScalar(cfg.wave, 'delpwrmn', 1e-3);
end
if isfield(cfg, 'dispers')
    cfg.dispers.id = round(doubleScalar(cfg.dispers, 'id', 2));
    cfg.dispers.ib = round(doubleScalar(cfg.dispers, 'ib', 1));
    cfg.dispers.iabsorp = round(doubleScalar(cfg.dispers, 'iabsorp', 4));
end
if isfield(cfg, 'numercl')
    cfg.numercl.isolv = round(doubleScalar(cfg.numercl, 'isolv', 1));
    cfg.numercl.irkmeth = round(doubleScalar(cfg.numercl, 'irkmeth', 2));
    cfg.numercl.idif = round(doubleScalar(cfg.numercl, 'idif', 1));
    for i = 1:9
        fni = sprintf('prmt%d', i);
        if ~isfield(cfg.numercl, fni)
            cfg.numercl.(fni) = defs.numercl.(fni);
        else
            cfg.numercl.(fni) = doubleScalar(cfg.numercl, fni, defs.numercl.(fni));
        end
    end
end
if isfield(cfg, 'plasma')
    cfg.plasma.nbulk = round(doubleScalar(cfg.plasma, 'nbulk', 1));
    cfg.plasma.idens = round(doubleScalar(cfg.plasma, 'idens', 0));
    cfg.plasma.ndens = round(doubleScalar(cfg.plasma, 'ndens', 21));
end

end

function v = doubleScalar(s, name, default)
if isfield(s, name)
    x = s.(name);
    if ischar(x) || isstring(x)
        v = str2double(x);
    else
        v = double(x(1));
    end
    if isnan(v), v = default; end
else
    v = default;
end
end
