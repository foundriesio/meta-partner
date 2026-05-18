# LmP device test-plan execution guide

Operating knowledge, conventions and hard-won gotchas for executing or editing the
FoundriesFactory LmP device test plans — `fio-test-plan-imx8mm-evk.md`,
`fio-test-plan-imx8mn-evk.md`, `fio-test-plan-imx8mp-evk.md` and
`fio-test-plan-imx8mq-evk.md`. They are
phase-structured (Phase 0 lab setup → Phase 6 interface sweep) and validate OTA (Phase 1),
rollback (Phases 2–3), compose-app enablement (Phase 5) and an interface regression sweep
(Phase 6). Read the relevant phase of the actual plan file before executing — this guide
only captures the cross-cutting knowledge the plans assume or that cost real debugging
time.

## 1. The reveal-tag workflow — the single most important concept

Devices are registered to follow the **`fio-test-plan`** tag, **not** `main`. A target is
invisible to the device until the operator appends `fio-test-plan` to it:

```bash
fioctl targets tag -f $FACTORY --append --tags fio-test-plan --by-version <N>
```

CI tags every build `main`; the operator-applied `fio-test-plan` tag is the deliberate
gate between phases. The device OTAs only to targets carrying `fio-test-plan`. This makes
progression operator-gated and the plan replayable without rebuilds.

**Gotcha — always tail the tag job.** Do NOT pass `--no-tail`. The tag op triggers a CI
metadata job that can hit a transient "in-transit" error: `fioctl` prints success + a CI
URL but the tag never lands. After tagging, **verify** with
`fioctl targets show -f $FACTORY <N>` that the `Tags:` line shows `fio-test-plan` before
assuming the device will move.

## 2. Device access

- **Register the device with the plan's `lmp-device-register` command exactly as written**
  — `lmp-device-register -n $DEVICE -t $TEST_TAG -f $FACTORY --apps ,`. Do **not** add
  `--start-daemon 0`: the default auto-starts aktualizr-lite, which is what a real operator
  gets, and the immediate happy-path OTA does **not** break journal/reboot monitoring (the
  watch is independent of when the OTA starts). Capture the §1.1 pre-OTA baseline right
  after the command returns — the OSTree pull leaves a comfortable multi-minute window.
  Worst case the pre-OTA state is still reconstructable: the old target survives as the
  ostree rollback deployment and the `EcuDownloadStarted` event records
  `Updating from <old-target>`. If a genuinely frozen snapshot is needed, a transient
  `systemctl stop`/`start aktualizr-lite` is a smaller, runtime-only deviation than
  altering the registration command.
- **Re-derive the device IP from its serial console before every SSH session.** Never
  reuse a cached IP — DHCP leases drift across the many reboots a test plan causes. Log in
  on the serial console (`fio`/`fio`) and run `ip -4 -o addr show end0`.
- SSH: `sshpass -p fio ssh -o StrictHostKeyChecking=no fio@$DEVICE_IP`. `sudo` needs a
  password — use `echo fio | sudo -S -p '' <cmd>`.
- The i.MX8M debug-UART bridge is **dual- or quad-UART depending on the board** — imx8mq-evk
  is a dual-UART CP2105; imx8mp-evk presents a **quad-UART** bridge. Either way, identify the
  **A53 Linux console** by its **USB interface number** (`ID_USB_INTERFACE_NUM` via
  `udevadm`), **not** a fixed `ttyUSB` index or "the second of the pair": the index drifts as
  boards are replugged. On imx8mq-evk the A53 console is interface `00` (on a recent run that
  was `ttyUSB0`, the *first* node); on a quad-UART board verify the interface per board.
  Confirm by sending a newline and reading the login banner. Run the session under
  `screen -L -Logfile <file>` so the log can be `grep`/`tail`-ed non-interactively.
- **`-sd` hostname suffix** (e.g. `imx8mm-lpddr4-evk-sd`) means the board booted from the
  **SD card**, not eMMC — a literal boot-source tag, not a build flavor. If you flashed
  eMMC and see `-sd`, the boot-mode switches are wrong.
- **imx8mp-evk boot mode is SW4** (verify on the silkscreen per board; don't trust
  training data): eMMC=`0010`, microSD=`0011`, SDP=`0001`.
- **imx8mq-evk boot mode is two switches** (verify on the silkscreen; don't trust training
  data): `SW802` — boot mode, 2-pole (internal boot vs serial downloader); `SW801` — boot
  device, 4-pole (eMMC vs microSD). See the imx8mq plan §0.1 for the bit patterns.
- **imx8mq-evk MACHINE is `imx8mq-evk`** (hyphenated). The un-hyphenated `imx8mqevk.conf`
  is a legacy hardknott-migration alias, not a different machine — don't treat it as one.

