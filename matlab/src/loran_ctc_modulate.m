function [waveform,meta] = loran_ctc_modulate(dataSymbols,cfg)
%LORAN_CTC_MODULATE Build data OFDM with a proven modulator and explicit CP/pilots.
% This output has no WiFi header/preamble. Extra HE DC-null tones stay zero.
validateattributes(dataSymbols,{'numeric'},{'2d','finite','nonempty'});
assert(size(dataSymbols,1)==numel(cfg.output_data_indices),'LoRan:CTCDimensions', ...
    'Data-symbol rows do not match the configured carrier layout.');
n = cfg.output_fft_length; pilots = cfg.output_pilot_indices(:);
occupied = (cfg.output_guard_bands(1)+1:n-cfg.output_guard_bands(2)).';
engineData = setdiff(occupied,[n/2+1;pilots],'stable');
[available,positions] = ismember(cfg.output_data_indices(:),engineData);
assert(all(available),'LoRan:CTCLayout','Data overlaps a pilot/guard/DC tone.');
engineInput = zeros(numel(engineData),size(dataSymbols,2));
engineInput(positions,:) = dataSymbols;
modulator = comm.OFDMModulator('FFTLength',n, ...
    'NumGuardBandCarriers',cfg.output_guard_bands,'InsertDCNull',true, ...
    'PilotInputPort',true,'PilotCarrierIndices',pilots, ...
    'CyclicPrefixLength',cfg.output_cp_length,'NumSymbols',size(dataSymbols,2));
pilotValues = repmat(cfg.pilot_symbols(:),1,size(dataSymbols,2));
waveform = modulator(engineInput,pilotValues);
meta = struct('fft_length',n,'cp_length',cfg.output_cp_length, ...
    'sample_rate_hz',cfg.output_fs_hz,'symbol_count',size(dataSymbols,2), ...
    'data_fft_indices',cfg.output_data_indices,'pilot_fft_indices',pilots, ...
    'full_wifi_phy_frame',false,'slave_activation_verified',false);
end
