# CTC Reconstruction Modules

The old notebooks combine several LoRa-to-QAM experiments with duplicated file
IO, FFT mapping, chunk-bit reversal, and unfinished decoder classes. The release
consolidates these into parameterized functions and uses Communications/WLAN
Toolbox for the OFDM and WiFi coding engines. Toolbox code is not redistributed.

## Profiles

| Parameter | `legacy64` | `he1024` |
|---|---:|---:|
| Input FFT samples | 64 | 128 |
| Input block samples | 64 | 136 |
| Selected target tones | 14 | 28 |
| QAM order | 64 | 1024 |
| Output FFT samples | 64 | 256 |
| Output CP samples | 16 | 16 |
| Output data carriers | 48 | 234 |
| Destination data slots | 7--20 | 47--74 |
| Input sample rate | 9,750,000 Hz | 9,750,000 Hz |
| Data-OFDM output rate | 9,750,000 Hz | 20,000,000 Hz |
| Chunk storage | uint8 | Little-endian uint16 |

These are prototype parameters consolidated from the old scripts, not a claim
that every draft describes a valid standard WiFi transmitter. Change rates and
mapping only with deployment evidence. Metadata explicitly records the
output/input duration ratio; CP insertion and the original mixed sample clocks
do not preserve duration automatically. No hidden resampling is performed.

WLAN Toolbox supplies correct active/data/pilot layouts. In particular, the HE
layout has 234 data and eight pilot carriers, with additional DC-null positions;
the old overlapping handwritten index lists are not retained.

## Data-OFDM Path

`loran_ctc_project` accepts request-only IQ, groups it, performs centered FFTs,
selects the configured tones, and maps to nearest unit-average-power QAM points.
`normalization='peak'` records the scale used; `'none'` supports direct unscaled
projection. QAM IDs are zero-based and unused data slots use the configured
filler ID. The nearest-point operation uses `qamdemod`/`qammod`.

`loran_ctc_modulate` uses `comm.OFDMModulator`, explicit CP/pilots, and null-tone
placement. Its output is the data OFDM waveform only: no WiFi preamble/header,
MAC frame, WiRa tagging, CP flipping, or verified LoRa-slave activation is implied.

`loran_ctc_export` writes generated float32 IQ, normalized HackRF signed-int8 IQ,
QAM indices/chunks, and metadata to a new caller-chosen directory. These generated
outputs are not included in the repository.

## Chunks and Payload Path

`loran_chunks_to_bits` and `loran_bits_to_chunks` are one reversible codec with
explicit LSB/MSB order, replacing conflicting string/reversal loops. `uint8`
cannot store 1024-QAM's ten-bit labels; that profile uses `uint16`.

For legacy 64-QAM targets, `loran_ctc_nonht_payload` uses WLAN constellation
demapping, BCC deinterleaving/decoding, scrambling/descrambling, and waveform
generation. It replaces the unfinished `QAM2Payload` and redundant hand-written
decoder paths. It accepts constellation points, so prototype QAM integer labels
are not mistaken for IEEE bit labels.

An arbitrary target constellation sequence may not be a valid WiFi codeword.
The generated packet therefore reports coded-bit disagreement instead of claiming
an exact inverse. The known-valid-codeword unit test recovers its payload exactly.

`loran_ctc_nonht_stream` splits long targets at the 4,095-byte legacy PSDU limit;
WiFi headers and configured inter-packet idle intervals remain visible overhead.
Its standard packet output runs at 20 MHz independently of prototype data-OFDM
rates. HE1024 does not implement inverse LDPC/full-HE packet construction.

This release includes the implemented request-reconstruction operations. It does
not add WiFi-chunk response ranging or claim a complete bidirectional CTC link.
