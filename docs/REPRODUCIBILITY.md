# Ranging Processing

## Shared Processing Chain

1. Read external little-endian float32 I,Q and reject incomplete/nonfinite pairs.
2. Apply the original low-pass preprocessing once per capture.
3. Analyze capture-relative basic-chirp windows without invented alignment.
4. De-chirp, zero-pad, FFT, fold the two spectrum ends, and record the peak bin.
5. Apply independently reviewed master-tail/response window pairs.
6. Wrap signed master-minus-response differences into the `2^SF*Nz` period and
   convert with `c/(2*Nz*BW)`; average within the same response frame.
7. Export per-chirp contributions and one raw result per frame.

`loran_results_from_peaks` is the single result builder for raw and cached inputs.
Native and physical references are optional and absent values remain NaN.
Negative raw distances are retained. No missing response or reference is filled
with a guessed value, and no IQ filename is treated as a UART response identifier.

## External Input Schemas

Selection JSON is an array of entries with these fields:

| Field | Meaning |
|---|---|
| `capture_id` | Unique caller-defined capture identifier |
| `relative_iq_file` | IQ path relative to the input root, for raw processing |
| `master_windows` | One-based indices for the request tail |
| `slave_windows` | Equally sized reviewed response-window indices |
| `native_result_m` | Optional independently paired native estimate |
| `physical_length_m` | Optional physical reference length |

Peak JSON entries contain `capture_id`, `nz`, and `peak_bins`.
`peak_amplitudes` may also be retained for inspection. There is no bundled
selection JSON, peak JSON, or example measurement file.

## Parameters and Boundaries

`loran_default_config` centralizes RF/SF/BW/fs/Nz. BW1600 is a radio label;
the paper's formula uses 1,625,000 Hz. `legacy_window_boundary=true` preserves
the old strict scan boundary; false includes the final complete window and
requires annotations checked against that numbering. The implementation requires
an integer number of samples per chirp and fs >= 2*BW for the retained folding.

Zero-padding refines the FFT grid. It does not increase the ADC sampling rate or
remove timing, CFO, and multipath biases. The correct Nz-dependent coefficient
is calculated, not entered as a hard-coded spreadsheet scale.

## Outputs and Timing

Raw processing creates frame/summary/chirp-pair CSVs and a MAT file with peaks,
configuration, and selections. Cached processing uses the same estimator and
exports the corresponding tables. Output directories must be new.

`loran_benchmark_latency` defaults to ten repetitions and one warmup per file/Nz.
Extraction excludes filtering, kernel setup, and IO; total DSP includes filtering,
setup, and extraction but excludes IO. These scopes are recorded separately and
are not asserted to equal historical timings from the old detector wrapper.

`loran_inspect_capture` and `loran_chirp_groups` provide inspection aids. Stable
peak runs are candidates, not automatic protocol labels. Select the request tail
and response from waveform/protocol evidence, not the resulting distance error.
