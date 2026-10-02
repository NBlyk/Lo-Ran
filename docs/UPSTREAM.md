# Source Provenance

## MATLAB

The basic chirp and folded-FFT algorithms derive from
[jkadbear/LoRaPHY](https://github.com/jkadbear/LoRaPHY), MIT, Copyright (C)
2020-2022 jkadbear. Its paper is Zhenqiang Xu, Pengjin Xie, Shuai Tong, Jiliang
Wang, *From Demodulation to Decoding: Towards Complete LoRa PHY Understanding and
Implementation*, ACM TOSN 2022, DOI `10.1145/3546869`.

The local research snapshot reports version 0.2.1, with an unknown original
commit. The modified ranging snapshot added Nz and capture-relative peak scans.
The integrated `matlab/src/LoRanPHY.m` retains only those required algorithms and
their copyright attribution. The original MIT license is included verbatim;
original file hashes are recorded in `upstream_files.json` for provenance.

The README organization follows the upstream project's prerequisites,
components, supported features, usage, and references structure. Its prose and
examples describe this implementation rather than duplicating the upstream text.

## STM32

The manuscript's bibliography entry `online4` identifies Chengdu Ebyte Electronic
Technology Co., Ltd., *[Embedded Demo Program] SX128X*,
<https://www.ebyte.com/pdf-down/3342.html>. The retrieved original archive is named
`20221121415107844.rar`. Local `ranging_master` and `ranging_slave` contain later
research modifications of this demo.

Firmware is outside the refactoring scope. The public repository links the
original source and documents the existing MASTER/SLAVE define. Local experiment
snapshots are unchanged and are not bundled here. No shared firmware, role/power
edits, pruning, or driver fixes are applied.

## CTC

The user-provided lora2wifi/lora2chunks, chunk conversion, decoder, and OFDM
notebooks contain local research prototypes. The consolidated MATLAB modules
retain their implemented operations, expose conflicting profile/timing choices,
and replace duplicated unfinished PHY helpers with calls to installed public
Communications/WLAN Toolbox APIs. No proprietary toolbox source is copied.

The files retain STMicroelectronics, ARM/CMSIS, and Semtech notices. Original
headers and the official download establish source provenance. They do not
replace the missing full license text for components whose headers only refer
to a separate license. See `LICENSE_REVIEW.md` before public redistribution.
