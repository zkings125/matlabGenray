function writeResultMat(result, outfile)
%WRITERESULTMAT Save ray tracing result to MAT file.

save(outfile, 'result', '-v7.3');
fprintf('Saved: %s\n', outfile);

end