## 3. fioctl gotchas

- `fioctl` needs `-f $FACTORY` on every call (factory is `nxp-imx` for the imx plans);
  there is no default factory in `~/.config/fioctl.yaml`.
- There is **no `fioctl devices events`** subcommand. The event feed is under
  `fioctl devices updates $DEVICE` (lists update sessions) then
  `fioctl devices updates $DEVICE <update-id>` (granular events:
  `EcuDownloadCompleted`, `EcuInstallationApplied`, `EcuInstallationCompleted -> Failed!`).
- A target version appears in `fioctl targets list` as soon as its *first* machine build
  publishes — poll `fioctl targets show <N>` for the specific machine entries
  (`imx8mm-lpddr4-evk-lmp-<N>` / `imx8mp-lpddr4-evk-lmp-<N>`) before revealing.

## 4. Boot chain & firmware model

- **`imx-boot` is split.** LmP modifies the upstream single-blob layout: SPL+DDR-fw live in
  `imx-boot` (eMMC `bootloader` slots, AHAB/SRK-signed), and ATF(BL31)+OP-TEE+U-Boot-proper
  live in a *separate* fit-image (`bootloader2` slots, FIT-signed by a Factory key in SPL's
  devicetree). The two have different trust roots and update on different cadences.
- **Rootfs and firmware are kept in sync per target — they are NOT independent.** A target
  is a matched rootfs+firmware set; they roll forward and back together. They often *look*
  unchanged across a rollback only because firmware changes far less often than the
  kernel/rootfs.
- **`fiovb.*` vars in `fw_printenv` are a U-Boot-written mirror.** Under
  `rollback_mode = "uboot_masked"` (this Factory) aktualizr-lite manages the *plain*
  `upgrade_available` and never touches the `fiovb.*` namespace. Trust the plain
  `rollback` / `bootcount` / `upgrade_available` for OTA-confirm state; treat `fiovb.*` as
  a possibly-stale mirror (e.g. `fiovb.upgrade_available` can read `1` on a fully
  confirmed device).
- **`debug` u-boot variable.** `sudo fw_setenv debug 1` makes the FIT boot script print a
  `FIO: … Debug info …` block on every boot — the fiovb rollback state machine
  (`bootcount`, `rollback`, `is_secondary_boot`, …) plus OSTree/firmware offsets, straight
  on serial. Test plan §0.8 enables it; §6.4 sign-off disables it (`fw_setenv debug 0`).
- **A boot-firmware update is NOT finalized on the boot that applies it — it needs a
  follow-up reboot.** A firmware change (e.g. the Phase-2 markers) makes the OTA stage a
  new `imx-boot`/fit-image and set `bootupgrade_available=1`. Confirmed against the
  `u-boot-ostree-scr-fit` recipe: it assembles `boot.cmd` from `boot-header.cmd.in` + the
  per-machine boot.cmd + a boot-upgrade variant + `boot-footer.cmd.in`. **imx8mm uses
  `boot-upgrade-regular.cmd.in`** (`@@INCLUDE_COMMON@@` — validate the new images via the
  secondary slot, then warm-reset); **imx8mp uses `boot-upgrade-alternative.cmd.in`**
  (`@@INCLUDE_COMMON_ALTERNATIVE@@` — back up + update the primary slot directly, set
  `bootupgrade_primary_updated=1`, reboot). In **both** variants the boot that *applies*
  the firmware does not clear `bootupgrade_available`; it is cleared to `0` only by a
  later finalization block that runs on a **subsequent** boot, gated on
  `upgrade_available=0` — i.e. after aktualizr-lite has confirmed the OS update — which
  commits the validated images to the primary slot and resets.
- **Regular vs alternative — why two paths, and which board uses which.** *Regular*
  (imx8mm) is a true A/B update: the new firmware is written to a **secondary** slot and
  trial-booted from there, so the primary slot stays known-good until the new firmware is
  validated, then it is copied to the primary slot. *Alternative* (imx8mp) has **no
  secondary-slot trial**: it backs up the primary slot, overwrites it directly with the
  new firmware, and `restore_primary_image`s the backup if the update fails. The deciding
  factor is the **BootROM**: the imx8mm BootROM supports a temporary "boot the secondary
  slot" setting that persists across a **warm reset** (`reset -w`) — exactly what the
  regular A/B trial relies on. The imx8mp BootROM has no such mechanism, so it must use
  the backup/restore (alternative) path. The `debug`-block boot-image offsets corroborate
  this: imx8mm has distinct primary/secondary offsets (`0x42` / `0x1042`), imx8mp has none
  (`0x0` / `0x0`). Which path a board uses follows its SoC's BootROM — **trial-boot
  supported → regular**: imx6ul, imx6ull, imx6ulz, imx8mm, imx8mq; **no trial-boot →
  alternative**: imx8mn, imx8mp, imx8qm, imx93. (Verified against the BSP `boot.cmd`
  `@@INCLUDE_COMMON@@` / `@@INCLUDE_COMMON_ALTERNATIVE@@` markers — all nine imx machines
  in `meta-partner-nxp-imx` match.)
