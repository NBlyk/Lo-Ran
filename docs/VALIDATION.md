# Validation Scope

Tested with MATLAB R2024a on October 2, 2026.

`run_loran_tests` uses runtime-generated inputs to check formula/sign/wrapping,
invalid inputs, chirp FFT bins, legacy/full end boundaries, candidate groups,
shared result construction, optional references, IQ IO, and raw batch processing.

`run_ctc_tests` checks both QAM profiles, LSB/MSB chunk roundtrips, all label values,
nearest-point equivalence, toolbox OFDM carrier/CP/pilot invariants, recovery of a
known valid WLAN payload, packet segmentation, and export/read-back.

The preparation also privately cross-checks historical results and actual IQ,
and executes both CTC profiles on the same request input used by the old script.
Those experiment inputs, selections, peaks, and outputs are not distributed.

Unit-generated chirps/bits are test stimuli, not experimental observations.
Software checks do not establish successful over-the-air LoRa activation,
WiRa header/CP mitigation, or a bidirectional CTC receiver. No new board test is
claimed. Original STM32 snapshots are unchanged and are not bundled here.
