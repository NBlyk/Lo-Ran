function [frames,summary] = process_captures(inputRoot,selectionFile,outputRoot)
%PROCESS_CAPTURES Example entry accepting your own data, annotations, and output.
root = fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_loran;
[frames,summary] = loran_process_dataset(inputRoot,outputRoot,selectionFile,loran_default_config());
end
