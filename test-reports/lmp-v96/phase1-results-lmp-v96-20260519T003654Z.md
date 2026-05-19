# Phase 1 — happy-path OTA — lmp-v96 — PASS (all 4 boards)

Factory nxp-imx. All four boards flashed to target 10, registered on fio-test-plan,
auto-OTA'd 10 -> 13 on registration (verbatim lmp-device-register, daemon auto-start).

| Board / device | OTA | Active | OSTree (active / rollback) | upgrade_available · bootcount · bootupgrade_available · rollback | rbtest |
|---|---|---|---|---|---|
| imx8mm-evk-dev | 10->13 | 13 (5.0.13-13-96) | c752b0e2.. / 03b79ff6.. (5.0.11-10) | 0 · 0 · 0 · 0 | 0 |
| imx8mn-evk-dev | 10->13 | 13 (5.0.13-13-96) | 3a0f7aa6.. / bb0f8321.. (5.0.11-10) | 0 · 0 · 0 · 0 | 0 |
| imx8mp-evk-dev | 10->13 | 13 (5.0.13-13-96) | c8d00dd6.. / ce68706b.. (5.0.11-10) | 0 · 0 · 0 · 0 | 0 |
| imx8mq-evk-dev | 10->13 | 13 (5.0.13-13-96) | 7ab3be6b.. / 2e104332.. (5.0.11-10) | 0 · 0 · 0 · 0 | 0 |

All boards: aktualizr-lite "Active image is: 13"; two OSTree deployments (13 active,
10 as rollback); kernel_image2 staged (fallback present); confirmed healthy.
bootupgrade_available=0 -> OTA carried no firmware change, finalize-reboot not needed.
rbtest=0 -> target 13 predates the Phase-2 markers (clean baseline for Phase 3).
fiovb.bootfirmware_version: imx8mm 278e4837 · imx8mn fc2a1bab · imx8mp 6a093c52 · imx8mq 37edbb55.

Verdict: Phase 1 PASS, all four boards.
