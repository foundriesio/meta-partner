# FoundriesFactory LmP test record — imx8mm-evk

- **Factory:** nxp-imx · **Device:** imx8mm-evk-dev · **Date:** 2026-05-19
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
interface-test-imx8mm-evk.sh: **88 PASS / 4 FAIL / 20 INFO / 12 SKIP**

- **Detail:** [interface-test-results-imx8mm-evk-20260519T012140Z.md](interface-test-results-imx8mm-evk-20260519T012140Z.md)
- **Summary:** [interface-test-summary-imx8mm-evk-20260519T012140Z.md](interface-test-summary-imx8mm-evk-20260519T012140Z.md)

FAIL rows — all classified as **accepted caveats**, no genuine regressions:
- §1 `psplash-start.service` failed -> `systemctl is-system-running`=degraded: headless board has no `/dev/fb0`; `psplash` (fbdev) exits 255. Test-script limitation on headless HW, not an image defect.
- §18 weston not running: headless board has no display output for the compositor to bind.
  Classification: accepted caveat (headless bench configuration).

## Verdict
**PASS** — OTA, rollback, fixed-target recovery, compose-app enablement and the interface
sweep all validated end-to-end. No genuine regressions. Final validated target: **imx8mm-lpddr4-evk-lmp-20**.
