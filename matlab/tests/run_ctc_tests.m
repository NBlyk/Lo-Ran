function report = run_ctc_tests()
%RUN_CTC_TESTS Test merged CTC modules using generated inputs, not experiments.
for depth = [6 10]
    labels = (0:2^depth-1).';
    for order = {'lsb','msb'}
        bits = loran_chunks_to_bits(labels,depth,order{1});
        recovered = loran_bits_to_chunks(bits,depth,order{1});
        assert(isequal(double(recovered),labels));
    end
end
loran_assert_throws(@() loran_chunks_to_bits([-1;0],6));
loran_assert_throws(@() loran_bits_to_chunks([0;1],6));
cfgRanging = loran_default_config(); phy = LoRanPHY(10,cfgRanging);
target = conj(phy.Downchirp);
for profile = {'legacy64','he1024'}
    cfg = loran_ctc_config(profile{1});
    result = loran_ctc_project(target,cfg);
    [waveform,metadata] = loran_ctc_modulate(result.data_symbols,cfg);
    expectedRows = 48;
    if strcmp(profile{1},'he1024'), expectedRows = 234; end
    assert(size(result.qam_indices,1)==expectedRows);
    assert(all(result.qam_indices(:)>=0 & result.qam_indices(:)<cfg.qam_order));
    assert(all(isfinite(waveform)) && ~metadata.full_wifi_phy_frame);
    blocks = reshape(waveform,cfg.output_fft_length+cfg.output_cp_length,[]);
    spectrum = fftshift(fft(blocks(cfg.output_cp_length+1:end,:),[],1),1);
    assert(max(abs(spectrum(cfg.output_data_indices,:)-result.data_symbols),[],'all')<1e-10);
    assert(max(abs(spectrum(cfg.output_pilot_indices,:)-cfg.pilot_symbols),[],'all')<1e-10);
    assert(isequal(blocks(1:cfg.output_cp_length,:),blocks(end-cfg.output_cp_length+1:end,:)));
    % Compare QAM decisions with the old explicit nearest-point operation.
    constellation = qammod(0:cfg.qam_order-1,cfg.qam_order,'UnitAveragePower',true);
    for k = 1:min(25,numel(result.desired_tones))
        [~,index] = min(abs(result.desired_tones(k)-constellation));
        assert(abs(result.mapped_tones(k)-constellation(index))<1e-10);
    end
end
% A valid WLAN codeword must invert back to its known payload, unlike arbitrary
% projected constellation targets whose coding mismatch is reported explicitly.
payload = repmat([0;1;0;0;1;1;0;1],128,1); seed = 17;
wifi = wlanNonHTConfig('MCS',7,'PSDULength',128);
waveform = wlanWaveformGenerator(payload,wifi,'ScramblerInitialization',seed, ...
    'WindowTransitionTime',0);
indices = wlanFieldIndices(wifi);
symbols = wlanNonHTOFDMDemodulate(waveform(indices.NonHTData(1):indices.NonHTData(2)), ...
    'NonHT-Data',wifi);
info = wlanNonHTOFDMInfo('NonHT-Data',wifi);
reconstructed = loran_ctc_nonht_payload(symbols(info.DataIndices,:),128,seed);
assert(isequal(reconstructed.payload_bits,payload));
assert(reconstructed.coded_bit_disagreement==0);
segmented = loran_ctc_nonht_stream(repmat(symbols(info.DataIndices,:),1,31),seed);
assert(segmented.packet_count==2 && segmented.target_symbol_ranges(end,2)==155);
folder = tempname; mkdir(folder);
iqFile = fullfile(folder,'generated_request.cf32');
loran_write_iq(iqFile,target,'float32');
cfg = loran_ctc_config('legacy64'); cfg.build_nonht_packet = true;
output = loran_ctc_export(iqFile,fullfile(folder,'generated'),cfg);
assert(~isempty(output.waveform) && isfile(fullfile(folder,'generated','ctc_nonht_packet.cf32')));
labels = loran_read_chunks(fullfile(folder,'generated','ctc_qam_chunks.bin'),6);
assert(isequal(labels,output.projection.qam_indices(:)));
cfg = loran_ctc_config('he1024');
he = loran_ctc_export(iqFile,fullfile(folder,'generated_he'),cfg);
labels = loran_read_chunks(fullfile(folder,'generated_he','ctc_qam_chunks.bin'),10);
assert(isequal(labels,he.projection.qam_indices(:)));
report = struct('passed',true,'uses_experiment_data',false, ...
    'profiles_tested',{{'legacy64','he1024'}},'nonht_payload_roundtrip',true,'matlab_version',version);
disp(report);
end
