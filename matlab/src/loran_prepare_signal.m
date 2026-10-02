function signal = loran_prepare_signal(iq,cfg)
%LORAN_PREPARE_SIGNAL Validate IQ and apply research low-pass preprocessing.
% No clock/CFO calibration or inferred alignment is added to reproduction.
validateattributes(iq,{'numeric'},{'vector','finite','nonempty'});
signal = double(iq(:));
if cfg.apply_lowpass
    assert(exist('lowpass','file')==2,'LoRan:SignalToolbox', ...
        'Raw-IQ filtering requires Signal Processing Toolbox.');
    signal = lowpass(signal,cfg.bw_hz/2,cfg.fs_hz);
end
end
