function v = parseValue(valStr)
%PARSEVALUE Parse a single namelist value (scalar, array, or string).

valStr = strtrim(valStr);
if isempty(valStr)
    v = [];
    return;
end
if (valStr(1) == '''' && valStr(end) == '''') || (valStr(1) == '"' && valStr(end) == '"')
    v = char(valStr(2:end-1));
    return;
end
% Fortran D exponent -> E
valStr = regexprep(valStr, '([0-9])D([+\-0-9])', '$1E$2', 'ignorecase');
valStr = regexprep(valStr, '([0-9])d([+\-0-9])', '$1e$2');
nums = sscanf(valStr, '%f');
if isempty(nums)
    v = valStr;
elseif numel(nums) == 1
    v = nums;
else
    v = nums(:)';
end

end
