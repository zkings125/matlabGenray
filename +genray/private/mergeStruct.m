function out = mergeStruct(base, over)
%MERGESTRUCT Recursive struct merge (overrides base).

out = base;
if ~isstruct(over)
    return;
end
fn = fieldnames(over);
for k = 1:numel(fn)
    f = fn{k};
    if isfield(out, f) && isstruct(out.(f)) && isstruct(over.(f))
        out.(f) = genray.private.mergeStruct(out.(f), over.(f));
    else
        out.(f) = over.(f);
    end
end

end
