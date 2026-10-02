# STM32 Source and Role Selection

The acquisition firmware is based on Chengdu Ebyte's
[SX128X embedded demo](https://www.ebyte.com/pdf-down/3342.html), cited as `online4`
in the paper. The original downloadable archive is named `20221121415107844.rar`.

Obtain the original package and open
`MDK-ARM/SX1280_L476RG_DemoApp.uvprojx` in Keil. In
`SMTC_App/main_ranging.c`, select the radio role using the existing define:

```c
#define DEMO_SETTING_ENTITY MASTER
```

Use `MASTER` for the ranging initiator and `SLAVE` for the responder. This
repository does not rewrite the STM32 program, modify power/calibration/timing
settings, or provide a new shared firmware implementation.

The experiment's local STM32 snapshots are preserved unchanged. The vendor
sources are not bundled in this public repository because some original headers
refer to a separate full license that is not supplied. Retain the ST/ARM/Semtech/
Ebyte notices and confirm applicable vendor redistribution terms before sharing
the original files. Citation and a download link do not replace those terms.

No new firmware build or board-level test is claimed by this release.
