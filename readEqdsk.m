function eq = readEqdsk(filename)
%READEQDSK Read a G-EQDSK equilibrium file (EQDSK format).
%   EQ = readEqdsk('equilib.dat')
%   Port of: equilib.f / subroutine input (standard 2-column format).
%
%   Fields: nw, nh, rdim, zdim, rleft, zmid, rmaxis, zmaxis, simag, sibry,
%   bcentr, current, fpol, pres, ffprim, pprime, psirz, qpsi, rgrid, zgrid.

narginchk(1, 1);
fid = fopen(filename, 'r');
if fid < 0
    error('readEqdsk:NoFile', 'Cannot open %s', filename);
end
cleanup = onCleanup(@() fclose(fid));

% Skip title line(s) until we find nw nh
nw = []; nh = [];
while true
    line = fgetl(fid);
    if ~ischar(line), error('readEqdsk:EOF', 'Unexpected EOF'); end
    nums = sscanf(line, '%d');
    if numel(nums) >= 2
        nw = nums(1);
        nh = nums(2);
        if numel(nums) >= 3
            eq.nveqd = nums(3);
        else
            eq.nveqd = nw;
        end
        break;
    end
end

eq.nw = nw;
eq.nh = nh;
if ~isfield(eq, 'nveqd'), eq.nveqd = nw; end

% Remaining numeric data (5 values per line, e format)
data = [];
while true
    line = fgetl(fid);
    if ~ischar(line), break; end
    v = sscanf(line, '%f');
    if ~isempty(v)
        data = [data; v(:)]; %#ok<AGROW>
    end
end

need = 20 + 4*eq.nveqd + nw*nh + eq.nveqd;
if numel(data) < need
    warning('readEqdsk:ShortFile', ...
        'Expected >= %d values, got %d. Some fields may be incomplete.', need, numel(data));
end

i = 1;
get5 = @() localGet5(data, i);
block = get5(); i = i + 5;
eq.rdim = block(1); eq.zdim = block(2); eq.rcentr = block(3);
eq.rleft = block(4); eq.zmid = block(5);

block = get5(); i = i + 5;
eq.rmaxis = block(1); eq.zmaxis = block(2);
eq.simag = block(3); eq.sibry = block(4); eq.bcentr = block(5);

block = get5(); i = i + 5;
eq.current = block(1);
eq.simag2 = block(2); eq.sibry2 = block(3); % often duplicate
eq.xdum = block(4); eq.nbbbs = block(5);

block = get5(); i = i + 5;
eq.limitr = block(1); eq.zxlim = block(2);
eq.zxlim2 = block(3); eq.xdum2 = block(4); eq.xdum3 = block(5);

n = eq.nveqd;
eq.fpol = data(i:i+n-1); i = i + n;
eq.pres = data(i:i+n-1); i = i + n;
eq.ffprim = data(i:i+n-1); i = i + n;
eq.pprime = data(i:i+n-1); i = i + n;

eq.psirz = reshape(data(i:i+nw*nh-1), [nw, nh]); i = i + nw*nh;
eq.qpsi = data(i:i+n-1); i = i + n;

eq.rgrid = linspace(eq.rleft, eq.rleft + eq.rdim, nw)';
eq.zgrid = linspace(eq.zmid - eq.zdim/2, eq.zmid + eq.zdim/2, nh)';

eq.filename = char(filename);
if eq.simag > eq.sibry
    eq.dpsign = -1;
else
    eq.dpsign = 1;
end

end

function block = localGet5(data, idx)
block = zeros(5, 1);
for k = 1:5
    if idx + k - 1 <= numel(data)
        block(k) = data(idx + k - 1);
    end
end
end
