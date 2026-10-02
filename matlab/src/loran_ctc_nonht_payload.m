function result = loran_ctc_nonht_payload(dataSymbols,psduBytes,scramblerSeed)
%LORAN_CTC_NONHT_PAYLOAD Project 48-tone 64-QAM targets through the WiFi coder.
% Consolidates demapper/deinterleave/depuncture/Viterbi/descramble prototypes.
% WLAN Toolbox owns PHY coding/puncturing, constellation labels, and headers.
% Arbitrary target QAM points may not be a valid codeword; report achieved bits.
if nargin<3, scramblerSeed = 1; end
validateattributes(dataSymbols,{'numeric'},{'2d','finite','nonempty','nrows',48});
validateattributes(scramblerSeed,{'numeric'},{'scalar','integer','>=',1,'<=',127});
nSymbols = size(dataSymbols,2); dataBitsPerSymbol = 216;
if nargin<2 || isempty(psduBytes)
    psduBytes = min(4095,floor((nSymbols*dataBitsPerSymbol-22)/8));
end
validateattributes(psduBytes,{'numeric'},{'scalar','integer','>=',1,'<=',4095});
requiredSymbols = ceil((16+8*psduBytes+6)/dataBitsPerSymbol);
assert(requiredSymbols==nSymbols,'LoRan:CTCPayloadLength', ...
    'PSDU length must give the same number of target OFDM symbols.');
llr = wlanConstellationDemap(dataSymbols(:),1,6);
deinterleaved = wlanBCCDeinterleave(llr,'Non-HT',288);
decoded = wlanBCCDecode(deinterleaved,3/4,'soft');
descrambled = wlanScramble(decoded,scramblerSeed);
payload = double(descrambled(17:16+8*psduBytes));
wifi = wlanNonHTConfig('MCS',7,'PSDULength',psduBytes);
waveform = wlanWaveformGenerator(payload,wifi,'ScramblerInitialization',scramblerSeed, ...
    'WindowTransitionTime',0);
indices = wlanFieldIndices(wifi);
dataField = waveform(indices.NonHTData(1):indices.NonHTData(2));
active = wlanNonHTOFDMDemodulate(dataField,'NonHT-Data',wifi);
info = wlanNonHTOFDMInfo('NonHT-Data',wifi);
achieved = active(info.DataIndices,:);
targetBits = wlanConstellationDemap(dataSymbols(:),0,6,'hard');
achievedBits = wlanConstellationDemap(achieved(:),0,6,'hard');
result = struct('payload_bits',payload,'wifi_waveform',waveform,'wifi_config',wifi, ...
    'data_symbols',achieved,'coded_bit_disagreement',mean(targetBits~=achievedBits), ...
    'sample_rate_hz',20e6,'scrambler_seed',scramblerSeed, ...
    'slave_activation_verified',false);
end
