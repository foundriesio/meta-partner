# Interface test results — imx8mp-evk on `nxp-imx`

- **Run:** `2026-05-19T01:27:26+00:00`
- **Device:** `imx8mp-lpddr4-evk-4696606e84ed1dd815291000dcd5159f` @ `192.168.101.159`
- **LmP version:** `5.0.13-18-96`
- **Kernel:** `6.6.52-lmp-standard-rbtest`
- **SW4:** `0010` (eMMC)
- **Note:** If the device is **not registered** with FoundriesFactory, aktualizr-lite + fioconfig are intentionally inactive (no `/var/sota/sql.db`) — expected pre-registration baseline, not a regression.
- **Skipped (optional / destructive):** §11/§12 with media inserted, §13 persistence/alarm, §14 memtester, §16 WDT trigger, §17 thermal-load.

## §0 Pre-flight

| Check | Result | Verdict |
|---|---|---|
| SSH login as `fio` | `whoami`=`fio` | PASS |
| sudo works | `6.6.52-lmp-standard-rbtest` | PASS |

## §1 System

| Check | Result | Verdict |
|---|---|---|
| Kernel | `6.6.52-lmp-standard-rbtest` | INFO |
| OS `VERSION_ID` | `5.0.13-18-96` | PASS |
| `systemctl is-system-running` | `degraded` | FAIL |
| Failed systemd units | `1`: psplash-start.service | FAIL |
| zram swap (`/dev/zram0`) | size=`5.4G` | PASS |
| zram compression | `lz4` | INFO |
| `dev-zram0.swap` unit | `active` | PASS |
| Kernel oops/BUG/stall scan (dmesg) | none this boot | PASS |
| Kernel error-level log lines (dmesg) | `11` err+ lines (INFO — trend across OTAs; some probe-defer noise is benign) | INFO |

## §2 OSTree

| Check | Result | Verdict |
|---|---|---|
| OSTree deployments | `2` (≥1; 2 after first OTA) | PASS |
| OSTree Version == `os-release` | `5.0.13-18-96` | PASS |
| Active OSTree hash | `lmp…` | INFO |

## §3 Foundries OTA stack

| Check | Result | Verdict |
|---|---|---|
| Device registered (`/var/sota/sql.db`) | present | PASS |
| `aktualizr-lite` service | `active` | PASS |
| `fioconfig` service | `active` | PASS |

## §4 Containers

| Check | Result | Verdict |
|---|---|---|
| Docker server version | `25.0.3` | PASS |
| `docker run hello-world` | ran cleanly | PASS |

## §5 Networking

| Check | Result | Verdict |
|---|---|---|
| `end0` link | `UP` | PASS |
| Outbound HTTPS (api.foundries.io) | HTTP `200` | PASS |

## §6 Time sync

| Check | Result | Verdict |
|---|---|---|
| Clock synchronized (NTP) | `yes` | PASS |
| NTP service active | `yes` | PASS |

## §7 OP-TEE / TEE

| Check | Result | Verdict |
|---|---|---|
| TEE devices | `/dev/tee0` + `/dev/teepriv0` | PASS |
| `tee-supplicant` process | running | PASS |
| `xtest regression_1001` | `3 subtests of which 0 failed` | PASS |
| Full `xtest` suite | `39326 subtests of which 0 failed 137 test cases of which 0 failed` | PASS |

## §8 U-Boot environment

| Check | Result | Verdict |
|---|---|---|
| Boot partition `/etc/fstab` automount entry | `x-systemd.automount` present for `/mnt/boot` | PASS |
| Boot automount unit (`var-rootdirs-mnt-boot.automount`) | `active` | PASS |
| Boot partition auto-mounts on access | `/mnt/boot/uboot.env` visible — systemd mounted it on demand | PASS |
| `fw_printenv` returns env | 136 vars | PASS |
| `bootcount` | `0` | PASS |
| `bootlimit` | `3` | PASS |
| `upgrade_available` | `0` | PASS |
| `bootupgrade_available` | `0` | PASS |
| `rollback` | `0` | PASS |
| `kernel_image` set | `/boot/ostree/lmp-0e1b9f6d0e049d2608d532d7ca66670f12c984b…` | PASS |
| `fiovb.*` namespace | `10` vars (≥9) | PASS |
| `fiovb.is_secondary_boot` | `0` (fiovb mirror — informational) | INFO |
| `fiovb.rollback` | `0` (fiovb mirror — informational) | INFO |
| `fiovb.bootupgrade_available` | `1` (fiovb mirror — informational) | INFO |

