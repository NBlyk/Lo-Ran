function summary = time_pipeline(inputFiles,outputRoot)
%TIME_PIPELINE Time caller-selected IQ files, ten repeats per file and Nz.
root = fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_loran;
summary = loran_benchmark_latency(inputFiles,outputRoot,loran_default_config());
end
