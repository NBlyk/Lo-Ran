# Current Release Changes

## Scope

Only MATLAB code is consolidated/refactored. STM32 sources are restored to their
original snapshots; the earlier shared-firmware rewrite and its fixes are not
part of this public repository. Original experiment data and manuscript are unchanged.

## MATLAB

- Remove duplicated `.mlx`/`.m` exports, backup copies, the full unused LoRa
  payload stack, recorder inheritance, Excel side effects, and unfinished stubs.
- Preserve the ranging de-chirp/folding behavior and the corrected signed
  Nz/BW formula; reuse one estimator/result builder for raw and cached inputs.
- Require external caller-supplied annotations/data. Native/physical references
  are optional and never inferred or filled with invented values.
- Consolidate FFT/QAM projection, carrier mapping, OFDM, chunks, and payload
  operations for the legacy64 and HE1024 CTC prototypes.
- Use toolbox coding/OFDM engines; fix undefined draft variables, duplicated
  transforms, zero-/one-based chunk confusion, ten-bit truncation, inconsistent
  carrier lists, and illegal legacy packet length handling.
- Add module comments, external-input examples, and deterministic code-only tests.

No experimental dataset, cached peaks, coordinates, annotations, results,
Origin/Excel project, generated signal, or figure is packaged.