## §9 Process tree

| Check | Result | Verdict |
|---|---|---|
| `systemd` | running (pid=408) | PASS |
| `dockerd` | running (pid=802) | PASS |
| `containerd` | running (pid=655) | PASS |
| `NetworkManager` | running (pid=610) | PASS |
| `wpa_supplicant` | running (pid=637) | PASS |
| `tee-supplicant` | running (pid=547) | PASS |
| `aktualizr-lite` | running (pid=1120) | PASS |
| `fioconfig` | running (pid=664) | PASS |

## §10 i.MX-specific surfaces

| Check | Result | Verdict |
|---|---|---|
| `soc_id` | `i.MX8MP` | PASS |
| CAAM RNG (`/dev/hwrng`) | 8 bytes: `4617775c6e22cc9f` | PASS |
| VPU device nodes | ` /dev/mxc_hantro /dev/mxc_hantro_vc8000e` | PASS |
| Vivante GPU (`/dev/galcore`) | present | PASS |
| G2D 2D engine (GC520L) | `libg2d` present but no g2d sample tool to exercise it; not run | SKIP |

## §11 USB host (always-on baseline)

| Check | Result | Verdict |
|---|---|---|
| USB root hubs | `2` (≥2) | PASS |
| xHCI host controllers bound | `1` | PASS |
| USB OTG controller | `38100000.usb` | PASS |
| USB device-plugged-in checks | skipped (requires lab presence) | SKIP |

## §12 microSD slot (always-on baseline)

| Check | Result | Verdict |
|---|---|---|
| `mmc1` host controller | present | PASS |
| `mmc1` bound to `30b50000.mmc` | yes | PASS |
| Card-detect GPIO | wired (`Got CD GPIO`) | PASS |
| No microSD inserted (expected baseline) | no /dev/mmcblk1* | PASS |
| microSD-inserted checks | skipped (requires lab presence) | SKIP |
| eMMC boot device | `/dev/mmcblk2` (non-removable, `device/type`=MMC) | PASS |
| eMMC Pre-EOL health | `0x01` Normal | PASS |
| eMMC life-time estimate | `0x01 0x01` (typ A / typ B; 0x01=0-10% used … 0x0B=exceeded) | INFO |

## §13 RTC (always-on baseline)

| Check | Result | Verdict |
|---|---|---|
| `/dev/rtc0` | present | PASS |
| RTC driver | `snvs_rtc 30370000.snvs:snvs-rtc-lp` | PASS |
| `hwclock --show` | `2026-05-19 01:29:54.367739+00:00` | PASS |
| `hctosys` | `1` (0 expected without SNVS battery) | INFO |
| RTC alarm + persistence tests | skipped (optional) | SKIP |

## §14 Memory

| Check | Result | Verdict |
|---|---|---|
| `MemTotal` | `5748100` kB (≥5,500,000) | PASS |
| `CmaTotal` | `983040` kB | PASS |
| `MemAvailable/MemTotal` | `0.943` (>0.5) | PASS |
| OOM events (this boot) | 0 | PASS |
| `Dirty` pages | `52` kB (<100,000) | PASS |
| memtester stress test | skipped (optional) | SKIP |

## §15 QSPI/FlexSPI (documented absence)

| Check | Result | Verdict |
|---|---|---|
| SPI masters (only `spi1` ECSPI) | `spi1` | PASS |
| MTD devices (none expected) | `0` | PASS |

## §16 HW watchdog

| Check | Result | Verdict |
|---|---|---|
| `/dev/watchdog0` | present | PASS |
| WDT identity | `imx2+ watchdog` | PASS |
| WDT `TIMEOUT` | `60`s | PASS |
| WDT `*_BOOT` flags | all 0 (clean reset) | PASS |
| systemd `RebootWatchdogUSec` / `RuntimeWatchdogUSec` | `1min` / `0` | INFO |
| Destructive WDT trigger | skipped (would reboot) | SKIP |

## §17 Temperature sensors

