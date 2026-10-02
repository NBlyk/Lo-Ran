function cfg = loran_default_config()
%LORAN_DEFAULT_CONFIG Shared acquisition, analysis, and timing parameters.
% The radio's BW1600 label corresponds to 1.625 MHz in the distance conversion.
cfg = struct('rf_hz', 2430e6, 'sf', 8, 'bw_hz', 1625e3, ...
    'fs_hz', 9750e3, 'nz_values', [10 50 100 200 500], ...
    'c_m_per_s',299792458,'apply_lowpass',true,'legacy_window_boundary',true, ...
    'plot_nz',100,'latency_repeats',10,'latency_warmups',1);
% True preserves the original strict scan boundary and historical window IDs.
% False includes the final complete window; use with newly checked annotations.
end
