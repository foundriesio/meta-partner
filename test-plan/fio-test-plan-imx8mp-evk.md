# Foundries.io device test plan

Factory: `nxp-imx` · Device: `imx8mp-evk-dev` · Target machine: `imx8mp-lpddr4-evk`

> ## i.MX 8M Plus EVK — board characteristics
>
> Key hardware facts this plan depends on:
>
> - **Display:** native HDMI — the i.MX 8M Plus has an on-SoC HDMI TX (DesignWare HDMI v2.13a,
>   `32fd8000.hdmi`), presenting a `card0-HDMI-A-1` DRM connector.
> - **Companion core:** Cortex-M7.
> - **NPU:** the 2.3-TOPS i.MX 8M Plus NPU. GPU is a Vivante GC7000UL.
> - **Memory:** the imx8mp-evk has 6 GiB LPDDR4 (~5,500,000 kB visible after firmware reservations).
> - **SDP USB ID:** `1fc9:013e` (also seen as `1fc9:0146` on EdgeLock-equipped variants) — SDPS,
>   single-stage `SDPS:` flow.
> - **Wi-Fi/BT:** an NXP 88W8xxx module — Wi-Fi via the `moal`/`mlan` driver (interface `wlp1s0`,
>   plus a `uap0` soft-AP), Bluetooth via `btnxpuart` over UART.
> - **uuu flash needs four artifacts** (wic, `imx-boot`, `u-boot-<machine>.itb`, mfgtools) — no
>   `sit.bin`; the fit-image offset is fuse-defined.
> - **Boot mode** is set via the `SW4` 4-position DIP switch — `0 0 1 0` eMMC, `0 0 1 1` microSD,
>   `0 0 0 1` USB-SDP (§0.1). The A53 console is on `/dev/ttyUSB2` (FT4232H debug bridge, §0.2).

## Goals

1. **Validate happy-path OTA** end-to-end on the `main` branch (aktualizr-lite pulls a fresh build, the device reboots into the new OSTree deployment, and the update is confirmed). Includes the `imx-boot` firmware container (TF-A + OP-TEE + U-Boot) being updated atomically via `fiovb` and `bootupgrade_available`.
2. **Validate the rollback mechanism** by pushing a deliberately broken update to `main`, watching three failed boots, and confirming U-Boot rolls the device back to the previous deployment under the same tag.
3. **Validate compose-app enablement** by enabling the `shellhttpd` example app from `containers.git`, assigning it to the device, and confirming aktualizr-lite pulls and runs it.
4. **Validate the device's interfaces** with a final regression sweep — confirm they still function after the OTA, rollback and compose-app phases (see Phase 6).

FoundriesFactory CI builds each branch of `lmp-manifest` (and `meta-subscriber-overrides`) and stamps every resulting target with the branch name as a tag (`main`). Devices only pull targets carrying one of *their* configured tags. **This plan does NOT register the device to follow `main`** — see the next section.

## Target reveal workflow (the `fio-test-plan` tag)

This plan uses a **two-tag model** so test progression is deterministic and the plan is replayable without rebuilding:

| Tag | Set by | Meaning |
|---|---|---|
| `main` | FoundriesFactory CI, automatically, on every build of the `main` branch | "this target was built from `main`" — a *build-provenance* tag |
| `fio-test-plan` | The operator, manually, via `fioctl targets tag` | "this target is **revealed** to the device under test" — a *test-control* tag |

**The device under test is registered to follow `fio-test-plan` only** (not `main`). Consequently:

- A target is **invisible** to the device until `fio-test-plan` is appended to it. CI can publish ten new `main` builds and the device won't budge.
- To advance the device to the next phase, the operator **reveals** the relevant target:
  ```bash
  fioctl targets tag -f $FACTORY --append --tags fio-test-plan --by-version <N> --no-tail
  ```
  On its next poll (`polling_sec`, default 300s) aktualizr-lite sees the newly-tagged target and OTAs to it.
- `--append` is essential — it adds `fio-test-plan` alongside `main` rather than replacing. Always dry-run first with `--dryrun`.

**Why this matters:**

1. **Deterministic progression.** The device never races ahead of the operator. Each phase's "wait for the device to OTA" step happens *because* you revealed the target, not because CI happened to finish a build.
2. **Replayable without rebuilds.** Targets persist in the Factory forever. To re-run this plan on a *second* device: remove `fio-test-plan` from every target after your chosen starting point (`fioctl targets tag --tags main --by-version <N>` — i.e. set tags back to just `main`), register the new device on `fio-test-plan`, and re-reveal targets one phase at a time. No CI builds are consumed — you are just re-pointing a tag at targets that already exist.
3. **Isolation.** Routine `main` development (other engineers pushing commits, nightly builds) does not perturb a test in progress.

Each phase below that generates a target has an explicit **"Reveal"** step. Treat the reveal as the deliberate gate between phases.

## Boot chain (imx8mp-evk, FoundriesFactory LmP)

FoundriesFactory's LmP distro **modifies the upstream NXP `imx-boot` layout**: instead of one AHAB container that holds SPL + ATF + OP-TEE + U-Boot, it splits the chain into two separately-signed pieces with two distinct trust roots.

| Stage | Artifact | Verified by | Trust root |
|---|---|---|---|
| 1. **BootROM** | (in-SoC ROM) | hardware | NXP-fused SRK hash (or development SRK on un-fused EVKs) |
| 2. **SPL** + DDR firmware | `imx-boot-<machine>` (e.g. `imx-boot-imx8mp-lpddr4-evk`); flashed by uuu into eMMC partitions `bootloader` (slot A) and `bootloader_s` (slot B) | BootROM (AHAB signature) | SRK fuses |
| 3. **fit-image** — ATF (BL31) + OP-TEE (BL32) + U-Boot proper (BL33) + boot script | published as a *separate* artifact `u-boot-<machine>.itb` (e.g. `u-boot-imx8mp-lpddr4-evk.itb`); flashed by uuu into eMMC partitions `bootloader2` (slot A) and `bootloader2_s` (slot B). Offset is fuse-defined on imx8mp — no `sit.bin` needed. | LmP-patched SPL via FIT signature check | **Factory-specific public key embedded in SPL's devicetree at build time** |
| 4. **Linux** | OSTree deployment | U-Boot (sha256 of boot script + signed kernel images per OSTree) | OSTree commit hashes |

The Factory-specific signing keypair lives in `lmp-manifest.git` (typically under `factory-keys/` or referenced from the `verified-boot` recipes). Each FoundriesFactory instance gets its own keypair at creation time; private signing key stays on the build server, public key is baked into SPL. This is why an SPL built for Factory A will refuse to load a fit-image signed by Factory B — even though both pass AHAB.

OTA for this stack:

- **`imx-boot` (SPL)** is rarely changed — it's pinned by AHAB to SRK fuses, and the public Factory key is in its devicetree, so changing it requires a rebuild of SPL that's still SRK-signable. When it does change (kernel/security updates that touch SPL), the OTA writes a new `imx-boot` to the eMMC boot partition's *staging* slot and `bootupgrade_available=1` tells the BootROM/SPL to try the new slot on next reset.
- **fit-image** is the part that changes routinely (any ATF / OP-TEE / U-Boot / boot-script update). It's also fiovb-managed with two slots so SPL can fall back if the new fit-image fails its signature check or the new U-Boot wedges.
- **`fiovb`** (Foundries.io versioned bootloader) is the slot-swap manager — sibling to `bootcount`/`upgrade_available` but for firmware. `bootupgrade_confirm` commits a staged firmware update once Linux signals health; if Linux never reaches that point and the BootROM/SPL detects the new slot is bad, the previous slot is reactivated on the next reset.

Implications for this plan:

- §1.5 verification has to look at *both* pieces (SPL via `imx-boot` slot, fit-image via fiovb slot) — they update on different cadences
- A "TA fails with `TEEC_ERROR_SECURITY`" symptom (origin `TEEC_ORIGIN_TRUSTED_APP`, raised when a user Trusted Application loads) is a **TA-signing key mismatch** — it has nothing to do with SPL. OP-TEE OS ships *inside the fit-image* (as BL32) and embeds the Factory's TA-signing public key; user TAs live in the rootfs and are signed with the matching private key. If the fit-image's OP-TEE OS and the rootfs's TAs come from different Factories (or a key rotation split them), the TA signature check fails. Core-only OP-TEE tests (e.g. `xtest regression_1001`) still pass — the failure is specific to the user-TA load path. Fix: re-flash a fit-image + rootfs matched as a set.
- This is distinct from the **SPL → fit-image FIT-signature check**: there, the Factory public key embedded in SPL's devicetree verifies the *whole fit-image*. A mismatch there means SPL refuses to load the fit-image at all (`Failed to verify required FIT signature`) — the device never reaches Linux, so you would never see a `TEEC_ERROR_SECURITY` from it.
- Recovery (R.4) must distinguish "wrong SRK" (BootROM-level, fuse problem, often unrecoverable) from "wrong Factory key" (re-flash a matching `imx-boot` + fit-image via uuu).

## Mechanism under test (rollback)

The OSTree-deployment vars are the standard LmP set; the **rollback-trigger mechanism** is the part that needs attention:

- `bootcount=0` — incremented by U-Boot each boot, cleared by `bootcount.service` after Linux reaches a healthy state
- `bootlimit=3`
- `upgrade_available=0` — set by aktualizr-lite once it confirms the new deployment is healthy (also mirrored as `fiovb.upgrade_available`)
- `rollback=0` initially; set to `1` on first successful boot of a new deployment (also mirrored as `fiovb.rollback`)
- `kernel_image=/boot/ostree/lmp-<hash>/vmlinuz-…` — the active kernel; `kernel_image2` only appears once a second OSTree deployment is staged (post-OTA, pre-confirm)
- `bootupgrade_available=0`, `bootupgrade_primary_updated=0` — firmware-slot flags (mirrored in `fiovb.*` namespace)
- **`altbootcmd` is absent on this build.** The fall-back to the secondary deployment is decided inline by `bootcmd_rollback`:

  ```
  bootcmd_rollback=if test -n "${kernel_image2}" \
                   && test "${fiovb.is_secondary_boot}" = "0" \
                   && test "${fiovb.rollback}" = "1"; then
                     setenv kernel_image "${kernel_image2}";
                     setenv bootdir "${bootdir2}";
                     setenv bootargs "${bootargs2}";
                   fi
  ```

  So the rollback trigger here is `fiovb.rollback=1` (set by the BSP boot chain when bootcount exceeds bootlimit), **not** an `altbootcmd` switcheroo. The visible behaviour is the expected one — three failed boots → next boot uses the previous deployment — and the test plan's checks key off `fiovb.rollback`.

