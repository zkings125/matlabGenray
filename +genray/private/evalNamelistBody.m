function s = evalNamelistBody(body)
%EVALNAMELISTBODY Parse assignment list from a namelist body string.

s = struct();
body = strrep(body, char(9), ' ');
% split on commas not inside quotes
parts = genray.private.splitAssignments(body);
for k = 1:numel(parts)
    part = strtrim(parts{k});
    if isempty(part), continue; end
    eq = strfind(part, '=');
    if isempty(eq), continue; end
    name = strtrim(part(1:eq(1)-1));
    valStr = strtrim(part(eq(1)+1:end));
    name = matlab.lang.makeValidName(name, 'ReplacementStyle', 'underscore');
    s.(name) = genray.private.parseValue(valStr);
end

end
