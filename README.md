# Lo-Ran

MATLAB source code for LoRa ranging-frame processing and LoRa-to-OFDM/QAM
reconstruction, with STM32 acquisition-source references and role instructions.

Associated paper: **Lo-Ran: Demystifying and Reconstructing the LoRa 2.4 GHz
Ranging Engine**, Yukai Lin, Chaojie Gu, Yin Song, Shibo He, and Jiming Chen.
Accepted by IEEE Transactions on Mobile Computing, September 26, 2026.

The ranging DSP is adapted from [LoRaPHY](https://github.com/jkadbear/LoRaPHY).
Firmware comes from Ebyte's [SX128X demo](https://www.ebyte.com/pdf-down/3342.html),
paper reference `online4`. Original component copyright notices are retained.

**Code only:** no experimental IQ, Origin/Excel projects, measurement coordinates,
peak sequences, chirp-window annotations, result tables, plots, or captured/
generated sample signals are distributed. Unit tests generate their inputs at
runtime. Processing functions accept data that the user supplies separately.

## Prerequisites

- MATLAB R2024a is tested.
- Ranging formula/FFT unit tests use base MATLAB. Raw-IQ filtering needs Signal
  Processing Toolbox.
- CTC needs Communications Toolbox and WLAN Toolbox. These remain external
  dependencies; no MathWorks implementation is copied into the repository.
- STM32: obtain the original Ebyte demo and use its Keil project. Firmware has
  not been rewritten; vendor sources are not redistributed in this repository.
- Python 3.10+ is optional for the source/data-exclusion audit.

## Components

| Module | Purpose |
|---|---|
| `LoRanPHY.m`, `loran_extract_peaks.m` | Basic-chirp reference, de-chirping, zero-padded folded FFT, peak extraction |
| `loran_read_iq.m`, `loran_write_iq.m` | Shared float32 IQ input and generated float32/HackRF int8 output |
| `loran_estimate_from_peaks.m` | Signed peak differences, Nz/BW conversion, averaging within a response |
| `loran_results_from_peaks.m` | One result-building path shared by raw-IQ and cached-peak processing |
| `loran_process_dataset.m`, `loran_process_peaks.m` | Process externally supplied IQ/peaks and reviewed window selections |
| `loran_inspect_capture.m`, `loran_chirp_groups.m` | Inspect candidate chirp groups before annotating a new capture |
| `loran_summarize.m`, `loran_plot_results.m` | Evaluate supplied native/physical references; missing references remain NaN |
| `loran_benchmark_latency.m` | Repeat extraction and total-DSP timing with explicit timing boundaries |
| `loran_ctc_config.m`, `loran_ctc_project.m` | Legacy64/HE1024 profiles, FFT tone selection, nearest-QAM projection |
| `loran_ctc_modulate.m`, `loran_ctc_export.m` | Data-OFDM synthesis, CP/pilots, generated IQ/chunk exports |
| `loran_chunks_to_bits.m`, `loran_bits_to_chunks.m`, `loran_read_chunks.m` | One explicit, reversible chunk/bit codec for both QAM orders |
| `loran_ctc_nonht_payload.m`, `loran_ctc_nonht_stream.m` | Library-backed BCC/payload projection and legal-length Non-HT packet generation |
| `firmware/README.md` | Original Ebyte source link and MASTER/SLAVE role selection |

MATLAB functions reside in `matlab/src`. Backup `.mlx` scripts, duplicate PHY
classes, incomplete decoder stubs, debug demonstrations, and captured outputs
are excluded. See [module consolidation](docs/DEDUPLICATION.md).

## Supported Features

- Offline ranging from cropped request/response exchanges.
- Configurable Nz, signed `wrap(master-response)*c/(2*Nz*BW)`, and per-frame means.
- Raw-IQ and cached-peak workflows using the same estimator and result builder.
- Optional native/physical references; no reference is inferred from filenames.
- 64-QAM and 1024-QAM reconstruction profiles consolidated from the old drafts.
- Zero-based QAM IDs and explicit LSB/MSB chunk order; 1024-QAM uses uint16 storage.
- Standard toolbox OFDM/FEC implementations instead of duplicated hand-written
  interleaver, puncturer, Viterbi, or scrambler implementations.
- Original STM32 role selection by `MASTER` / `SLAVE`, without source changes.

## Usage

From the `matlab` directory:

```matlab
setup_loran;
run_loran_tests();
run_ctc_tests();
```

These tests do not need the paper's experimental data.

### Ranging

```matlab
cfg = loran_default_config();
[frames, summary] = loran_process_dataset( ...
    '/path/to/your/iq', '/path/to/new/results', ...
    '/path/to/your/selections.json', cfg);
```

Each external selection supplies `capture_id`, `relative_iq_file`,
`master_windows`, and `slave_windows`. `native_result_m` and `physical_length_m`
are optional. Window indices are one-based and identify reviewed master-tail/
response pairs. IQ is little-endian float32 I,Q. Missing references stay NaN.

For already extracted peaks:

```matlab
[frames, summary] = loran_process_peaks( ...
    '/path/to/your/peaks.json', '/path/to/your/selections.json', ...
    '/path/to/new/results', cfg);
```

See [ranging workflow](docs/REPRODUCIBILITY.md) for data schemas and timing.

### CTC Reconstruction

```matlab
cfg = loran_ctc_config('legacy64');  % Or 'he1024'
result = loran_ctc_export('/path/to/request_only.cf32', ...
    '/path/to/new/ctc_results', cfg);
```

The input must contain the intended master request, not a full interaction with
the slave response. The output is an SDR data-OFDM reconstruction. To also
generate standard legacy WiFi packets from the 64-QAM targets:

```matlab
cfg.build_nonht_packet = true;
result = loran_ctc_export('/path/to/request_only.cf32', ...
    '/path/to/another/new/ctc_results', cfg);
```

Long targets are split into legal-length packets. Coding mismatch, header/idle
overhead, and input/output timing differences are recorded. HE1024 provides
data-OFDM reconstruction; it does not claim a complete HE LDPC payload inverse,
WiRa header/tag/CP mitigation, or verified slave activation. See
[CTC details](docs/CTC.md).

### STM32 Roles

Download and use the original Ebyte Keil project. In
`SMTC_App/main_ranging.c`, select the intended role:

```c
#define DEMO_SETTING_ENTITY MASTER  /* Ranging initiator */
/* Use SLAVE on the responder. */
```

No new shared firmware project, radio preset, driver fix, or firmware build is
delivered. Vendor files remain outside this public repository while their full
redistribution terms are being confirmed.
See [firmware instructions](firmware/README.md).

## Validation

Code-only tests cover ranging sign/wrapping/window handling, IO, both CTC
profiles, reversible chunk codecs, OFDM FFT/CP/pilot invariants, valid WLAN
payload inversion, packet segmentation, and generated exports. Separate private
checks use historical experiment files; those inputs and outputs are not part of
this release. No new radio/board test or over-the-air CTC result is claimed.

## References and Licensing

1. Lo-Ran, IEEE TMC, accepted 2026. [Citation metadata](CITATION.cff).
2. Zhenqiang Xu, Pengjin Xie, Shuai Tong, Jiliang Wang. *From Demodulation to
   Decoding: Towards Complete LoRa PHY Understanding and Implementation*.
   ACM TOSN, 2022. [DOI](https://doi.org/10.1145/3546869).
3. Chengdu Ebyte Electronic Technology Co., Ltd. *[Embedded Demo Program] SX128X*.
   [Source](https://www.ebyte.com/pdf-down/3342.html).

Original Lo-Ran additions and the LoRaPHY-derived MATLAB algorithms use MIT
terms. Vendor firmware is linked, not bundled; the root MIT license does not
relicense it. See [third-party notices](THIRD_PARTY_NOTICES.md).
