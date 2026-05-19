# Interface test results — imx8mn-evk on `nxp-imx`

- **Run:** `2026-05-19T01:24:32+00:00`
- **Device:** `imx8mn-ddr4-evk-3215220a5c85f0d6` @ `192.168.101.171`
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
| zram swap (`/dev/zram0`) | size=`1.8G` | PASS |
| zram compression | `lz4` | INFO |
| `dev-zram0.swap` unit | `active` | PASS |
| Kernel oops/BUG/stall scan (dmesg) | none this boot | PASS |
| Kernel error-level log lines (dmesg) | `14` err+ lines (INFO — trend across OTAs; some probe-defer noise is benign) | INFO |

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
| Full `xtest` suite | `39327 subtests of which 0 failed 137 test cases of which 0 failed` | PASS |

## §8 U-Boot environment

| Check | Result | Verdict |
|---|---|---|
| Boot partition `/etc/fstab` automount entry | `x-systemd.automount` present for `/mnt/boot` | PASS |
| Boot automount unit (`var-rootdirs-mnt-boot.automount`) | `active` | PASS |
| Boot partition auto-mounts on access | `/mnt/boot/uboot.env` visible — systemd mounted it on demand | PASS |
| `fw_printenv` returns env | 132 vars | PASS |
| `bootcount` | `0` | PASS |
| `bootlimit` | `3` | PASS |
| `upgrade_available` | `0` | PASS |
| `bootupgrade_available` | `0` | PASS |
| `rollback` | `0` | PASS |
| `kernel_image` set | `/boot/ostree/lmp-465fda404b58c5d15c6dcf06abedccb44ec5280…` | PASS |
| `fiovb.*` namespace | `10` vars (≥9) | PASS |
| `fiovb.is_secondary_boot` | `0` (fiovb mirror — informational) | INFO |
| `fiovb.rollback` | `0` (fiovb mirror — informational) | INFO |
| `fiovb.bootupgrade_available` | `1` (fiovb mirror — informational) | INFO |

## §9 Process tree

| Check | Result | Verdict |
|---|---|---|
| `systemd` | running (pid=398) | PASS |
| `dockerd` | running (pid=713) | PASS |
| `containerd` | running (pid=611) | PASS |
| `NetworkManager` | running (pid=571) | PASS |
| `wpa_supplicant` | running (pid=598) | PASS |
| `tee-supplicant` | running (pid=508) | PASS |
| `aktualizr-lite` | running (pid=1620) | PASS |
| `fioconfig` | running (pid=620) | PASS |

## §10 i.MX-specific surfaces

| Check | Result | Verdict |
|---|---|---|
| `soc_id` | `i.MX8MN` | PASS |
| CAAM RNG (`/dev/hwrng`) | 8 bytes: `34f672c2b1d79a45` | PASS |
| VPU device nodes | absent — expected (i.MX 8M Nano has no VPU) | INFO |
| Vivante GPU (`/dev/galcore`) | present | PASS |

## §11 USB (always-on baseline)

| Check | Result | Verdict |
|---|---|---|
| ChipIdea USB controllers bound (`ci_hdrc`) | `1` | PASS |
| USB OTG/UDC controller | `ci_hdrc.0` | PASS |
| USB root hubs | `0` (INFO — 0 is fine if no port is in host mode) | INFO |
| USB device-plugged-in checks | skipped (requires lab presence) | SKIP |

## §12 microSD slot (always-on baseline)

| Check | Result | Verdict |
|---|---|---|
| `mmc1` host controller | present | PASS |
| `mmc1` bound to `30b50000.mmc` (SD slot) | yes | PASS |
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
| `hwclock --show` | `2026-05-19 01:26:58.700288+00:00` | PASS |
| `hctosys` | `1` (0 expected without SNVS battery) | INFO |
| RTC alarm + persistence tests | skipped (optional) | SKIP |

## §14 Memory

