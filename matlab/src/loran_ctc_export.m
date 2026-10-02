function result = loran_ctc_export(requestIQFile,outputRoot,cfg)
%LORAN_CTC_EXPORT Reconstruct external request-only IQ and export SDR/chunk files.
% No captured or reconstructed example signal is included in the code release.
if nargin<3, cfg = loran_ctc_config(); end
assert(~isfolder(outputRoot) && ~isfile(outputRoot),'LoRan:OutputExists', ...
    'Choose a new output directory.');
projection = loran_ctc_project(loran_read_iq(requestIQFile),cfg);
[waveform,metadata] = loran_ctc_modulate(projection.data_symbols,cfg);
payload = [];
if cfg.build_nonht_packet
    assert(strcmp(cfg.profile,'legacy64'),'LoRan:CTCProfile', ...
        'BCC payload inversion supports legacy64, not the HE LDPC draft.');
    payload = loran_ctc_nonht_stream(projection.data_symbols,cfg.scrambler_seed,cfg.wifi_idle_time_s);
end
mkdir(outputRoot);
metadata.float32 = loran_write_iq(fullfile(outputRoot,'ctc_data_ofdm.cf32'),waveform,'float32');
metadata.hackrf = loran_write_iq(fullfile(outputRoot,'ctc_data_ofdm.cs8'),waveform,'hackrf-int8');
bitsPerChunk = log2(cfg.qam_order);
chunks = projection.qam_indices(:);
fid = fopen(fullfile(outputRoot,'ctc_qam_chunks.bin'),'wb','ieee-le');
assert(fid>=0,'LoRan:OutputFile','Cannot create chunks file.');
cleanup = onCleanup(@() fclose(fid));
if bitsPerChunk<=8, precision = 'uint8'; else, precision = 'uint16'; end
assert(fwrite(fid,chunks,precision)==numel(chunks),'LoRan:OutputFile','Incomplete chunk write.');
clear cleanup;
writematrix(projection.qam_indices,fullfile(outputRoot,'ctc_qam_indices.csv'));
metadata.chunk_bits = bitsPerChunk;
metadata.bit_order = cfg.bit_order;
metadata.output_to_input_duration_ratio = projection.output_to_input_duration_ratio;
metadata.fft_scale = projection.fft_scale;
metadata.input_padding_samples = projection.input_padding_samples;
if ~isempty(payload)
    metadata.nonht_coded_bit_disagreement = payload.coded_bit_disagreement;
    metadata.nonht_packet_count = payload.packet_count;
    metadata.nonht_idle_time_s = payload.idle_time_s;
    metadata.nonht_iq = loran_write_iq(fullfile(outputRoot,'ctc_nonht_packet.cf32'), ...
        payload.wifi_waveform,'float32');
end
fid = fopen(fullfile(outputRoot,'ctc_metadata.json'),'w','n','UTF-8');
assert(fid>=0,'LoRan:OutputFile','Cannot create metadata file.');
cleanup = onCleanup(@() fclose(fid)); fprintf(fid,'%s',jsonencode(metadata)); clear cleanup;
save(fullfile(outputRoot,'ctc_generated.mat'),'projection','waveform','metadata','payload');
result = struct('projection',projection,'waveform',waveform,'metadata',metadata,'payload',payload);
end
