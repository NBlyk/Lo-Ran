classdef LoRanPHY
    %LORANPHY Ranging-only de-chirp and folded-FFT processing of cropped IQ.
    % Adapted from jkadbear/LoRaPHY, Copyright (C) 2020-2022 jkadbear, MIT.
    % Modulation/decoding/CRC are omitted: ranging only uses basic up-chirps.
    % See third_party/LoRaPHY/LICENSE and docs/UPSTREAM.md for attribution.
    properties (SetAccess = private)
        SampleCount       % Captured samples per basic chirp: fs*2^SF/BW.
        BinCount          % Period of the folded FFT grid: 2^SF*Nz.
        FFTLength         % Zero-padded FFT length: SampleCount*Nz.
        Downchirp         % Reference multiplied with each received up-chirp.
    end
    methods
        function self = LoRanPHY(nz, cfg)
            validateattributes(nz, {'numeric'}, {'scalar','integer','positive'});
            validateattributes(cfg.sf, {'numeric'}, {'scalar','integer','>=',5,'<=',12});
            validateattributes(cfg.fs_hz, {'numeric'}, {'scalar','finite','positive'});
            validateattributes(cfg.bw_hz, {'numeric'}, {'scalar','finite','positive'});
            samples = cfg.fs_hz * 2^cfg.sf / cfg.bw_hz;
            assert(abs(samples-round(samples)) < 1e-10, 'LoRan:SamplingGrid', ...
                'Choose fs and BW giving an integer number of samples per chirp.');
            assert(cfg.fs_hz >= 2*cfg.bw_hz, 'LoRan:FoldedGrid', ...
                'The preserved two-sided folding requires fs >= 2*BW.');
            self.SampleCount = round(samples);
            self.BinCount = 2^cfg.sf*nz;
            self.FFTLength = self.SampleCount*nz;
            % LoRaPHY basic down-chirp (h=0, CFO=0), without unused wrap segments.
            time = (0:self.SampleCount-1)/cfg.fs_hz;
            slope = -cfg.bw_hz/(2^cfg.sf/cfg.bw_hz);
            self.Downchirp = exp(1j*2*pi*(time.*(cfg.bw_hz/2+0.5*slope*time))).';
        end
        function [amplitude, bin] = dechirp(self, signal, startSample)
            % Folding and one-based bin IDs match the original research code.
            segment = signal(startSample:startSample+self.SampleCount-1);
            spectrum = fft(segment(:).*self.Downchirp,self.FFTLength);
            folded = abs(spectrum(1:self.BinCount))+ ...
                abs(spectrum(end-self.BinCount+1:end));
            [amplitude,bin] = max(folded);
        end
        function result = extract(self, signal, cfg)
            % Capture-relative windows are retained; no resampling or alignment.
            stop = numel(signal)-self.SampleCount-1;
            if ~cfg.legacy_window_boundary
                stop = numel(signal)-self.SampleCount+1;
            end
            starts = 1:self.SampleCount:stop;
            assert(~isempty(starts),'LoRan:NoPeaks','No complete analysis windows.');
            bins = zeros(1,numel(starts));
            amplitudes = zeros(size(bins));
            for k = 1:numel(starts)
                [amplitudes(k),bins(k)] = self.dechirp(signal,starts(k));
            end
            result = struct('peak_bins',bins,'peak_amplitudes',amplitudes, ...
                'window_start_samples',starts,'fft_length',self.FFTLength, ...
                'sample_count_per_chirp',self.SampleCount,'folded_bin_count',self.BinCount);
        end
    end
end