| Check | Result | Verdict |
|---|---|---|
| `MemTotal` | `1929656` kB (≥1,800,000 — 2 GiB DDR4) | PASS |
| `CmaTotal` | `655360` kB (640 MiB) | PASS |
| `MemAvailable/MemTotal` | `0.821` (>0.5) | PASS |
| OOM events (this boot) | 0 | PASS |
| `Dirty` pages | `4` kB (<100,000) | PASS |
| memtester stress test | skipped (optional) | SKIP |

## §15 QSPI/FlexSPI (documented absence)

| Check | Result | Verdict |
|---|---|---|
| SPI masters (drift if FlexSPI bound) | `spi3` | INFO |
| MTD devices (drift) | `5` | INFO |

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
| Thermal zones | `1` (imx8mn TMU = single `cpu-thermal` sensor) | PASS |
| `thermal_zone0` (`cpu-thermal`) | `48.0°C` | INFO |
| `thermal_zone0` temp in 15-85°C | `48.0°C` | PASS |
| `thermal_zone0` trip points | passive=`85°C` critical=`95°C` (from the device tree) | INFO |
| Cooling device | `cpufreq-cpu0` cur_state=`0` | PASS |
| Thermal-load smoke test | skipped (optional) | SKIP |

## §18 Wayland / display

| Check | Result | Verdict |
|---|---|---|
| `weston` service | `activating` | FAIL |
| weston process | not running | FAIL |
| Vivante GPU (`/dev/galcore`) | present | PASS |
| DRM nodes (`card0`+`renderD128`) | present | PASS |
| `seatd` service (optional — logind backend is fine) | `inactive` | INFO |
| HDMI connector | `absent` (INFO — a connector appears only with the optional ADV7535 bridge board fitted) | INFO |
| 3D GPU render | weston not active — not run | SKIP |

## §19 Wi-Fi radio

| Check | Result | Verdict |
|---|---|---|
| Wi-Fi station interface | `wlan0` | PASS |
| Wi-Fi driver module (expect `brcmfmac` — BCM4345/6) | `brcmfmac_wcc,brcmfmac,brcmutil` | PASS |
| `wpa_supplicant` service | `active` | PASS |
| `nmcli radio wifi` | `enabled` | PASS |
| Wi-Fi scan (AP count) | `12` APs — 2.4GHz:`14` 5GHz:`1` | PASS |
| Wi-Fi associate/DHCP/traffic test | skipped (optional, needs SSID+PSK) | SKIP |

## §20 Bluetooth

| Check | Result | Verdict |
|---|---|---|
| HCI controller (`hci0`) | present | PASS |
| `bluetooth.service` | `active` | PASS |
| BT driver module (expect `btnxpuart`) | `btnxpuart` | PASS |
| rfkill (`hci0` not blocked) | soft-blocked=`no` | PASS |
| Controller enumerated (`bluetoothctl show`) | Manufacturer `0x000f (15)` | PASS |
| Controller power-on | `hci0 UP RUNNING` | PASS |
| BT scan (devices discovered) | `3` device(s) | PASS |
| HCI link errors post-scan | `errors:0 errors:0` | INFO |
| BT pair/connect test | skipped (optional, needs a target device) | SKIP |

## §21 Audio

| Check | Result | Verdict |
|---|---|---|
| ALSA sound cards (`/proc/asound/cards`) | `3` (≥3: imxspdif, btsco, wm8524) | PASS |
| On-board codec card (`wm8524` DAC) | registered | PASS |
| Playback devices (`aplay -l`) | `4` device(s) | PASS |
| Capture devices (`arecord -l`) | `2` device(s) | PASS |
| `/dev/snd` device nodes | `9` control/pcm nodes | PASS |
| Deferred-probe audio nodes | sound-ak4458 stays unbound — expected (optional audio expansion board absent) | INFO |
| Tone-playback test | skipped (optional — needs a speaker/headset) | SKIP |

## §22 PCIe

| Check | Result | Verdict |
|---|---|---|
| PCIe controller | absent — expected (i.MX 8M Nano has no PCIe) | INFO |

---

## Summary

| Verdict | Count |
|---|---|
| PASS | 85 |
| FAIL | 4 |
| INFO | 21 |
| SKIP | 10 |
| **Total** | **120** |

**Overall: FAIL** — 4 row(s) failed. Investigate before sign-off.

