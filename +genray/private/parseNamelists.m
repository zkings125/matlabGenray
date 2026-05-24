function sections = parseNamelists(text)
%PARSENAMELISTS Split Fortran namelist text into struct of sections.
%   Handles &name ... &end blocks and ! comments.

lines = regexp(text, '\r\n|\n|\r', 'split');
buf = '';
sections = struct();
current = '';

for i = 1:numel(lines)
    line = lines{i};
    % strip ! comments (Fortran)
    ex = strfind(line, '!');
    if ~isempty(ex)
        line = line(1:ex(1)-1);
    end
    line = strtrim(line);
    if isempty(line)
        continue;
    end
    if line(1) == '&'
        if ~isempty(current) && ~isempty(buf)
            sections.(current) = genray.private.evalNamelistBody(buf);
        end
        name = strtrim(line(2:end));
        if strcmpi(name, 'end')
            current = '';
            buf = '';
            continue;
        end
        % &end on same line as last assignments
        if contains(lower(name), 'end')
            tok = regexp(name, '^(\w+)', 'tokens', 'once');
            if ~isempty(tok)
                current = matlab.lang.makeValidName(tok{1});
            end
            continue;
        end
        current = matlab.lang.makeValidName(name);
        buf = '';
        continue;
    end
    if strcmpi(line, '&end') || strcmpi(line, '/end')
        if ~isempty(current) && ~isempty(buf)
            sections.(current) = genray.private.evalNamelistBody(buf);
        end
        current = '';
        buf = '';
        continue;
    end
    if ~isempty(current)
        buf = [buf, ' ', line]; %#ok<AGROW>
    end
end
if ~isempty(current) && ~isempty(buf)
    sections.(current) = genray.private.evalNamelistBody(buf);
end

end
