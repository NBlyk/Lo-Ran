function result = rebuild_ctc(requestIQFile,outputRoot,profile)
%REBUILD_CTC Example entry accepting your own isolated LoRa master-frame IQ.
if nargin<3, profile = 'legacy64'; end
root = fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_loran;
result = loran_ctc_export(requestIQFile,outputRoot,loran_ctc_config(profile));
end
