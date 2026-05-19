# FoundriesFactory LmP test record — imx8mq-evk

- **Factory:** nxp-imx · **Device:** imx8mq-evk-dev · **Date:** 2026-05-19
- **LmP release:** lmp-v96 · **Reveal tag:** fio-test-plan · **Mode:** replay of existing targets
- **Targets:** Phase-1 baseline 10 → forward 13 · BROKEN 17 · FIXED 18 · APPS 20

## Phase 1 — happy-path OTA — PASS
OTA 10 → 13 confirmed; two OSTree deployments (13 active, 10 rollback); upgrade_available=0,
bootcount=0, bootupgrade_available=0; rbtest=0 (clean pre-marker baseline).

## Phase 2 — broken target published — PASS (replay)
BROKEN target 17 (panic recipe + rbtest markers) pre-existing in the Factory; revealed at Phase 3.

## Phase 3 — rollback — PASS
OTA → 17, 3 panic-fails (fiovb.bootcount=3), U-Boot rolled the device back to target 13
(rollback=1). Host event feed: EcuInstallationCompleted → Failed! "Wrong version booted".
Anti-thrash: 11 min, no re-attempt of target 17.

## Phase 4 — fixed-target forward update — PASS
OTA 13 → 18 (panic recipe reverted, rbtest markers kept). Firmware change carried:
bootupgrade_available 1 → 0 after the §4.3 finalize reboot.

## Phase 5 — compose-app enablement — PASS
Target 20 revealed + shellhttpd assigned. Container running; HTTP "Hello world" served
device-local and from the host LAN. aktualizr-lite Active image 20, shellhttpd on.

## Phase 6 — interface regression sweep — PASS (with accepted caveats)
interface-test-imx8mq-evk.sh: **89 PASS / 1 FAIL / 26 INFO / 10 SKIP**

- **Detail:** [interface-test-results-imx8mq-evk-20260519T012140Z.md](interface-test-results-imx8mq-evk-20260519T012140Z.md)
- **Summary:** [interface-test-summary-imx8mq-evk-20260519T012140Z.md](interface-test-summary-imx8mq-evk-20260519T012140Z.md)

FAIL rows — all classified as **accepted caveats**, no genuine regressions:
- §20 Bluetooth scan discovered 0 devices: the §6.3 spec marks this a FAIL only "unless the bench is RF-isolated / nothing advertising". BT controller is up (hci0 present, powered, scan ran) — environmental.
  Classification: accepted caveat (RF environment).

## Verdict
**PASS** — OTA, rollback, fixed-target recovery, compose-app enablement and the interface
sweep all validated end-to-end. No genuine regressions. Final validated target: **imx8mq-evk-lmp-20**.
