function result = loran_ctc_nonht_stream(dataSymbols,scramblerSeed,idleTime)
%LORAN_CTC_NONHT_STREAM Segment targets into legal-length legacy WiFi packets.
% Headers and inter-packet idle intervals are explicit; no CP/header mitigation
% or successful LoRa-slave activation is claimed by this software-only stage.
if nargin<2, scramblerSeed = 1; end
if nargin<3, idleTime = 20e-6; end
validateattributes(idleTime,{'numeric'},{'scalar','finite','nonnegative'});
validateattributes(dataSymbols,{'numeric'},{'2d','finite','nonempty','nrows',48});
maxSymbols = ceil((16+8*4095+6)/216);
packets = cell(ceil(size(dataSymbols,2)/maxSymbols),1);
segments = cell(size(packets)); ranges = zeros(numel(packets),2);
idle = zeros(round(idleTime*20e6),1); weightedMismatch = 0;
for k = 1:numel(packets)
    first = (k-1)*maxSymbols+1; last = min(k*maxSymbols,size(dataSymbols,2));
    payloadBytes = min(4095,floor(((last-first+1)*216-22)/8));
    packets{k} = loran_ctc_nonht_payload(dataSymbols(:,first:last),payloadBytes,scramblerSeed);
    segments{k} = packets{k}.wifi_waveform;
    if k<numel(packets), segments{k} = [segments{k};idle]; end
    ranges(k,:) = [first last];
    weightedMismatch = weightedMismatch+packets{k}.coded_bit_disagreement*(last-first+1);
end
result = struct('packets',{packets},'wifi_waveform',vertcat(segments{:}), ...
    'target_symbol_ranges',ranges,'packet_count',numel(packets),'sample_rate_hz',20e6, ...
    'idle_time_s',idleTime,'coded_bit_disagreement',weightedMismatch/size(dataSymbols,2), ...
    'slave_activation_verified',false);
end
