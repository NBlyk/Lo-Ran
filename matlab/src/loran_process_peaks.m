function [frames,summary] = loran_process_peaks(peakFile,selectionFile,outputRoot,cfg)
%LORAN_PROCESS_PEAKS Apply the same ranging formula to external saved peak JSON.
% Peak entries have capture_id, nz, and peak_bins; selections supply windows.
if nargin<4, cfg = loran_default_config(); end
records = jsondecode(fileread(peakFile));
selections = jsondecode(fileread(selectionFile));
[frames,summary,chirpPairs] = loran_results_from_peaks(records,selections,cfg);
if nargin>=3 && ~isempty(outputRoot)
    assert(~isfolder(outputRoot) && ~isfile(outputRoot),'LoRan:OutputExists', ...
        'Choose a new output directory.');
    mkdir(outputRoot);
    writetable(frames,fullfile(outputRoot,'loran_frame_results.csv'));
    writetable(summary,fullfile(outputRoot,'loran_nz_summary.csv'));
    writetable(chirpPairs,fullfile(outputRoot,'loran_chirp_pairs.csv'));
    save(fullfile(outputRoot,'loran_processed_peaks.mat'), ...
        'frames','summary','chirpPairs','records','selections','cfg');
end
end