- The `fiovb.*` namespace contains 9 vars. The userspace `fiovb_printenv` tool **is not shipped on this build** — query via `fw_printenv | grep ^fiovb\.` instead.
- A boot is "failed" if the kernel/userspace doesn't reach the bootcount reset (kernel panic, hung init, forced reboot before reset).

## Conventions used in this plan

**When Claude executes this plan, it should call `AskUserQuestion` at the start to collect all variables below** rather than hardcoding values. Suggested defaults reflect a typical lab bench but the plan should work for any Factory whose i.MX 8M Plus EVK target uses the `imx8mp-lpddr4-evk` MACHINE.

| Variable | Suggested default | Notes |
|---|---|---|
| `$FACTORY` | `nxp-imx` | the Factory the device registers to |
| `$DEVICE` | `imx8mp-evk-dev` | a fresh device name; bump on re-runs (registration is one-shot) |
| `$BRANCH` | `main` | the git branch commits are pushed to; CI tags its builds with this name |
| `$TEST_TAG` | `fio-test-plan` | the **reveal tag** the device is registered to follow — see [Target reveal workflow](#target-reveal-workflow-the-fio-test-plan-tag). The device only OTAs to targets carrying this tag. |
| `$DEVICE_IP` | (DHCP lease, captured in §0) | the board's address on the lab LAN |
| `$SERIAL_DEV` | `/dev/ttyUSB2` | A53 debug UART; the imx8mp-evk's FT4232H enumerates four ttyUSB devices, ttyUSB2 is conventionally the A-core console (verify per board) |
| `$SERIAL_LOG` | `serial-$(date -u +%Y%m%dT%H%M%SZ).log` | append-only capture file used by `screen -L -Logfile` |

- All on-device commands assume `sshpass -p fio ssh -o StrictHostKeyChecking=no fio@$DEVICE_IP`
- All serial-only commands assume the host has a `screen $SERIAL_DEV 115200` session active **with logging enabled** (see Lab setup §0.3) so Claude can `tail -f $SERIAL_LOG` to read output non-interactively
- Host-side commands assume `fioctl` is logged in and pointed at `$FACTORY` (Claude can sanity-check via `grep access_token ~/.config/fioctl.yaml` before starting)

## Pre-conditions

- imx8mp-evk hardware on the bench, powered (5 V via barrel jack J302 or USB-C PD), Ethernet plugged into the lab LAN, debug USB-C cable to the host
- USB-C OTG cable available (for uuu flashing in §0)
- Boot-mode DIP switch SW4 positions known (see §0.1)
- Host packages installed: `uuu` (≥ 1.5), `screen`, `sshpass`, `fioctl`, `git`
- `fioctl` logged in, default factory `$FACTORY`
- Local clones of `lmp-manifest.git` and `meta-subscriber-overrides.git`, both checked out on `main`
- Device registered to follow the **`$TEST_TAG` reveal tag** (NOT `$BRANCH`), with **apps explicitly disabled**:
  ```bash
  lmp-device-register -n $DEVICE -t $TEST_TAG -f $FACTORY --apps ,
  ```
  - `-t $TEST_TAG` (`fio-test-plan`) — registers the device to follow the reveal tag, not `main`. This is what makes test progression operator-gated; see [Target reveal workflow](#target-reveal-workflow-the-fio-test-plan-tag). The device will OTA only to targets that have had `fio-test-plan` appended.
  - The trailing `,` (literal comma) on `--apps` is the `lmp-device-register` flag for "no apps" — apps will only run when Phase 5 explicitly assigns them. **Without `--apps ,`** the device runs *every* compose-app advertised by the active target — surprising Phase 5 because shellhttpd would start automatically the moment `APPS_TARGET` publishes, defeating the test.
  - `lmp-device-register` defaults to an interactive OAuth2 device flow (prints an `app.foundries.io/activate` URL + user code; requires a browser step). For unattended runs, pass `-T <api-token>` (create one at `https://app.foundries.io/settings/tokens/`) to skip the browser step. The tool needs a PTY for the OAuth flow — run it on a real console, or under `script -qfc "…"` if driving it over a non-interactive SSH channel.
  - **Before registering, decide your starting target.** The device boots whatever is on eMMC, then OTAs to the *newest* `fio-test-plan`-tagged target. Reveal exactly the target you want as the Phase 1 baseline (e.g. target 10) and ensure no *later* target carries `fio-test-plan` yet.

---

## Phase 0 — Lab setup (imx8mp-evk)

### 0.1 Boot-mode DIP switch (SW4) cheat sheet

The imx8mp-evk's SW4 is a 4-position DIP switch that selects the BootROM's primary boot device:

| SW4 [4 3 2 1] | Mode | When to use |
|---|---|---|
| `0 0 1 0` | eMMC (default for this plan) | all OTA / rollback / app phases — this is what target 9 etc. get flashed to |
| `0 0 0 1` | USB (SDP — Serial Download Protocol) | first-time provisioning (§0.4) and uuu recovery (Recovery section) |
| `0 0 1 1` | microSD (slot J401) | only if you are deliberately testing an SD-card boot variant — NOT the default for this plan |

Always power the board off before flipping SW4. Record the current setting before changing — restoring it is a per-test ritual.

**Diagnostic clue — hostname suffix:** if the booted system reports its hostname as `<machine>-sd` (e.g. `imx8mp-lpddr4-evk-sd`) instead of `<machine>` (e.g. `imx8mp-lpddr4-evk`), the board booted from SD, *not* eMMC. The `-sd` suffix is not a build-flavor naming convention — it's a literal indicator that the SD-card image is what loaded. If you just flashed eMMC and you're seeing `-sd` in the hostname or login banner, your SW4 is wrong: power off, set to `0 0 1 0` (eMMC, NOT `0 0 1 1` which is microSD), power on. (This bit me once; the `-sd` looked like an LmP build variant suffix until the version mismatch made the truth obvious.)

### 0.2 Cabling

| Cable | Board port | Host side | Purpose |
|---|---|---|---|
| USB-C debug | J901 (debug) | enumerates as 4× `/dev/ttyUSB[0-3]` (FT4232H) | A53 console on `ttyUSB2`; M4 console on `ttyUSB0` (verify per board rev) |
| USB-C OTG | J3 (USB-C OTG) | host USB-C/Type-A | uuu downloads in SDP mode |
| Ethernet | J9 (RJ-45) | lab switch | DHCP for `$DEVICE_IP` and SSH/OTA |
| Power | J302 (barrel) or USB-C PD | 5 V / 3 A | required even with USB-C OTG attached |

### 0.3 Open the serial console with logging

Pick a fresh log file per run so Phase 6 can keep the evidence:

```bash
cd /home/scottml/fio/DeviceFiles/lmp/d.nxp/lmp-v96-testing
SERIAL_LOG=serial-$(date -u +%Y%m%dT%H%M%SZ).log
screen -L -Logfile "$SERIAL_LOG" /dev/ttyUSB2 115200
# detach with Ctrl-A d  (do not Ctrl-C — that kills the screen session)
```

To consume output non-interactively from Claude or a script:

```bash
tail -f "$SERIAL_LOG"
```

To send a single line of input from outside the screen session (useful for breaking into U-Boot):

```bash
screen -S <session> -X stuff $'\n'        # any key, satisfies "Hit any key to stop autoboot"
screen -S <session> -X stuff $'printenv\n'
```

If `screen` exits but the log keeps having stale data, it's because another `screen`/`picocom` already owns the tty — `fuser /dev/ttyUSB2` to find it.

### 0.4 First-time flash via uuu / mfgtools

Skip this section if the EVK already has a working LmP image you intend to start from — continue at §0.5. The rest of Phase 0 (§0.5–§0.8) still applies.

Pull the manufacturing artifacts for a recent target on `$BRANCH`. Filenames *must* match exactly what the bundled `full_image.uuu` script references (relative paths from inside the mfgtool subdir):

```bash
TARGET=9                                  # whichever target you want to provision from
mkdir -p uuu-target$TARGET && cd uuu-target$TARGET

# Four separate artifacts — all required:
fioctl targets artifacts -f $FACTORY $TARGET \
  imx8mp-lpddr4-evk/lmp-factory-image-imx8mp-lpddr4-evk.wic.gz > lmp-factory-image-imx8mp-lpddr4-evk.wic.gz
fioctl targets artifacts -f $FACTORY $TARGET \
  imx8mp-lpddr4-evk/imx-boot-imx8mp-lpddr4-evk > imx-boot-imx8mp-lpddr4-evk
fioctl targets artifacts -f $FACTORY $TARGET \
  imx8mp-lpddr4-evk/u-boot-imx8mp-lpddr4-evk.itb > u-boot-imx8mp-lpddr4-evk.itb
fioctl targets artifacts -f $FACTORY $TARGET \
  imx8mp-lpddr4-evk-mfgtools/mfgtool-files-imx8mp-lpddr4-evk.tar.gz > mfgtool-files.tar.gz

tar xzf mfgtool-files.tar.gz              # creates mfgtool-files-imx8mp-lpddr4-evk/ with uuu, full_image.uuu, bundled mfgtool SPL/fit
# do NOT gunzip the wic — uuu's `flash -raw2sparse` reads .wic.gz directly
```

Two non-obvious things to know about these artifacts:

- **The wic is `lmp-factory-image-…`** — FoundriesFactory CI on i.MX targets publishes the factory-image variant (which includes Foundries-specific extras), not `lmp-base-console-image-…`. Adjust the artifact name if your Factory's CI publishes a different variant; check via `fioctl targets artifacts -f $FACTORY $TARGET | grep '^imx8mp-lpddr4-evk/' | grep wic`.
- **The `mfgtool-files` tarball is published under a *separate* build run** named `<machine>-mfgtools/`, *not* under the main machine path. So the mfg artifact path is `imx8mp-lpddr4-evk-mfgtools/mfgtool-files-imx8mp-lpddr4-evk.tar.gz` — note the `-mfgtools` suffix on the run name. uuu, `full_image.uuu`, the bootstrap mfgtool SPL (`imx-boot-mfgtool`), and a bootstrap fit-image (`u-boot-mfgtool.itb`) all live inside this tarball.

What `full_image.uuu` actually does:

```
SDPS: boot -f imx-boot-mfgtool                        # SDP-loads bundled mfgtool SPL + DDR fw
FB: ucmd setenv fastboot_dev mmc                      # then transitions to fastboot
FB: ucmd mmc dev ${emmc_dev} 1; mmc erase 0 0x2000    # clear eMMC boot partition 1
FB: flash -raw2sparse all ../lmp-factory-image-…wic.gz/*
FB: flash bootloader     ../imx-boot-imx8mp-lpddr4-evk      # SPL → eMMC "bootloader" partition (slot A)
FB: flash bootloader2    ../u-boot-imx8mp-lpddr4-evk.itb    # fit-image → "bootloader2" partition (slot A)
FB: flash bootloader_s   ../imx-boot-imx8mp-lpddr4-evk      # SPL → "bootloader_s" (slot B, redundant)
FB: flash bootloader2_s  ../u-boot-imx8mp-lpddr4-evk.itb    # fit-image → "bootloader2_s" (slot B)
# imx8mp note: no sit.bin needed, the fit-image offset is fuse-defined
FB: ucmd mmc partconf ${emmc_dev} ${emmc_ack} 1 0
FB: done
```

Maps directly to the boot architecture: SPL goes to `bootloader{,_s}`, fit-image goes to `bootloader2{,_s}`, two slots each so fiovb has somewhere to fall back to. There is **no `sit.bin`** on imx8mp — the SPL learns the fit-image's eMMC offset from the SoC fuses.

Power off → set SW4 to `0 0 0 1` (USB SDP) → power on → connect the USB-C OTG cable. Confirm the host sees the SDP device:

```bash
lsusb | grep -iE 'NXP|Freescale'
# Expected: "1fc9:013e Freescale i.MX8MP"
# Also seen on EdgeLock-Enclave-equipped variants: "1fc9:0146 NXP Semiconductors SE Blank …"
# The bundled mfgtool SPL knows how to handle both — the user's confirmation of the SoC matters more than this string.
```

Run uuu using the binary bundled in the tarball (do *not* use a system-installed uuu unless you've verified the version matches). **Invoke from the parent `uuu-target<N>/` directory, not from inside the mfgtool subdir** — the `.uuu` script's `../<artifact>` paths resolve relative to where you run uuu from, and you want them to land in the parent dir where you placed the four artifacts:

```bash
# from uuu-target<N>/:
mfgtool-files-imx8mp-lpddr4-evk/uuu mfgtool-files-imx8mp-lpddr4-evk/full_image.uuu \
  2>&1 | tee uuu-flash-$(date -u +%Y%m%dT%H%M%SZ).log
# ~2 min; SDP-boots mfgtool SPL → fastboot → flashes the four artifacts to eMMC.
# Pipe to `tee` because uuu's TUI uses ANSI cursor codes that get stripped when piped — without `tee`,
# uuu's progress bars don't survive the pipe and you can mistake a clean exit for a hang.
```

If you've installed udev rules so non-root users can access the SDP USB device (`uuu` ships sample rules under `mfgtools` on GitHub), no `sudo` is needed.

Power off → restore SW4 to `0 0 1 0` (eMMC) → power on → watch `$SERIAL_LOG`. Expect:

```
U-Boot SPL <version> (LmP build …)
... (SPL loads + verifies fit-image, sig check OK)
NOTICE:  BL31: <ATF version banner>
... (OP-TEE early init)
U-Boot 2024.04+fio+...                    # U-Boot proper, from the fit-image
... (OSTree boot script, sha256+, kernel load)
[kernel boot messages]
lmp login:                                # within ~30 s
```

If SPL prints a signature-verification failure here (e.g. `Failed to verify required FIT signature`, or just hangs after "Trying to boot from MMC") and you flashed `imx-boot` from this same Factory's target 1, suspect: the wic's fit-image is from a different Factory, or the wic was rebuilt against a different keypair than the SPL. See R.4.

### 0.5 Discover `$DEVICE_IP`

After login on the serial console (user `fio`, password `fio`):

```bash
fio@imx8mp-lpddr4-evk:~$ ip -4 addr show eth0 | awk '/inet /{print $2}' | cut -d/ -f1
192.168.1.42
```

Export on the host and confirm SSH:

```bash
DEVICE_IP=192.168.1.42
sshpass -p fio ssh -o StrictHostKeyChecking=no fio@$DEVICE_IP 'uname -a'
```

Set a static DHCP reservation on the lab router if the lease is short — losing the IP mid-test costs a serial-console scramble.

### 0.6 Disk-headroom note

No disk-overlay step is needed: the EVK's eMMC is large (at least 16 GB) and LmP's first-boot resize service auto-expands `/dev/mmcblk2p2` (or whichever is the rootfs partition for this MACHINE) to fill the partition. After §0.4, verify:

```bash
sshpass -p fio ssh fio@$DEVICE_IP 'df -h / /var /sysroot 2>/dev/null'
# expect rootfs ≥ 6 GiB free; if you see <2 GiB, the resize service didn't run
```

If it didn't run, reboot once and re-check. If still wrong, manually:

```bash
sudo bash -c 'echo ", +" | sfdisk -N 2 --no-reread --force /dev/mmcblk2'
sudo reboot
# after reboot:
sudo resize2fs /dev/mmcblk2p2
```

### 0.7 Verify the fit-image and SPL slots in eMMC

uuu's `full_image.uuu` writes the artifacts into named eMMC partitions on the boot hardware partition (HW partition 1, which the BootROM consults before HW partition 0 / user data). After §0.4 the layout is:

| eMMC partition (HW part 1) | Contents | Role |
|---|---|---|
| `bootloader`     | SPL + DDR fw (`imx-boot-imx8mp-lpddr4-evk`) | slot A — primary |
| `bootloader_s`   | identical copy | slot B — fallback for SPL |
| `bootloader2`    | fit-image (`u-boot-imx8mp-lpddr4-evk.itb`) | slot A — primary fit-image |
| `bootloader2_s`  | identical copy | slot B — fallback for fit-image |

(There is **no `sit.bin`** on imx8mp — the fit-image's eMMC offset is fuse-defined, so SPL knows where to read from without a separate index file.)

To inspect the slots from the running device:

```bash
# device — fiovb's view of which slot is active (no userspace fiovb_printenv on this build;
# the fiovb.* vars live inside u-boot env and are accessible via fw_printenv)
sudo fw_printenv | grep -E '^(fiovb\.|bootupgrade)'
# expected vars: fiovb.is_secondary_boot, fiovb.rollback, fiovb.bootcount,
#                fiovb.upgrade_available, fiovb.bootupgrade_available,
#                fiovb.bootfirmware_version, fiovb.debug, fiovb.rollback_protection,
#                fiovb.bootupgrade_primary_updated

# device — sha256 of each slot, so §1.5 can detect a swap by comparing
ls /dev/mmcblk2boot0 /dev/mmcblk2boot1 2>/dev/null      # raw HW boot partitions; uuu's named partitions live within boot0
# fastboot-named partition map (after first boot u-boot has populated it):
ls -l /dev/disk/by-partlabel/bootloader /dev/disk/by-partlabel/bootloader2 \
      /dev/disk/by-partlabel/bootloader_s /dev/disk/by-partlabel/bootloader2_s 2>/dev/null

# fingerprint each one — non-zero bytes only (partitions are larger than the artifacts)
for p in bootloader bootloader_s bootloader2 bootloader2_s; do
  printf '%-15s ' "$p"
  sudo dd if=/dev/disk/by-partlabel/$p bs=1M status=none 2>/dev/null | sha256sum | cut -d' ' -f1
done
```

Record the four sha256s, the value of `fiovb.is_secondary_boot`, and `fiovb.bootfirmware_version` as the **`GOOD_FIT`** baseline so §1.5 can confirm they changed across the OTA. Slot A and slot B start identical after the uuu flash; the first OTA is what creates the asymmetry.

The userspace tool `fiovb_printenv` is **not** shipped in current LmP builds for this Factory — the `fiovb.*` vars are exposed only via `fw_printenv`. If `fw_printenv | grep ^fiovb\.` returns nothing, that's a real anomaly worth investigating in `meta-lmp-bsp` / `meta-subscriber-overrides`.

### 0.8 Enable verbose boot logging (the `debug` u-boot variable)

LmP's FIT boot script (`boot-header.cmd.in`) checks a `debug` u-boot environment variable. With `debug=1` it prints a **`FIO:` "Debug info" block on every boot** — a dump of the fiovb rollback state machine plus the OSTree / boot-firmware layout. This is the cheapest way to watch the rollback state on the serial console during Phases 1–3 without SSHing in or interrupting boot, so enable it now, before Phase 1.

```bash
# device
sudo fw_setenv debug 1
sudo fw_printenv debug          # expect: debug=1
```

`debug` is mirrored to `fiovb.debug` by the boot script itself, so `fiovb.debug` flips to `1` on the *next* boot, not immediately. Reboot once and confirm the block appears on the serial console:

```
FIO: ################ Debug info ###############
FIO: State machine variables:
FIO: fiovb.is_secondary_boot = 0
FIO: fiovb.bootcount = 0
FIO: fiovb.rollback = 0
FIO: fiovb.rollback_protection = 0
FIO: fiovb.upgrade_available = 0
FIO: fiovb.bootupgrade_available = 0
FIO: fiovb.bootupgrade_primary_updated = 0
FIO: fiovb.bootfirmware_version = <md5>
FIO: Other variables:
FIO: ostree deploy usr = 0   /   ostree split boot = 0
FIO: ostree boot dir  = /boot/ostree/lmp-<bootcsum>/
FIO: ostree root path = /ostree/boot.<N>/lmp/<hash>/0
FIO: primary boot image offset / primary FIT offset
FIO: secondary boot image offset / secondary FIT offset
FIO: ###########################################
```

Leave `debug=1` set for the whole test run — the per-boot dump of `fiovb.bootcount` / `fiovb.rollback` / `fiovb.is_secondary_boot` makes the Phase 3 panic→rollback sequence directly observable on serial (watch `bootcount` climb 0→1→2→3 and `rollback` flip). Disable it afterwards with `sudo fw_setenv debug 0` if a quiet console is wanted for Phase 6 sign-off.

---

## Phase 1 — Validate happy-path OTA on `main`

**Purpose:** Prove the OTA pipeline is healthy end-to-end before we deliberately break it. If this phase fails, do not proceed to the rollback test — diagnose first.

### 1.1 Capture baseline

| # | On | Command | Record |
|---|----|---------|--------|
| 1.1.1 | host | `fioctl status -f $FACTORY` | overall factory state |
| 1.1.2 | host | `fioctl devices show $DEVICE -f $FACTORY` | current target (expect `imx8mp-lpddr4-evk-lmp-1`), tag (`main`), online state |
| 1.1.3 | host | `fioctl targets list -f $FACTORY` | what's published |
| 1.1.4 | device | `sudo aktualizr-lite status` | `Active image is: 1 sha256:…` |
| 1.1.5 | device | `sudo ostree admin status` | one deployment, hash matches above |
| 1.1.6 | device | `sudo fw_printenv \| grep -E '^(bootcount\|bootlimit\|upgrade_available\|bootupgrade_available\|bootupgrade_primary_updated\|rollback\|kernel_image)='` | `bootcount=0`, `bootlimit=3`, `upgrade_available=0`, `bootupgrade_available=0`, `bootupgrade_primary_updated=0`, `rollback=0` (initial; flips to `1` after first OTA), `kernel_image=/boot/ostree/lmp-…/vmlinuz-…` |
| 1.1.7 | device | `cat /var/sota/sota.toml \| grep -A2 '\[pacman\]'` | confirm `tags = "fio-test-plan"` (the reveal tag — NOT `main`) |
| 1.1.8 | device | `sudo fw_printenv \| grep ^fiovb\\.` | 9 vars expected: `fiovb.bootcount=0`, `fiovb.bootupgrade_available=0`, `fiovb.bootupgrade_primary_updated=0`, `fiovb.debug=0`, `fiovb.is_secondary_boot=0`, `fiovb.rollback=0`, `fiovb.rollback_protection=0`, `fiovb.upgrade_available=0`, `fiovb.bootfirmware_version=<md5>` |

Save the active OSTree hash from 1.1.5 as **`GOOD_HASH`** — needed later as the deployment U-Boot must roll back to. Save `fiovb.bootfirmware_version` and `fiovb.is_secondary_boot` from 1.1.8 as **`GOOD_FIT`** + active-slot baseline.

### 1.2 Trigger a build on `main`

Push any small change to `lmp-manifest:main` or `meta-subscriber-overrides:main` to kick off a new build:

```bash
cd /home/scottml/fio/DeviceFiles/lmp/d.nxp/lmp-v96-testing/meta-subscriber-overrides
git commit --allow-empty -m "trigger build for OTA happy-path test"
git push origin main
```

> If a suitable target already exists (e.g. target 10 from a prior manifest bump), you can **skip the build entirely** and go straight to the reveal step — that's the whole point of the reveal workflow. Only push a fresh commit if you actually need a *new* target.

### 1.3 Wait for build to publish, then **reveal** it

Poll until `fioctl targets list -f $FACTORY` shows the new version. Web UI: `https://app.foundries.io/factories/$FACTORY/targets/<n>/`.

The new target is tagged `main` by CI but is **invisible to the device** until revealed. Append the reveal tag:

```bash
# dry-run first — confirm it appends fio-test-plan and doesn't drop main
fioctl targets tag -f $FACTORY --append --tags $TEST_TAG --by-version <N> --dryrun
# apply
fioctl targets tag -f $FACTORY --append --tags $TEST_TAG --by-version <N> --no-tail
```

`fioctl targets tag` triggers a short CI metadata-update job; the new tag is live in the TUF metadata once that job finishes (~1-2 min). Verify with `fioctl targets show -f $FACTORY <N> | grep -A2 'Target: imx8mp-lpddr4-evk-lmp-<N>'` — the `Tags:` line should list both `main` and `fio-test-plan`.

### 1.4 Wait for the device to OTA automatically

The aktualizr-lite daemon polls every `polling_sec` (default 300 s). Track:

```bash
# host — every minute or so
fioctl devices list -f $FACTORY
```

Expected progression:
- Soon after the target is **revealed** (not when it was built — when `fio-test-plan` was appended): `UP-TO-DATE` flips to `false`
- Aktualizr-lite logs show TUF metadata refresh, OSTree pull, then a new fit-image staged into fiovb's inactive slot (and a new `imx-boot`/SPL staged via `bootupgrade_available` *only* if SPL changed in this build — usually not)
- `upgrade_available=1` set in `fw_env` just before reboot; `bootupgrade_available=1` only if SPL changed
- Device reboots (SSH session drops). Serial log shows: SPL banner → SPL verifies + loads new fit-image → BL31/ATF banner reflects new build → new U-Boot proper banner
- After reboot: SSH back in, device on the new target, `UP-TO-DATE=true`

Capture progress on-device:

```bash
sudo journalctl -u aktualizr-lite -f
```

And on the serial side:

```bash
tail -f $SERIAL_LOG
```

### 1.5 Verify the update was confirmed (rootfs + firmware)

| # | On | Command | Expected |
|---|----|---------|----------|
| 1.5.1 | host | `fioctl devices show $DEVICE` | current target = new version, `UP-TO-DATE=true` |
| 1.5.2 | device | `sudo aktualizr-lite status` | `Active image is: 2` (new version), no pending |
| 1.5.3 | device | `cat /etc/os-release \| grep VERSION` | new LmP version string |
| 1.5.4 | device | `sudo ostree admin status` | two deployments — `* lmp <new>.0` active, `lmp <old>.1` rollback target |
| 1.5.5 | device | `sudo fw_printenv \| grep -E '^(upgrade_available\|bootcount\|bootupgrade_available\|rollback\|kernel_image2?)='` | `upgrade_available=0`, `bootupgrade_available=0`, `bootcount=0`, `rollback=1` (set on first successful boot of a new deployment), `kernel_image=` new deployment, `kernel_image2=` previous deployment (this is the fall-back target) |
| 1.5.6 | device | `sudo fw_printenv \| grep ^fiovb\\.` | If SPL/fit-image changed in this OTA: `fiovb.is_secondary_boot` flipped, `fiovb.bootfirmware_version` differs from `GOOD_FIT`. If only OSTree changed (most OTAs): both unchanged from baseline. `fiovb.rollback=0` (set by BSP only when bootcount triggers rollback) |
| 1.5.7 | serial | `grep -aE 'U-Boot SPL 20\|BL31:\|OP-TEE version\|U-Boot 20\|Linux version' $SERIAL_LOG \| tail -20` | SPL, BL31, OP-TEE, U-Boot-proper and kernel banners reflect the new build (BL31/OP-TEE/U-Boot come *from the fit-image* — a stale banner means the fit-image swap didn't take). A Phase-1 (good) target predates the Phase-2 markers, so it carries **no `rbtest`**: `grep -c rbtest $SERIAL_LOG` is `0`. Record these clean banners as the unmarked firmware/kernel baseline for §3.x. |
| 1.5.8 | device | `sudo dd if=/dev/mmcblk2 bs=1k skip=32 count=2048 status=none \| md5sum` (or compare `imx-boot` slot — exact offset depends on this MACHINE; see §0.7) | hash either equals the old `imx-boot` (SPL didn't change this OTA — common, expected for most updates) **or** has changed *and* `bootupgrade_available=0` confirms it was committed |

Save the new OSTree hash as **`GOOD_HASH`**, the new fit-image slot as **`GOOD_SLOT`**, the new fit-image sha256 as **`GOOD_FIT`** (overwriting previous values — these are what the rollback will return to).

**Why two slot concepts (`imx-boot` vs fit-image):**

- `imx-boot` (SPL + Factory public key) almost never changes between OTAs — its public key has to keep matching whatever signed the fit-image. When LmP *does* roll a new SPL (Factory key rotation or kernel-side SPL fixes), the build pipeline rebuilds *both* in lockstep, the OTA stages both, and `bootupgrade_available` covers SPL while fiovb covers the fit-image. If only one of the two updates and the other doesn't, suspect a partial OTA — escalate, do not declare Phase 1 passed.
- The **fit-image** is what changes for routine ATF/OP-TEE/U-Boot updates. Its swap is what §1.5.6 is really checking.

If §1.5.6 shows the slot did *not* flip, the firmware update didn't take — see Recovery before continuing. Symptom: the old fit-image (ATF + OP-TEE + U-Boot) stays active while the rootfs has moved to the new target, leaving the two out of sync. If the OP-TEE OS in that stale fit-image carries a different TA-signing key than the new rootfs's TAs, user-TA loads fail with `TEEC_ERROR_SECURITY`.

**Finalize the boot-firmware update (only if firmware changed).** If §1.5.5 showed `bootupgrade_available=1`, this OTA carried a new `imx-boot`/fit-image that is *applied but not yet committed* — the boot script commits a firmware update only on a **follow-up reboot**, after aktualizr-lite has confirmed the OS update (`upgrade_available=0`, which §1.5.5 confirms). Reboot once to finalize, then re-check:

```bash
sshpass -p fio ssh fio@$DEVICE_IP 'sudo reboot'
# device comes back; re-derive $DEVICE_IP from the serial console (§0.5), then:
sshpass -p fio ssh fio@$DEVICE_IP 'sudo fw_printenv | grep "^bootupgrade_available="'   # expect: bootupgrade_available=0
```

The boot script runs the finalization automatically and may perform one extra internal reset of its own. If §1.5.5 already showed `bootupgrade_available=0`, this OTA didn't touch firmware — skip this step.

Phase 1 done — the firmware (SPL + fit-image) updates in-band via the OTA; the only operator action is the finalize reboot above, and only when the OTA carried a firmware change.

---

## Phase 2 — Push the failure-injection commit to `main`

**Purpose:** Publish a target that's guaranteed to panic before `bootcount.service` can run, so U-Boot's `bootlimit` mechanism is exercised.

### 2.1 Stage the change

**Failure injection** — recipe files to add in the local clone of `meta-subscriber-overrides` (the panic mechanism is platform-agnostic):

- `recipes-support/rollback-test/rollback-test.bb`
- `recipes-support/rollback-test/files/rollback-test.service`
- `recipes-samples/images/lmp-factory-image.bb` — add `rollback-test` to `CORE_IMAGE_BASE_INSTALL`

This plan targets FoundriesFactory instances whose CI builds `lmp-factory-image`, so adding `rollback-test` to `CORE_IMAGE_BASE_INSTALL` is sufficient — no `lmp-base-console-image.bbappend` is needed.

**Firmware/kernel markers** — bbappends that stamp an `rbtest` marker into each component's serial-console banner, so §1.5.7 and Phase 3 can watch the firmware and kernel roll forward and back in sync with the rootfs (see §3.3). Add these in the same `meta-subscriber-overrides` clone:

- `recipes-bsp/u-boot/u-boot-fio_%.bbappend` + `recipes-bsp/u-boot/u-boot-fio/rollback-test-marker.cfg` — U-Boot SPL + proper: `CONFIG_IDENT_STRING=" rbtest"`
- `recipes-bsp/imx-atf/imx-atf_%.bbappend` — TF-A (BL31): `EXTRA_OEMAKE += "BUILD_STRING=rbtest"`
- `recipes-security/optee/optee-os-fio_%.bbappend` — OP-TEE: `EXTRA_OEMAKE += "CFG_OPTEE_REVISION_EXTRA=+fio+rbtest"`
- `recipes-kernel/linux/linux-lmp-fslc-imx_%.bbappend` — kernel: `LINUX_VERSION_EXTENSION:append = "-rbtest"`

The markers are observability-only — they change version/ident strings, not behaviour — and use the supported config/make knobs of each recipe. They land on every build off `main` from here on; the Phase-1 (good) targets predate them and carry no `rbtest`. **The markers are kept past Phase 4** — Phase 4 reverts only the failure-injection commit, not these.

**Stage the two parts as two separate commits.** The failure injection and the markers are removed at different times (Phase 4 reverts only the failure-injection commit), so keeping them in separate commits makes that a clean single-commit revert:

```bash
cd /home/scottml/fio/DeviceFiles/lmp/d.nxp/lmp-v96-testing/meta-subscriber-overrides
git status

# Commit 1 — failure injection. This is the commit Phase 4 reverts.
git add recipes-support/ recipes-samples/
git diff --cached
git commit -m "TEST: deliberately panic early in boot to validate aktualizr-lite rollback"

# Commit 2 — firmware/kernel markers. Kept in place past Phase 4.
git add recipes-bsp/ recipes-security/ recipes-kernel/
git diff --cached
git commit -m "TEST: mark TF-A, OP-TEE, U-Boot and kernel for rollback observability"

git push origin main
```

### 2.2 `rollback-test.service` payload (recap)

```ini
[Unit]
Description=Deliberately panic to exercise OTA rollback (TEST ONLY)
DefaultDependencies=no
After=sysinit.target
Before=basic.target bootcount.service aktualizr-lite.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'echo "rollback-test: triggering kernel panic via sysrq" > /dev/kmsg; echo 1 > /proc/sys/kernel/sysrq; echo c > /proc/sysrq-trigger'

[Install]
WantedBy=sysinit.target
```

Critical orderings:
- `Before=bootcount.service` — counter never gets reset, so U-Boot's `bootlimit` mechanism fires
- `Before=aktualizr-lite.service` — `upgrade_available` is not cleared, signalling the boot was not confirmed
- `DefaultDependencies=no` + `After=sysinit.target` — runs as early as systemd will allow

### 2.3 Wait for the broken target to publish, then **reveal** it

Poll `fioctl targets list -f $FACTORY` until the new version appears. Note it as **`BROKEN_TARGET`**.

It is tagged `main` by CI but invisible to the device until revealed. This is the deliberate gate — reveal it only when you're ready to watch the rollback happen:

```bash
fioctl targets tag -f $FACTORY --append --tags $TEST_TAG --by-version $BROKEN_TARGET --dryrun
fioctl targets tag -f $FACTORY --append --tags $TEST_TAG --by-version $BROKEN_TARGET --no-tail
```

Once the metadata job finishes, the device's next poll picks up `BROKEN_TARGET` and Phase 3 begins.

---

## Phase 3 — Trigger and validate rollback

**Purpose:** Watch three failed boots, the U-Boot-driven rollback, and confirm aktualizr-lite and the Factory dashboard both recognize the failure.

### 3.1 Aktualizr-lite stages and reboots into the broken deployment

The daemon polls, finds `BROKEN_TARGET`, pulls OSTree, stages a new deployment, sets `upgrade_available=1` (and `bootupgrade_available=1` if `imx-boot` also changed), and reboots. Watch:

```bash
# host — terminal 1
tail -f /home/scottml/fio/DeviceFiles/lmp/d.nxp/lmp-v96-testing/$SERIAL_LOG

# host — terminal 2 (until SSH drops)
sshpass -p fio ssh fio@$DEVICE_IP 'sudo journalctl -u aktualizr-lite -f'
```

Expected serial events at this point: `aktualizr-lite-finalize`-style messages, then `systemd[1]: Reboot triggered`, then TF-A re-banner.

### 3.2 Three panic cycles

Each iteration in the serial log:

```
NOTICE:  BL31: Booting BL33
U-Boot 2024.04+fio+...
Hit any key to stop autoboot:  0
## Executing script at 50200000
sha256+
...
[    X.XXXXXX] rollback-test: triggering kernel panic via sysrq
[    X.XXXXXX] sysrq: Trigger a crash
[    X.XXXXXX] Kernel panic - not syncing: ...
[    X.XXXXXX] CPU: 0 PID: ...
... (stack trace)
... board resets ...
```

U-Boot increments `bootcount` from 0→1→2→3 across these three iterations. To watch from the host:

```bash
grep -anE 'bootcount|Bootlimit|panic|Booting BL33|rbtest' "$SERIAL_LOG" | tail -40
```

`BROKEN_TARGET` was built with the Phase-2 markers, so all three broken boots run the **marked** firmware and kernel. Confirm the forward firmware+kernel swap took — every component banner should carry `rbtest`:

```bash
# SPL, BL31, OP-TEE, U-Boot-proper and kernel banners — all should match
grep -aE 'U-Boot SPL 20|BL31:|OP-TEE version|U-Boot 20|Linux version' "$SERIAL_LOG" | grep rbtest | sort -u
```

Each cycle is ~15–20 s on the EVK (BootROM → SPL → ATF → U-Boot → panic → watchdog reset).

### 3.3 Fourth boot — U-Boot detects failure and rolls back

In the serial log on the fourth boot attempt (this build has no `altbootcmd` — the fall-back is the inline `bootcmd_rollback`):

```
Hit any key to stop autoboot:  0
... bootcount has hit bootlimit; the BSP has set fiovb.rollback=1 ...
... U-Boot runs bootcmd_otenv (loads kernel_image, kernel_image2 from /boot/loader/uEnv.txt) ...
... bootcmd_rollback fires: kernel_image2 is non-empty, fiovb.rollback==1, fiovb.is_secondary_boot==0 ...
... so bootcmd_rollback swaps kernel_image := kernel_image2, bootdir := bootdir2, bootargs := bootargs2 ...
... boots the previous OSTree deployment ...
[normal Linux boot, no panic, reaches login prompt]
```

The exact U-Boot console messages depend on the BSP's verbosity; the observable signal is "no panic" + login prompt + on-device confirmation that `kernel_image` now points at the previous deployment (§3.4).

This is the rollback. The device should come up healthy on `GOOD_HASH`.

**The rootfs and the firmware (`imx-boot` SPL + fit-image) belong to one target and are kept in sync — they roll forward together when the device OTAs to `BROKEN_TARGET`, and they roll back together here. They are *not* independent.**

- The rootfs/kernel rollback uses no `altbootcmd` (that var does not exist on this build). When bootcount exceeds bootlimit, the BSP boot chain sets `fiovb.rollback=1`, which causes `bootcmd_rollback` (run as part of every boot) to swap `kernel_image` for `kernel_image2` (the previous deployment) — see [Mechanism under test (rollback)](#mechanism-under-test-rollback) for the inline `bootcmd_rollback` script.
- The firmware reverts with it: a target's `imx-boot` / fit-image is part of the same rollout as its rootfs, so rolling back to `GOOD_HASH` restores `GOOD_HASH`'s firmware too. The post-rollback device runs the matched firmware + rootfs of one target — never a new-firmware/old-rootfs mix.
- **The firmware often *looks* unchanged across the rollback** — not because it is independent, but because `imx-boot` and the fit-image change far less often than the kernel and rootfs. If `BROKEN_TARGET` and `GOOD_HASH` were built from the same TF-A / OP-TEE / U-Boot / SPL, the firmware banners are byte-identical before and after and nothing appears to move, even though the firmware rolled back in lockstep with the rootfs. To make the swap observable, build `BROKEN_TARGET` with the firmware/kernel markers (Phase 2) and watch the `rbtest` marker appear on the forward OTA and disappear on the rollback.

### 3.4 On-device verification after rollback

SSH back in once the login prompt is up. Run:

| # | Command | Expected |
|---|---------|----------|
| 3.4.1 | `sudo fw_printenv \| grep -E '^(rollback\|bootcount\|upgrade_available\|bootupgrade_available\|kernel_image2?)='` | `rollback=1`, `upgrade_available=0`, `bootupgrade_available=0`, `bootcount=0` (after `bootcount.service` runs), `kernel_image` now points at the *previous* (good) deployment, `kernel_image2` points at what was previously `kernel_image` (the broken one). `bootupgrade_available=0` here because the rollback path's `rollback_setup` clears it — **no finalize reboot is needed after a rollback** (unlike §1.5 / §4.3). |
| 3.4.2 | `sudo aktualizr-lite status` | Active image = the pre-broken target; broken target version listed as failed/pending |
| 3.4.3 | `sudo journalctl -u aktualizr-lite \| grep -iE 'rollback\|failed\|did not boot'` | Aktualizr-lite logs detect that the currently-running deployment is not the one it expected; logs "Rollback to previous version" or similar |
| 3.4.4 | `sudo ostree admin status` | Active deployment = `GOOD_HASH`; the broken deployment may be present as `pending` or pruned |
| 3.4.5 | `cat /etc/os-release \| grep VERSION` | LmP version matches `GOOD_HASH`'s target, not `BROKEN_TARGET` |
| 3.4.6 | `sudo fw_printenv \| grep ^fiovb\\.` | The `fiovb.*` mirror. `fiovb.rollback=1`; `fiovb.bootfirmware_version` matches `GOOD_HASH`'s firmware — firmware reverted together with the rootfs (see §3.3). Treat the plain `rollback`/`bootcount` from §3.4.1 as authoritative; the `fiovb.*` env entries are a U-Boot-written mirror. |
| 3.4.7 | `uname -r` | `6.6.52-lmp-standard` with **no `-rbtest`** suffix — the kernel rolled back to the unmarked `GOOD_HASH`. (On the three broken boots it read `…-lmp-standard-rbtest`.) |
| 3.4.8 | `grep -aE 'U-Boot SPL 20\|BL31:\|OP-TEE version\|U-Boot 20\|Linux version' $SERIAL_LOG \| tail -6` | The 4th-boot (rolled-back) SPL / BL31 / OP-TEE / U-Boot / kernel banners carry **no `rbtest`**. `rbtest` present on boots 1–3 and gone on boot 4 is the visible proof firmware *and* kernel rolled back in sync with the rootfs (§3.3). |

### 3.5 Host-side verification

```bash
fioctl devices show $DEVICE -f $FACTORY

# fioctl has no `events` subcommand — the event feed lives under `updates`:
# 1) list update sessions and find the one for BROKEN_TARGET (note its ID)
fioctl devices updates $DEVICE -f $FACTORY
# 2) show the granular event feed for that update
fioctl devices updates $DEVICE <update-id> -f $FACTORY
```

Expected:
- Current target = the pre-broken target
- The `BROKEN_TARGET` update's event feed shows `EcuDownloadCompleted -> Succeed`, then `EcuInstallationApplied` ("Application successful, need reboot"), then `EcuInstallationCompleted -> Failed!` with detail `Wrong version booted` — the install applied but the post-reboot deployment did not stick, so the device returned to the good target

### 3.6 Anti-thrash check (do not loop on the broken target)

Wait two polling intervals (10 minutes with default `polling_sec=300`) and verify:
- `fioctl devices list` continues to show the device on the good target, not flapping back to `BROKEN_TARGET`
- Aktualizr-lite logs do not retry the broken target — it should be blacklisted by hash for this device

If the device DOES retry the broken target and rolls again, that's a bug in aktualizr-lite's failure-tracking. Capture the journal and stop the test.

---

## Phase 4 — Cleanup: revert the failure-injection on `main`

**Purpose:** Remove the broken commit so subsequent builds on `main` are healthy again, and let the device update forward off the broken-target lineage.

### 4.1 Revert the failure-injection commit

Revert **only** the §2.1 failure-injection commit (the `rollback-test` panic recipe). Leave the firmware/kernel marker commit in place — `FIXED_TARGET` stays instrumented with the `rbtest` markers.

```bash
cd /home/scottml/fio/DeviceFiles/lmp/d.nxp/lmp-v96-testing/meta-subscriber-overrides
git log --oneline                              # find the "deliberately panic" commit
git revert --no-edit <failure-injection-sha>   # NOT `git revert HEAD` — that would revert the markers
git push origin main
```

This triggers a fresh build on `main` (call it `FIXED_TARGET`) — healthy (no panic recipe), still carrying the `rbtest` markers.

### 4.2 Wait for `FIXED_TARGET` to publish, **reveal** it, and let the device take it

The device is on the previous good deployment (post-rollback) and aktualizr-lite has blacklisted `BROKEN_TARGET` by hash. `FIXED_TARGET` is a new, never-attempted version.

```bash
fioctl targets list -f $FACTORY                    # confirm FIXED_TARGET appeared
# reveal it to the device:
fioctl targets tag -f $FACTORY --append --tags $TEST_TAG --by-version $FIXED_TARGET --dryrun
fioctl targets tag -f $FACTORY --append --tags $TEST_TAG --by-version $FIXED_TARGET --no-tail
fioctl devices list -f $FACTORY                    # after the metadata job: watch UP-TO-DATE flip false → true
```

### 4.3 Final verification

```bash
fioctl devices show $DEVICE -f $FACTORY
sshpass -p fio ssh fio@$DEVICE_IP 'sudo aktualizr-lite status; cat /etc/os-release | grep VERSION'
sshpass -p fio ssh fio@$DEVICE_IP 'sudo fw_printenv | grep -E "upgrade_available|bootupgrade_available|bootcount"'
```

Expected:
- `STATUS=OK`, `UP-TO-DATE=true`, current target = `FIXED_TARGET` (which now carries both `main` and `fio-test-plan` tags)
- On-device LmP version matches `FIXED_TARGET`
- `upgrade_available=0`, `bootcount=0`

**Finalize the boot-firmware update.** `FIXED_TARGET` is built from `main` with the Phase-2 firmware/kernel markers still in place — Phase 4 reverts only the failure-injection commit (§4.1) — so its `imx-boot`/fit-image differ from the pre-test firmware and this OTA carried a firmware change. Expect **`bootupgrade_available=1`** in the check above: applied but not yet committed. The boot script commits it on a **follow-up reboot**, now that aktualizr-lite has confirmed the OS update (`upgrade_available=0`). Reboot once to finalize:

```bash
sshpass -p fio ssh fio@$DEVICE_IP 'sudo reboot'
# device comes back; re-derive $DEVICE_IP from the serial console (§0.5), then:
sshpass -p fio ssh fio@$DEVICE_IP 'sudo fw_printenv | grep "^bootupgrade_available="'   # expect: bootupgrade_available=0
```

The boot script runs the finalization automatically and may perform one extra internal reset of its own. `bootupgrade_available=0` after the reboot completes Phase 4.

---

## Phase 5 — Validate compose-app enablement (`shellhttpd`)

**Purpose:** Prove the second half of the Factory pipeline — `containers.git` → CI compose-app target → `fioctl devices config updates` → aktualizr-lite → `docker compose up` — works end-to-end. Run this *after* Phase 4 cleanup is complete and the device is healthy on a `FIXED_TARGET`.

### 5.1 Pre-conditions

- Phase 4 done: device on `FIXED_TARGET`, `STATUS=OK`, `UP-TO-DATE=true`, following the `fio-test-plan` reveal tag
- Docker daemon healthy on device: `sudo docker version` works, `sudo docker run --rm hello-world` succeeds
- `containers.git` not yet cloned locally

### 5.2 Clone the containers repo and inspect

```bash
cd /home/scottml/fio/DeviceFiles/lmp/d.nxp/lmp-v96-testing
git clone https://source.foundries.io/factories/$FACTORY/containers.git
cd containers
ls                                  # expect shellhttpd.disabled/ (CI ignores any *.disabled dir)
ls shellhttpd.disabled/             # expect docker-compose.yml, Dockerfile, httpd.sh, etc.
cat shellhttpd.disabled/docker-compose.yml
```

### 5.3 Enable shellhttpd in a new target

```bash
git mv shellhttpd.disabled shellhttpd
git status                          # confirm rename only
git commit -m "Enable shellhttpd compose app"
git push origin main
```

The push triggers a CI job that produces a new compose-app target whose metadata advertises `shellhttpd`.

### 5.4 Wait for the new target to publish, then **reveal** it

```bash
fioctl targets list -f $FACTORY     # find the new version; APPS column should mention shellhttpd
```

Note the new version as **`APPS_TARGET`**, then reveal it:

```bash
fioctl targets tag -f $FACTORY --append --tags $TEST_TAG --by-version $APPS_TARGET --dryrun
fioctl targets tag -f $FACTORY --append --tags $TEST_TAG --by-version $APPS_TARGET --no-tail
```

The device won't OTA to `APPS_TARGET` until it's both revealed *and* the app is assigned (§5.5) — two independent gates.

### 5.5 Assign the app to the device

This step is meaningful **because the device was registered with `--apps ,`** (see Pre-conditions). Without that, aktualizr-lite would have already pulled and started shellhttpd as soon as `APPS_TARGET` published.

```bash
fioctl devices config updates $DEVICE --apps shellhttpd -f $FACTORY
fioctl devices config updates $DEVICE -f $FACTORY    # no flags = print current config to verify
```

`--apps` accepts a comma-separated list (`shellhttpd,otherapp`); `,` clears apps to empty (no apps will run); `-` falls back to image preset apps in `/usr/lib/sota/conf.d/`.

### 5.6 Wait for aktualizr-lite to pull and start the app

The daemon polls (default 300 s), sees both the new target and the new device-side app config, pulls the compose project, runs `docker compose up`. Track:

```bash
# device
sudo journalctl -u aktualizr-lite -f
```

Expected log lines: TUF metadata refresh, target install for `APPS_TARGET`, compose pull, compose up.

### 5.7 On-device verification

| # | Command | Expected |
|---|---------|----------|
| 5.7.1 | `sudo docker ps` | a running `shellhttpd` container |
| 5.7.2 | `sudo docker compose -f /var/sota/compose-apps/shellhttpd/docker-compose.yml ps` | service `up` |
| 5.7.3 | `wget -qO- http://localhost:8080/` (busybox wget; no curl on this image) | shellhttpd's response payload |
| 5.7.4 | `sudo aktualizr-lite status` | active target = `APPS_TARGET`; apps section lists shellhttpd as installed |

### 5.8 Host-side verification (optional — exercise inbound networking)

The EVK is on the lab LAN at `$DEVICE_IP`, so shellhttpd is directly reachable:

```bash
wget -qO- http://$DEVICE_IP:8080/
```

If this fails, check:
- `sudo iptables -L -n` on the device (Docker may have added rules)
- The lab firewall isn't dropping inbound to that subnet

### 5.9 Factory dashboard verification

```bash
fioctl devices show $DEVICE -f $FACTORY
```

Expected: `APPS` column lists `shellhttpd` and shows running.

### 5.10 Cleanup (optional)

If you want to leave the Factory in a fresh state after the test:

```bash
fioctl devices config updates $DEVICE --apps , -f $FACTORY
cd .../containers
git mv shellhttpd shellhttpd.disabled
git commit -m "Disable shellhttpd after test"
git push origin main
```

Or simply leave shellhttpd enabled — it's harmless and useful as a smoke target for future device tests.

---

## Phase 6 — Final interface regression sweep

**Purpose:** Confirm that all the OTA + rollback + compose-app churn from Phases 1–5 hasn't broken any device-level interface that worked before. If it passes, the device is in a fully healthy post-test state and the LmP delta represented by the new manifest is empirically validated end-to-end.

### 6.1 Pre-conditions

- Phases 1–5 complete; device on the latest target (or whatever you intend to ship), `STATUS=OK`, `UP-TO-DATE=true`
- `interface-test-imx8mp-evk.sh` available in this same directory — the executable interface test (23 §-sections, numbered §0–§22)
- §1.5.6 confirmed the fit-image swap took (and §1.5.8 confirmed `imx-boot`/SPL is consistent — otherwise the OP-TEE / TA tests in §7 will give misleading results)

### 6.2 Run the interface test

`interface-test-imx8mp-evk.sh` is a self-contained device-side script — it runs all "always-on baseline" rows and skips destructive/optional ones (USB/SD with media, RTC persistence, memtester, WDT trigger, thermal-load).

> **This step produces TWO artifact files — generate BOTH before moving to §6.3.**
> Step 2 (the per-interface summary) is the one that gets forgotten — do not skip it.

**Step 1 — full results → `interface-test-results-imx8mp-<datetime>.md`.** Pipe the script to the device over SSH and capture its GitHub-flavored-markdown output (one table per §-section, plus the script's own PASS/FAIL/INFO/SKIP totals block):

```bash
TS=$(date -u +%Y%m%dT%H%M%SZ)
sshpass -p fio ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
  fio@$DEVICE_IP 'bash -s' < interface-test-imx8mp-evk.sh > interface-test-results-imx8mp-$TS.md
```

**Step 2 — high-level summary → `interface-test-summary-imx8mp-<datetime>.md`.** A one-row-per-§-section (per-interface) roll-up — the at-a-glance verdict view — derived from the Step-1 results. A section's verdict is FAIL if any of its rows FAILed, else PASS; the **Notes** column explains any FAIL by listing the failing check(s):

```bash
{
  printf '# Interface test — high-level summary by interface\n\n'
  printf '**Detail:** `interface-test-results-imx8mp-%s.md`\n\n' "$TS"
  printf '| Interface | Verdict | P / F / I / S | Notes |\n|---|---|---|---|\n'
  awk -F'|' '
    function trim(x) { gsub(/^[ \t]+|[ \t]+$/, "", x); return x }
    function emit() { if (h) printf "| %s | %s | %dP %dF %dI %dS | %s |\n", h, (f?"FAIL":"PASS"), p,f,i,s, notes }
    /^## §/       { emit(); h=substr($0,4); p=f=i=s=0; notes=""; next }
    /^## Summary/ { emit(); h=""; next }
    NF>=5         { v=trim($4)
                    if (v=="PASS") p++; else if (v=="INFO") i++; else if (v=="SKIP") s++;
                    else if (v=="FAIL") { f++; notes=(notes?notes"; ":"") trim($2) " → " trim($3) } }
    END           { emit() }
  ' interface-test-results-imx8mp-$TS.md
} > interface-test-summary-imx8mp-$TS.md
```

Both files stay in this directory. §6.4's test record cites the summary's headline verdict and keeps the full results file as supporting evidence.

### 6.3 Expected pass set

All rows — including the full xtest suite — should PASS. Any FAIL is either:

- A genuine regression worth investigating before shipping
- A spec drift (the test command no longer matches the new image's behavior; update the spec)
- A known issue documented as a "Known caveats" entry in the spec

Expected on this Factory's lmp-2-and-later baseline:

| Test | Expected | Source-of-truth |
|------|----------|-----------------|
| §0.x pre-flight | PASS | SSH + sudo work |
| §1.x system | PASS | kernel banner / OS release / no failed units / `swapon --show` lists `/dev/zram0` as a non-zero-size partition swap (LmP enables zram-backed swap by default via `zram-swap.service`); a `dmesg` scan — **no kernel oops / BUG / stall this boot** (PASS; FAIL on any hit), plus the kernel error-level line count as INFO |
| §2.x OSTree | PASS | two deployments after first OTA |
| §3.x Foundries OTA stack | PASS | aktualizr-lite + fioconfig running, secrets delivered |
| §4.x containers | PASS | docker daemon, hello-world end-to-end |
| §5.x networking | PASS | DNS + outbound HTTPS handshake |
| §6.x time sync | PASS | timedatectl reports synchronized |
| §7.1–7.5 OP-TEE basics + PKCS#11 TA file present | PASS | TEE devices, supplicant, patched-UUID TA installed |
| §7.6 full xtest suite | PASS | required — full OP-TEE regression suite, ~5 min, 0 failed |
| §8.x U-Boot env | PASS | boot partition (`/mnt/boot`, holds `uboot.env`) auto-mounted by systemd via the fstab `x-systemd.automount` entry — verified by the test, not script-mounted; then OSTree-aware boot vars, bootcount=0, upgrade_available=0, bootupgrade_available=0 |
| §9.x process tree | PASS | aktualizr-lite, fioconfig, tee-supplicant, dockerd, containerd |
| §10.x i.MX-specific | PASS | `fw_printenv \| grep ^fiovb\\.` returns the 9 expected vars; `cat /sys/devices/soc0/soc_id` matches `i.MX8MP`; CAAM RNG present at `/dev/hwrng`; a **conditional G2D 2D-engine check** exercises the dedicated 2D core (GC520L) by running a g2d sample tool when `libg2d` + the tool are present in the image — SKIP otherwise (the common case) |
| §11.x USB host (optional) | PASS for always-on baseline; rest skipped unless a device is plugged in | Always-on (no device needed): `lsusb` lists 2 root hubs (`1d6b:0002` USB-2.0 + `1d6b:0003` USB-3.0); `ls /sys/bus/usb/devices/` shows `usb1`+`usb2`. With a USB stick plugged into a USB-A host port: device enumerates within ~1s and mounts cleanly. |
| §12.x microSD slot + eMMC health | PASS for always-on baseline; rest skipped unless a card is inserted | Always-on (no card needed): `mmc1` host controller present in `/sys/class/mmc_host/`, dmesg shows `30b50000.mmc` initialized + `Got CD GPIO` (card-detect wired), no bound child / no `/dev/mmcblk1*`. With a microSD inserted: card enumerates within ~1s, `/dev/mmcblk1` appears, partitions mount cleanly. **eMMC health** (always-on baseline): detects the eMMC (the `mmcblk` whose sysfs `device/type`=MMC) → PASS; `pre_eol_info` → PASS at `0x01` Normal, FAIL at `0x02` Warning / `0x03` Urgent; `life_time` reported INFO — all read from sysfs, no `mmc-utils` in the image required. |
| §13.x RTC (optional) | PASS for always-on baseline; persistence + alarm checks skipped unless explicitly run | Always-on (no special hw): `/dev/rtc0` present, `/sys/class/rtc/rtc0/name = snvs_rtc 30370000.snvs:snvs-rtc-lp` (i.MX 8M Plus internal SNVS RTC), `hwclock --show` returns a parseable time matching system clock to within a second. **Expected baseline gotcha:** `/sys/class/rtc/rtc0/hctosys=0` and dmesg shows the boot RTC read returned epoch (1970-01-01) — this is normal on dev EVKs without the SNVS coin-cell battery installed; NTP brings the time back. Optional persistence test (cold-boot, see if RTC time survives) only PASSes if a battery is fitted. |
| §14.x memory | PASS for always-on baseline; stress test optional | Always-on (no extras): `MemTotal` ≥ 5,500,000 kB (6 GiB physical minus ~470 MiB of ATF/OP-TEE/firmware/CMA reservations), `CmaTotal` = 983,040 kB (the 960 MiB device-tree CMA pool), `MemAvailable / MemTotal` > 0.5 at idle, `SwapTotal` ≥ 5,000,000 kB (zram — see §1.x), no `out of memory` / `oom-kill` / `killed process` in dmesg this boot. Expected absences (don't false-FAIL): EDAC counters (i.MX 8M Plus uses non-ECC LPDDR4), `/proc/pressure/memory` (kernel may not have CONFIG_PSI). |
| §15.x QSPI/FlexSPI | NOT TESTED — expected-absence row | This build's devicetree leaves the i.MX 8M Plus FlexSPI controller (`30bb0000.spi`) disabled, so no NOR flash is visible to the kernel. Verdict is informational: the row documents what's *currently* off so a future build that enables FlexSPI causes a visible verdict flip (from "absent" to either PASS-with-MTD-checks or FAIL-controller-bound-but-no-chip). Until then, intentionally not exercised. |
| §16.x HW watchdog | PASS for always-on baseline; trigger test optional (destructive) | Always-on (no special hw): `/dev/watchdog0` present, `wdctl -O /dev/watchdog0` returns `IDENTITY="imx2+ watchdog" TIMEOUT="60"` (driver bound to `30280000.watchdog`, the i.MX 8M Plus internal WDT). systemd's `RebootWatchdogSec=60` means WDT is used as a *shutdown safety net*, but `RuntimeWatchdogUSec=0` — i.e. nothing kicks it during steady-state operation. Bootstatus flags all 0 (last reset was NOT WDT-induced). Optional trigger test resets the board on purpose. |
| §17.x temperature sensors | PASS for always-on baseline; load test optional | Always-on (no special hw): two TMU thermal zones present — `thermal_zone0=cpu-thermal`, `thermal_zone1=soc-thermal`, both `mode=enabled`. Each zone reads 15°C ≤ T ≤ 80°C at idle (lab-realistic range; specific value depends on ambient + workload). Trip points: passive=85°C, critical=95°C — verify these match expected device-tree values, since a too-low critical would cause spurious shutdowns. Both zones agree within ~10°C of each other (large divergence = a sensor regressed). One cooling device: `cooling_device0=cpufreq-cpu0` with `cur_state=0/2` at idle. Governor on both zones = `step_wise`. |
| §18.x Wayland / display | PASS on `lmp-wayland` builds; whole section N/A on plain `lmp` | **Only applies when DISTRO is `lmp-wayland`** (target 10 onward for this Factory). Always-on: `weston` service active + process running; `/dev/galcore` (Vivante GPU) present; `/dev/dri/card0` + `/dev/dri/renderD128` present; a **3D GPU render check** — `weston-simple-egl` is run against the live compositor for ~5 s under `timeout`, PASS if it creates an EGL/GLES context and renders without crashing (exercises the GPU end-to-end — catches a UMD/kernel-driver mismatch or GPU hang that the node-presence checks miss; SKIP if `weston-simple-egl` is absent from the image). `seatd` service is **optional/INFO** — Weston commonly uses the logind libseat backend instead, so `seatd` inactive is fine *provided* weston is active and DRI nodes exist. Display-attached checks (HDMI connector `connected`, negotiated mode, `fb0` size) are INFO unless a monitor is known to be plugged in. On a plain `lmp` build the entire row is N/A — `weston`/`galcore` absent is expected, not a failure. |
| §19.x Wi-Fi radio | PASS for always-on baseline + scan | Always-on: station interface `wlp1s0` (+ `uap0` soft-AP) present, NXP `moal`/`mlan` driver loaded, `wpa_supplicant` active, `nmcli radio` shows WIFI `enabled`. Scan check: bring `wlp1s0` up → `nmcli device wifi rescan` → expect **≥1 AP** visible (proves the radio tunes and receives). Both 2.4 GHz (ch 1-13) and 5 GHz (ch 32+) APs should appear if any exist on each band. `0` APs is a FAIL *unless* the bench is RF-isolated. Association → DHCP → traffic is the optional deeper test (needs AP credentials). |
| §20.x Bluetooth | PASS for always-on baseline + power-on/scan | Always-on: `hci0` controller present (`hciconfig`), `bluetooth.service` active + `bluetoothd` running, `hci0` not rfkill-blocked, `bluetoothctl show` enumerates the controller (manufacturer, HCI version, features) with **0 HCI errors**. Power-on/scan check: `bluetoothctl power on` → `Powered: yes` / `hci0 UP` → timed `scan on` → expect **≥1 device** discovered (proves the radio receives + decodes advertisements). `0` devices is a FAIL *unless* the bench is RF-isolated with nothing advertising. Driver is `btnxpuart` (NXP UART BT). Pairing/connect is the optional deeper test (needs a target device). |
| §21.x audio | PASS for the always-on baseline; tone playback skipped | ALSA is up with all on-board cards — `/proc/asound/cards` lists **4**: `imxaudioxcvr` (SPDIF/eARC transceiver), `wm8960audio` (the on-board WM8960 codec), `audiohdmi` (HDMI audio), `micfilaudio` (PDM mic). `aplay -l` / `arecord -l` enumerate playback + capture devices, and `/dev/snd` has the `controlC*` / `pcmC*` nodes. `sound-bt-sco` stays in deferred-probe — an **expected absence** on a bare EVK, reported INFO not FAIL. Actual tone playback needs a speaker / HDMI sink — skipped. |
| §22.x PCIe | PASS only with a fitted card; otherwise INFO — never FAIL | The i.MX 8M Plus has one PCIe Gen3 controller (DesignWare-based, driver `imx6q-pcie`). Always-on (no card): the script reports the `*.pcie` devicetree node, whether the host bridge bound, and the `/sys/bus/pci/devices` count — all **INFO**, since a PCIe link only comes up with an endpoint card fitted in the slot (a bare bench legitimately shows no link / "PHY link never came up"). It goes **PASS** only when an endpoint enumerates past the host bridge; the link+traffic test is **SKIP** (needs a card). |

### 6.4 Compile the test record and sign off

**Run results do not go in this plan file** — the plan stays a clean, reusable procedure. Record the run in a standalone **test-record artifact** instead.

Write `test-record-<machine>-<datetime>.md` in this directory — a markdown summary of the whole run:

- **Run header** — factory, device name, date; the target versions the run exercised (Phase-1 baseline, `BROKEN_TARGET`, `FIXED_TARGET`, `APPS_TARGET`).
- **Phases 1–5** — one section per phase, PASS/FAIL with the key evidence:
  - Phase 1 — happy-path OTA confirmed on the Phase-1 target (§1.5).
  - Phase 2 — `BROKEN_TARGET` published.
  - Phase 3 — rollback: panic-cycle count, U-Boot returned to `GOOD_HASH` (§3.4 / §3.5).
  - Phase 4 — `FIXED_TARGET`: device updated forward, boot-firmware finalized (§4.3).
  - Phase 5 — `shellhttpd` pulled and running (§5.7).
- **Phase 6** — interface-sweep PASS / FAIL / INFO / SKIP totals, then the detail and
  summary artifacts as a **markdown bullet list of links** — leave a blank line before the
  list so it is not soft-wrapped into the totals line. The Phase 6 section should read:
  - `**Detail:** [interface-test-results-<machine>-<datetime>.md](interface-test-results-<machine>-<datetime>.md)`
  - `**Summary:** [interface-test-summary-<machine>-<datetime>.md](interface-test-summary-<machine>-<datetime>.md)`
- **FAIL rows** — every FAIL classified as *regression* / *spec drift* / *accepted caveat*, with evidence. This run data belongs in the artifact, **not** in this plan.
- **Verdict** — overall pass/fail and the final validated target version.

Keep the `interface-test-results-<machine>-<datetime>.md` file and the run's `$SERIAL_LOG` alongside the artifact as supporting evidence.

**Sign-off:** if §6.2 passed the expected set with no genuine regressions, the run is complete. Then restore the device to a clean state — turn off the §0.8 verbose boot logging so the serial console is quiet for any future / production use:

```bash
sudo fw_setenv debug 0
sudo fw_printenv debug          # expect: debug=0
```

The change takes effect on the next boot, when the boot script stops mirroring `debug` into `fiovb.debug`.

### 6.5 Interface-test reference

The interface test exists as the executable **`interface-test-imx8mp-evk.sh`** (see §6.2) — 23
§-sections, numbered §0–§22, covering pre-flight, system, OSTree, the Foundries OTA stack, containers, networking,
time sync, OP-TEE, U-Boot env, the process tree, i.MX-specific surfaces, USB, microSD, RTC,
memory, QSPI, the watchdog, temperature, Wayland/display, Wi-Fi, Bluetooth, audio, and PCIe. The §6.3 table
above is the human-readable summary; the script is the authoritative, runnable form.

To extend or audit it, edit `interface-test-imx8mp-evk.sh` directly — each `header "§N …"` block
is one section, using the `row` / `P` / `F` / `I` / `S` helpers (PASS / FAIL / INFO / SKIP).

Destructive / optional checks the script intentionally **skips** (run by hand when investigating):
USB / microSD with media inserted, RTC alarm + cold-boot
persistence, `memtester` stress, the destructive watchdog trigger, the thermal-load smoke test.


## Recovery if the test misfires

In rough order of escalation:

### R.1 Break into U-Boot via serial (no SSH needed)

If the previous deployment is also broken or the device is wedged in U-Boot:

1. Power-cycle the board with the serial console attached and logging
2. As soon as TF-A banner appears, send a key over serial to abort autoboot:
   ```bash
   screen -S <session> -X stuff $'\n'
   ```
3. At the U-Boot prompt, force a good state and pin to the known-good deployment:
   ```
   setenv bootcount 0
   setenv upgrade_available 0
   setenv bootupgrade_available 0
   setenv rollback 1
   saveenv
   run bootcmd_rollbackenv
   run bootostree
   ```
4. If `bootostree` panics again, the rootfs is also corrupt — escalate to R.2

### R.2 Re-flash via uuu

If the rootfs is bad enough that no OSTree deployment boots cleanly:

1. Power off → set SW4 to `0 0 0 1` (USB SDP) → power on → connect USB-C OTG
2. Run uuu against the latest known-good `full_image.uuu` (re-fetch from `fioctl targets artifacts` if the local copy is stale)
3. Power off → restore SW4 to `0 0 1 0` (eMMC) → power on
4. Re-register the device with `lmp-device-register -n $DEVICE -t $TEST_TAG -f $FACTORY --apps ,` (the device's `sota.toml` was wiped)

### R.3 Fit-image-only recovery (most common firmware misfire)

If §1.5.6 shows the **fit-image** slot is wrong (`fiovb.is_secondary_boot` didn't flip, `fiovb.bootfirmware_version` still matches `GOOD_FIT`) but the rootfs is fine — i.e. SPL loaded the *old* fit-image so the device is running new userspace against old ATF/OP-TEE/U-Boot:

1. Boot to Linux (rootfs is OK; SPL fell back to the previous slot, which is signed and works)
2. Force aktualizr-lite to re-stage the fit-image:
   ```bash
   sudo fw_setenv bootupgrade_available 0
   sudo systemctl restart aktualizr-lite
   ```
3. If the daemon doesn't re-stage on its own (it considers the deployment already applied), force-update:
   ```bash
   sudo aktualizr-lite update --update-name <current-version>
   ```
4. After reboot, re-check §1.5.6 / §1.5.7 — both `fiovb.is_secondary_boot` and the BL31 banner must reflect the new build

### R.4 SPL signature failure ("wrong Factory key")

Symptom: SPL prints `Failed to verify required FIT signature` (or just hangs after `Trying to boot from MMC`) and never reaches the BL31 banner. The fit-image was built against a different Factory's keypair than the SPL embeds.

Common causes:
- You re-flashed `imx-boot` from Factory A but the wic still has Factory B's fit-image (or vice versa)
- The `lmp-manifest` keypair was rotated and an old SPL is still in eMMC against a new fit-image
- During first-flash, you mixed `imx-boot` from `fioctl targets artifacts -f $FACTORY_A` with a wic from `$FACTORY_B`

Fix: re-flash `imx-boot` and `image.wic` *as a matched pair from the same Factory and same target* via uuu (R.2). Both pieces must come from the same `fioctl targets artifacts` invocation against `$FACTORY`.

If you genuinely need to swap one Factory's SPL into another Factory's wic (e.g. testing a key-rotation flow), the build pipeline must produce a matched `imx-boot` for the source Factory's keypair — there is no on-device workaround.

### R.5 BootROM-level recovery (SRK fuses involved)

Out of scope for this plan. Symptom: BootROM rejects `imx-boot` *itself* (AHAB signature mismatch — pre-SPL, you won't see any U-Boot banner). On a fused part this means the SRK in the binary doesn't match the SRK hash in the chip's fuses; the EVK is likely bricked unless you have an unfused / development part. Engage the secure-boot owner before doing anything irreversible.

---

## Manual aktualizr-lite controls (useful while testing)

- Stop the daemon before manual commands: `sudo systemctl stop aktualizr-lite`
- List visible targets: `sudo aktualizr-lite list`
- Force an update to a specific target: `sudo aktualizr-lite update --update-name <version-or-name>`
- Two-phase install (controlled reboot timing): `sudo aktualizr-lite pull --update-name N` → `sudo aktualizr-lite install --update-name N` → `sudo reboot` → `sudo aktualizr-lite finalize`
- Roll back to previous successful target (experimental): `sudo aktualizr-lite rollback`
- Resume daemon: `sudo systemctl start aktualizr-lite`

Source/destination targets must share a tag.

---

## Replaying the plan on another device

Because targets persist in the Factory indefinitely and the device only advances when a target is *revealed*, the entire plan can be re-run on a fresh device **without consuming any CI builds** — you re-point the `fio-test-plan` tag at targets that already exist.

To reset and replay:

1. **Pick the baseline target** — the version the new device should start Phase 1 on (e.g. target 10).
2. **Un-reveal every later target.** For each target version *after* the baseline that currently carries `fio-test-plan`, set its tags back to just `main`:
   ```bash
   # inspect what's currently revealed
   for v in $(fioctl targets list -f $FACTORY | awk 'NR>2{print $1}'); do
     fioctl targets show -f $FACTORY $v 2>/dev/null \
       | grep -q fio-test-plan && echo "revealed: $v"
   done
   # un-reveal a target (replace --append semantics — this SETS tags, dropping fio-test-plan)
   fioctl targets tag -f $FACTORY --tags main --by-version <V> --dryrun
   fioctl targets tag -f $FACTORY --tags main --by-version <V> --no-tail
   ```
   Leave the baseline target revealed (it's the new device's Phase 1 starting point).
3. **Flash the new device** to the baseline target via uuu (§0.4) and **register it** on `$TEST_TAG` (Pre-conditions). Use a fresh `$DEVICE` name.
4. **Walk the phases.** Each phase's "Reveal" step now just re-appends `fio-test-plan` to the already-built target for that phase — no `git push`, no waiting for CI. The broken target, fixed target, and apps target from the first run are all still in the Factory; reveal them in order.

The only situation that needs a real rebuild is if you intend to test *different* content than the first run. For a pure replay, tagging is all it takes.

> Caveat: aktualizr-lite blacklists a failed target **by OSTree hash, per device**. A *new* device has no blacklist, so re-revealing the original `BROKEN_TARGET` will make the new device attempt-and-roll-back exactly as the first device did — which is what you want for a replay. The same device, however, will refuse to re-attempt a hash it already failed.

---

## Out of scope (suggest separate plans)

- AHAB SRK fuse programming — one-shot, irreversible, owned by the secure-boot lead
- Boot-firmware fiovb-driven rollback in isolation (this plan only covers it incidentally as part of OTA failure)
- Compose-app failure rollback (governed by `create_containers_before_reboot`)
- Network-loss-during-OTA partial-download recovery
- Catastrophic case: rollback target is also broken (recovery covered above as a manual escape, not as an automated path)
- M4 / Cortex-M7 co-processor firmware (loaded by U-Boot, separate update mechanism)

---

## References

- [Update Rollback — FoundriesFactory docs](https://docs.foundries.io/latest/reference-manual/ota/update-rollback.html)
- [aktualizr-lite reference (CLI)](https://docs.foundries.io/latest/reference-manual/ota/aktualizr-lite.html)
- [LmP Customization — meta-subscriber-overrides](https://docs.foundries.io/latest/user-guide/lmp-customization/lmp-customization.html)
- [NXP i.MX 8M Plus EVK board hardware user guide](https://www.nxp.com/products/iMX8MPLUS-EVK) — pinout, SW4 boot mode, J3/J901 connectors
- [uuu (Universal Update Utility) on GitHub](https://github.com/nxp-imx/mfgtools)
- Interface test: `interface-test-imx8mp-evk.sh` (the executable Phase 6 sweep — see §6.2)
