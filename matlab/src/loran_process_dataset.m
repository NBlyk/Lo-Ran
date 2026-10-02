function [frames,summary] = loran_process_dataset(inputRoot,outputRoot,selectionFile,cfg)
%LORAN_PROCESS_DATASET Process caller-supplied cropped IQ and reviewed annotations.
% Files are float32 I,Q pairs. The release supplies code, not experiment data.
if nargin<4, cfg = loran_default_config(); end
assert(nargin>=3 && ~isempty(selectionFile),'LoRan:SelectionFile', ...
    'Provide your own selection JSON; no experimental selections are bundled.');
assert(isfolder(inputRoot),'LoRan:InputDirectory','Input directory does not exist.');
assert(~isfolder(outputRoot) && ~isfile(outputRoot),'LoRan:OutputExists', ...
    'Choose a new output directory.');
validateattributes(cfg.nz_values,{'numeric'},{'vector','integer','positive'});
assert(numel(unique(cfg.nz_values))==numel(cfg.nz_values),'LoRan:NzValues','Duplicate Nz values.');
selections = jsondecode(fileread(selectionFile));
recorded = struct('capture_id',{},'nz',{},'peak_bins',{},'peak_amplitudes',{});
for k = 1:numel(selections)
    chosen = selections(k);
    relative = strrep(chosen.relative_iq_file,'/',filesep);
    assert(isempty(regexp(relative,'(^|[\\/])\.\.([\\/]|$)|^[A-Za-z]:|^[\\/]','once')), ...
        'LoRan:RelativePath','IQ paths must be relative to inputRoot.');
    % The filter is independent of Nz, so each capture is filtered only once.
    signal = loran_prepare_signal(loran_read_iq(fullfile(inputRoot,relative)),cfg);
    for nz = cfg.nz_values(:).'
        phy = LoRanPHY(nz,cfg); result = phy.extract(signal,cfg);
        recorded(end+1) = struct('capture_id',chosen.capture_id,'nz',nz, ...
            'peak_bins',result.peak_bins,'peak_amplitudes',result.peak_amplitudes); %#ok<AGROW>
    end
    fprintf('Processed %d/%d captures\n',k,numel(selections));
end
[frames,summary,chirpPairs] = loran_results_from_peaks(recorded,selections,cfg);
mkdir(outputRoot);
writetable(frames,fullfile(outputRoot,'loran_frame_results.csv'));
writetable(summary,fullfile(outputRoot,'loran_nz_summary.csv'));
writetable(chirpPairs,fullfile(outputRoot,'loran_chirp_pairs.csv'));
save(fullfile(outputRoot,'loran_processed_results.mat'), ...
    'frames','summary','recorded','chirpPairs','cfg','selections');
end
