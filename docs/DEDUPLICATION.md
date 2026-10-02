# MATLAB Consolidation

The preparation audit inspected the working source trees, revision copies,
dated backup, and the original RAR backup: 75 MATLAB files, 25 byte-identical
file groups and 24 groups with the same normalized code. Function-name matches
were inspected as candidates, not assumed to be identical implementations.
Original working files/backups are not deleted or changed.

| Previous Files / Functions | Canonical Module |
|---|---|
| `LoRaPHY`, `LoRaPHY2`, recorder subclass, repeated basic-chirp FFT code | `LoRanPHY`, `loran_extract_peaks` |
| `raging.mlx`, its export, repeated batch loops | `loran_process_dataset` |
| Spreadsheet scale/sign and revision peak-to-distance loops | `loran_estimate_from_peaks`, `loran_results_from_peaks` |
| Repeated IQ reader/writer examples | `loran_read_iq`, `loran_write_iq` |
| `getchunks.m`, `getchunks.mlx`, repeated reversal/packing loops | `loran_read_chunks`, `loran_chunks_to_bits`, `loran_bits_to_chunks` |
| Repeated FFT/QAM sections in `lora2wifi`, `lora2chunks`, OFDM draft | `loran_ctc_config`, `loran_ctc_project`, `loran_ctc_modulate` |
| `demapper`, `deinterleave`, `descreamble`, duplicated class methods | `loran_ctc_nonht_payload` with WLAN Toolbox |
| Custom Viterbi and incomplete `QAM2Payload` methods | WLAN coding engine; no dormant decoder stubs |
| Oversized OFDM plotting/demo script and `untitled`/debug tests | Focused library functions and deterministic unit tests |

`ranging.mlx` is an older aligned/payload-demodulation experiment, not an exact
copy of the batch-ranging script despite the similar spelling. Older archive
variants and single-capture variants are likewise distinguished. Their unused
packet/debug paths are not added back into the reviewed ranging pipeline.

The release ships one implementation per responsibility. Raw and cached ranging
share the same result builder, both CTC profiles share one projection/modulation
path, and both chunk orders share the same reversible codec. The firmware is
explicitly outside the refactoring scope; original sources are linked rather
than redistributed in this public repository.