- **Therefore `bootupgrade_available=1` is EXPECTED right after a firmware-carrying OTA
  and is not a fault.** It persists until one more successful reboot (after the OS update
  is confirmed) runs the finalization and clears it to `0`. `bootupgrade_primary_updated`
  and `is_secondary_boot` indicate which stage of the multi-step commit a board is in.
  To settle it: reboot the device once more and re-check `bootupgrade_available` is `0`.
- **Inspecting firmware slots is board-layout-dependent.** On some boards (e.g. imx8mq-evk)
  the eMMC enumerates as `mmcblk0` (not `mmcblk2`) and there are **no
  `/dev/disk/by-partlabel/*` symlinks** — the plan's §0.7 named-slot fingerprinting
  (`bootloader`, `bootloader2`, …) then silently reads empty (`dd` of a missing path → the
  empty-input sha256 `e3b0c442…98fc1c14…`). Fall back to `fiovb.bootfirmware_version` plus
  a sha256 of the raw boot HW partition `/dev/mmcblk0boot0`.
- **The `uuu` first-flash log is unreadable** — it is pure ANSI cursor codes. Judge a flash
  by `uuu`'s exit code and the log's size, then by whether the board boots; don't try to
  parse the log.

## 5. Phase 2 recipe staging & Phase 4 revert

- Phase 2 adds two things to `meta-subscriber-overrides`, staged as **two separate
  commits**: (1) the `rollback-test` failure-injection (panic recipe), (2) the `rbtest`
  firmware/kernel markers. Keep them apart — Phase 4 reverts only commit (1).
- **Phase 4 reverts ONLY the failure-injection commit.** Do `git log --oneline` and
  `git revert --no-edit <failure-injection-sha>` — NOT `git revert HEAD`, which would also
  revert the markers. The markers are intentionally kept past Phase 4.
- imx plans target Factories whose CI builds `lmp-factory-image` — add `rollback-test` to
  `CORE_IMAGE_BASE_INSTALL` in `lmp-factory-image.bb`.
- Marker mechanisms (observability-only, version/ident-string knobs — no behaviour change):
  U-Boot `CONFIG_IDENT_STRING` (.cfg fragment) · TF-A `EXTRA_OEMAKE BUILD_STRING` ·
  OP-TEE `EXTRA_OEMAKE CFG_OPTEE_REVISION_EXTRA` · kernel `LINUX_VERSION_EXTENSION:append`.
  imx kernel recipe is `linux-lmp-fslc-imx`.
- When researching a BSP recipe (e.g. `imx-atf` in `meta-freescale`), clone the layer at
  the SHA pinned in `lmp-manifest` (`nxp-imx.xml`) — other local checkouts may differ.
- `lmp-manifest` SHA-bump commits: subject `<factory>: update <layer> layer to <sha>` +
  a "Relevant changes:" body; no `Co-Authored-By` trailer (Factory commit convention).

## 6. Tooling in the test-plan directory

- `phase3-rollback-monitor.sh` — watches the Phase 3 panic/rollback sequence on logged
  serial consoles; reports panic counts and exits when each board has rolled back.
  Usage: `./phase3-rollback-monitor.sh NAME=LOGFILE[:OFFSET] …`. Start it just before the
  Phase 2 reveal. Grep serial-log *files* directly by byte offset — never slurp a
  multi-hundred-KB log into a shell variable.

## 7. Where run artifacts go — `test-reports/`, never `test-plan/`

- `test-plan/` holds the **procedure only** — the four plans, the four
  `interface-test-<machine>-evk.sh` scripts, and `phase3-rollback-monitor.sh`. Do **not**
  write run output there; it buries the procedure.
- Completed-run evidence goes in **`test-reports/<lmp-release>/`** — keyed by the LmP
  release line (e.g. `test-reports/lmp-v96/`), artifacts kept **flat** (the machine name
  is already in every filename, so there is no per-machine subdirectory). One release
  folder accumulates: the §6.4 `test-record-<machine>-<datetime>.md` (the headline
  artifact), `interface-test-results-…md` / `interface-test-summary-…md`, the
  `phase{1,3,4,5}-result-…md` evidence, and the `baseline-…txt`.
- After a run, add one row to **`test-reports/README.md`** — the index (release × board →
  verdict, linking the test-record).
- Serial-console logs (`serial-*.log`) are **git-ignored** (layer `.gitignore`) — keep
  them locally as evidence; they are not committed.
