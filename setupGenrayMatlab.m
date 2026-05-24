function setupGenrayMatlab()
%SETUPGENRAYMATLAB Add GENRAY MATLAB port to path.

root = fileparts(mfilename('fullpath'));
addpath(root);
fprintf('GENRAY MATLAB path: %s\n', root);

end
