# Phase 4 — fixed-target forward update — lmp-v96 — PASS (all 4 boards)

FIXED_TARGET = 18 (reverts the panic recipe, keeps the rbtest markers). Revealed to all
4 boards; each OTA'd forward 13 -> 18, then the §4.3 finalize reboot committed the
firmware change.

| Board / device | OTA | Active (os-release) | uname | post-OTA bootupgrade_available | after finalize reboot |
|---|---|---|---|---|---|
| imx8mm-evk-dev | 13->18 | 5.0.13-18-96 | 6.6.52-lmp-standard-rbtest | 1 | 0 |
| imx8mn-evk-dev | 13->18 | 5.0.13-18-96 | 6.6.52-lmp-standard-rbtest | 1 | 0 |
| imx8mp-evk-dev | 13->18 | 5.0.13-18-96 | 6.6.52-lmp-standard-rbtest | 1 | 0 |
| imx8mq-evk-dev | 13->18 | 5.0.13-18-96 | 6.6.52-lmp-standard-rbtest | 1 | 0 |

All boards: aktualizr-lite "Active image is: 18"; upgrade_available=0, bootcount=0,
rollback=0; two OSTree deployments (18 active, 13 rollback). Target 18 carries a firmware
change -> bootupgrade_available=1 post-OTA -> finalize reboot -> bootupgrade_available=0
(committed). rbtest markers retained (Phase 4 reverts only the panic recipe).

Verdict: Phase 4 PASS, all four boards.
