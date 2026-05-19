# Interface test — high-level summary by interface

**Detail:** `interface-test-results-imx8mp-evk-20260519T012140Z.md`

| Interface | Verdict | P / F / I / S | Notes |
|---|---|---|---|
| §0 Pre-flight | PASS | 2P 0F 0I 0S |  |
| §1 System | FAIL | 4P 2F 3I 0S | `systemctl is-system-running` -> `degraded`; Failed systemd units -> `1`: psplash-start.service |
| §2 OSTree | PASS | 2P 0F 1I 0S |  |
| §3 Foundries OTA stack | PASS | 3P 0F 0I 0S |  |
| §4 Containers | PASS | 2P 0F 0I 0S |  |
| §5 Networking | PASS | 2P 0F 0I 0S |  |
| §6 Time sync | PASS | 2P 0F 0I 0S |  |
| §7 OP-TEE / TEE | PASS | 4P 0F 0I 0S |  |
| §8 U-Boot environment | PASS | 11P 0F 3I 0S |  |
| §9 Process tree | PASS | 8P 0F 0I 0S |  |
| §10 i.MX-specific surfaces | PASS | 4P 0F 0I 1S |  |
| §11 USB host (always-on baseline) | PASS | 3P 0F 0I 1S |  |
| §12 microSD slot (always-on baseline) | PASS | 6P 0F 1I 1S |  |
| §13 RTC (always-on baseline) | PASS | 3P 0F 1I 1S |  |
| §14 Memory | PASS | 5P 0F 0I 1S |  |
| §15 QSPI/FlexSPI (documented absence) | PASS | 2P 0F 0I 0S |  |
| §16 HW watchdog | PASS | 4P 0F 1I 1S |  |
| §17 Temperature sensors | PASS | 6P 0F 2I 1S |  |
| §18 Wayland / display | PASS | 5P 0F 2I 0S |  |
| §19 Wi-Fi radio | PASS | 5P 0F 0I 1S |  |
| §20 Bluetooth | PASS | 7P 0F 1I 1S |  |
| §21 Audio | PASS | 6P 0F 1I 1S |  |
| §22 PCIe | PASS | 1P 0F 2I 1S |  |