| Check | Result | Verdict |
|---|---|---|
| Thermal zones | `2` | PASS |
| `thermal_zone0` (`cpu-thermal`) | `41.0°C` | INFO |
| `thermal_zone1` (`soc-thermal`) | `43.0°C` | INFO |
| `thermal_zone0` temp in 15-80°C | `41.0°C` | PASS |
| `thermal_zone1` temp in 15-80°C | `43.0°C` | PASS |
| `|cpu-soc|` divergence | `2.0°C` (≤15) | PASS |
| `thermal_zone0` trip points | passive=`85°C` critical=`95°C` | PASS |
| `thermal_zone1` trip points | passive=`85°C` critical=`95°C` | PASS |
| Cooling device | `cpufreq-cpu0` cur_state=`0` | PASS |
| Thermal-load smoke test | skipped (optional) | SKIP |

## §18 Wayland / display

| Check | Result | Verdict |
|---|---|---|
| `weston` service | `active` | PASS |
| weston process | running | PASS |
| Vivante GPU (`/dev/galcore`) | present | PASS |
| DRM nodes (`card0`+`renderD128`) | present | PASS |
| `seatd` service (optional — logind backend is fine) | `inactive` | INFO |
| HDMI connector | `disconnected` (INFO — headless bench is fine) | INFO |
| 3D GPU render (`weston-simple-egl`, GLES) | EGL/GLES context created + rendered ~5 s, no crash | PASS |

## §19 Wi-Fi radio

| Check | Result | Verdict |
|---|---|---|
| Wi-Fi station interface | `wlp1s0` | PASS |
| Wi-Fi driver module | `moal` | PASS |
| `wpa_supplicant` service | `active` | PASS |
| `nmcli radio wifi` | `enabled` | PASS |
| Wi-Fi scan (AP count) | `52` APs — 2.4GHz:`58` 5GHz:`16` | PASS |
| Wi-Fi associate/DHCP/traffic test | skipped (optional, needs SSID+PSK) | SKIP |

## §20 Bluetooth

| Check | Result | Verdict |
|---|---|---|
| HCI controller (`hci0`) | present | PASS |
| `bluetooth.service` | `active` | PASS |
| BT driver module | `btnxpuart` | PASS |
| rfkill (`hci0` not blocked) | soft-blocked=`no` | PASS |
| Controller enumerated (`bluetoothctl show`) | Manufacturer `0x0048 (72)` | PASS |
| Controller power-on | `hci0 UP RUNNING` | PASS |
| BT scan (devices discovered) | `3` device(s) | PASS |
| HCI link errors post-scan | `errors:0 errors:0` | INFO |
| BT pair/connect test | skipped (optional, needs a target device) | SKIP |

## §21 Audio

| Check | Result | Verdict |
|---|---|---|
| ALSA sound cards (`/proc/asound/cards`) | `4` (≥4: xcvr, wm8960, hdmi, micfil) | PASS |
| On-board codec card (`wm8960`) | registered | PASS |
| HDMI audio card | registered | PASS |
| Playback devices (`aplay -l`) | `4` device(s) | PASS |
| Capture devices (`arecord -l`) | `4` device(s) | PASS |
| `/dev/snd` device nodes | `12` control/pcm nodes | PASS |
| Deferred-probe audio nodes | sound-bt-sco stays unbound — expected (BT-SCO codec absent on a bare EVK) | INFO |
| Tone-playback test | skipped (optional — needs a speaker / HDMI sink) | SKIP |

## §22 PCIe

| Check | Result | Verdict |
|---|---|---|
| PCIe controller node(s) in devicetree | `33800000.pcie` | INFO |
| PCIe host bridge bound (`imx6q-pcie`) | `33800000.pcie` — link is up | INFO |
| PCI devices on the bus (`/sys/bus/pci/devices`) | `2` — host bridge + endpoint(s) | PASS |
| PCIe endpoint-card link + traffic test | skipped (optional — needs a card in the PCIe/M.2 slot) | SKIP |

---

## Summary

| Verdict | Count |
|---|---|
| PASS | 98 |
| FAIL | 2 |
| INFO | 18 |
| SKIP | 11 |
| **Total** | **129** |

**Overall: FAIL** — 2 row(s) failed. Investigate before sign-off.

