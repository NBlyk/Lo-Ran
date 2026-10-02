function result = loran_extract_peaks(iq,nz,cfg)
%LORAN_EXTRACT_PEAKS Filter a cropped capture and extract basic-chirp FFT peaks.
% Packet demodulation, payload decoding, and Excel writes are not needed here.
if nargin<3, cfg = loran_default_config(); end
phy = LoRanPHY(nz,cfg);
signal = loran_prepare_signal(iq,cfg);
result = phy.extract(signal,cfg);
end
