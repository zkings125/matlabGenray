function parts = splitAssignments(str)
%SPLITASSIGNMENTS Split namelist assignments on commas outside quotes.

parts = {};
buf = '';
inQuote = false;
q = '';
for i = 1:numel(str)
    c = str(i);
    if inQuote
        buf = [buf, c]; %#ok<AGROW>
        if c == q
            inQuote = false;
        end
        continue;
    end
    if c == '''' || c == '"'
        inQuote = true;
        q = c;
        buf = [buf, c]; %#ok<AGROW>
        continue;
    end
    if c == ','
        parts{end+1} = buf; %#ok<AGROW>
        buf = '';
        continue;
    end
    buf = [buf, c]; %#ok<AGROW>
end
if ~isempty(buf)
    parts{end+1} = buf; %#ok<AGROW>
end

end
