function cfg = loran_ctc_config(profile)
%LORAN_CTC_CONFIG Consolidated legacy/HE settings from the reconstruction drafts.
% These describe SDR data-OFDM prototypes, not complete 802.11 PHY frames.
if nargin<1, profile = 'legacy64'; end
profile = validatestring(profile,{'legacy64','he1024'});
cfg = struct('profile',profile,'input_fs_hz',9750e3, ...
    'normalization','peak','bit_order','lsb','build_nonht_packet',false, ...
    'scrambler_seed',1,'wifi_idle_time_s',20e-6);
if strcmp(profile,'legacy64')
    layout = wlanNonHTOFDMInfo('NonHT-Data','CBW20');
    cfg.input_fft_length = 64;
    cfg.input_block_length = 64;
    cfg.output_fs_hz = 9750e3;
    cfg.qam_order = 64;
    cfg.target_tone_count = 14;
    cfg.output_data_slots = 7:20;
    cfg.filler_index = 27;
else
    layout = wlanHEOFDMInfo('HE-Data','CBW20',0.8);
    cfg.input_fft_length = 128;
    cfg.input_block_length = 136;
    cfg.output_fs_hz = 20e6;
    cfg.qam_order = 1024;
    cfg.target_tone_count = 28;
    cfg.output_data_slots = 47:74;
    cfg.filler_index = 341;
end
% Toolbox indices distinguish active-tone indices from full FFT indices.
cfg.output_fft_length = layout.FFTLength;
cfg.output_cp_length = layout.CPLength;
cfg.output_data_indices = layout.ActiveFFTIndices(layout.DataIndices);
cfg.output_pilot_indices = layout.ActiveFFTIndices(layout.PilotIndices);
cfg.output_guard_bands = [min(layout.ActiveFFTIndices)-1; ...
    layout.FFTLength-max(layout.ActiveFFTIndices)];
cfg.pilot_symbols = ones(numel(cfg.output_pilot_indices),1);
if strcmp(profile,'legacy64'), cfg.pilot_symbols(end) = -1; end
end
