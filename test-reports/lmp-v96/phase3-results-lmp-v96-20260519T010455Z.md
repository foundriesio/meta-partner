# Phase 3 — rollback — lmp-v96 — PASS (all 4 boards)

BROKEN_TARGET = 17 (panic recipe + rbtest markers). Revealed to all 4 boards; each
OTA'd to 17, kernel-panicked until bootlimit (3), and U-Boot rolled it back to target 13.

| Board / device | §3.4 on-device | §3.5 event feed |
|---|---|---|
| imx8mm-evk-dev | target 13, rollback=1, fiovb.bootcount=3, kernel no-rbtest | EcuInstallationCompleted->Failed! "Wrong version booted" |
| imx8mn-evk-dev | target 13, rollback=1, fiovb.bootcount=3, kernel no-rbtest | EcuInstallationCompleted->Failed! "Wrong version booted" |
| imx8mp-evk-dev | target 13, rollback=1, fiovb.bootcount=3, kernel no-rbtest | EcuInstallationCompleted->Failed! "Wrong version booted" |
| imx8mq-evk-dev | target 13, rollback=1, fiovb.bootcount=3, kernel no-rbtest | EcuInstallationCompleted->Failed! "Wrong version booted" |

All boards: upgrade_available=0, bootupgrade_available=0, OSTree active = the target-13
deployment. Rollback mechanism (bootlimit=3 -> fiovb.rollback=1 -> bootcmd_rollback) worked
on every board.

3.6 anti-thrash: 11 min watch -> VERDICT OK; all 4 held on target 13, exactly one
target-17 update session each (target 17 blacklisted by hash, no re-attempt).
See phase3-antithrash-lmp-v96-*.txt.

## Note — phase3-rollback-monitor.sh undercount (NOT a device fault)
The monitor marks a board "done" only after seeing >=3 panic lines in the serial log.
imx8mm/imx8mq: 3 panic lines captured -> done. imx8mn/imx8mp: only 2 of 3 panic lines
captured (a serial-capture gap -- no UART flow control, fast panic->watchdog-reset drops
a line), so the monitor stalled in "wait" although the boards had rolled back.
fiovb.bootcount=3 on all four is the authoritative proof all 3 failed boots occurred.
TODO (deferred): make the monitor cross-check on-device fiovb.bootcount; note in AGENTS.md.

Verdict: Phase 3 PASS, all four boards.
