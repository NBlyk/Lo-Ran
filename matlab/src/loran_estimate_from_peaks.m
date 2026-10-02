function [distanceM, perChirpM] = loran_estimate_from_peaks(peakBins, masterWindows, slaveWindows, nz, cfg)
%LORAN_ESTIMATE_FROM_PEAKS Convert selected de-chirped peaks to a frame result.
% Window and FFT-bin indices are one-based. Selections must identify the master
% tail and slave response independently of the native reference distance.
validateattributes(nz, {'numeric'}, {'scalar','integer','positive'});
validateattributes(peakBins, {'numeric'}, {'vector','finite','integer','positive'});
validateattributes(masterWindows, {'numeric'}, {'vector','integer','positive'});
validateattributes(slaveWindows, {'numeric'}, {'vector','integer','positive'});
validateattributes(cfg.sf, {'numeric'}, {'scalar','integer','>=',5,'<=',12});
validateattributes(cfg.bw_hz, {'numeric'}, {'scalar','finite','positive'});
validateattributes(cfg.c_m_per_s, {'numeric'}, {'scalar','finite','positive'});
assert(numel(masterWindows) == numel(slaveWindows) && ~isempty(masterWindows), ...
    'LoRan:PairCount', 'Master and response windows must have equal nonzero length.');
assert(max([masterWindows(:); slaveWindows(:)]) <= numel(peakBins), ...
    'LoRan:WindowBounds', 'Selected window is outside the peak sequence.');
period = 2^cfg.sf * nz;
assert(all(peakBins <= period), 'LoRan:BinBounds', 'FFT bins exceed the folded grid.');
master = peakBins(masterWindows(:));
slave = peakBins(slaveWindows(:));
% Signed master-tail minus response shift; wrapping removes FFT-period aliases.
% SF cancels from c/(2*Nz*BW). Zero-padding refines the frequency grid; it does
% not increase ADC sampling rate or remove timing, CFO, and multipath biases.
delta = mod(master(:) - slave(:) + period/2, period) - period/2;
perChirpM = delta * cfg.c_m_per_s / (2 * nz * cfg.bw_hz);
% One response frame yields one raw result; signed/negative values are retained.
distanceM = mean(perChirpM);
end
