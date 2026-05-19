# Interface test — high-level summary by interface

**Detail:** `interface-test-results-imx8mq-evk-20260519T012140Z.md`

| Interface | Verdict | P / F / I / S | Notes |
|---|---|---|---|
| §0 Pre-flight | PASS | 2P 0F 0I 0S |  |
| §1 System | PASS | 6P 0F 3I 0S |  |
| §2 OSTree | PASS | 2P 0F 1I 0S |  |
| §3 Foundries OTA stack | PASS | 3P 0F 0I 0S |  |
| §4 Containers | PASS | 2P 0F 0I 0S |  |
| §5 Networking | PASS | 2P 0F 0I 0S |  |
| §6 Time sync | PASS | 2P 0F 0I 0S |  |
| §7 OP-TEE / TEE | PASS | 4P 0F 0I 0S |  |
| §8 U-Boot environment | PASS | 11P 0F 3I 0S |  |
| §9 Process tree | PASS | 8P 0F 0I 0S |  |
| §10 i.MX-specific surfaces | PASS | 4P 0F 1I 0S |  |
| §11 USB (always-on baseline) | PASS | 3P 0F 2I 1S |  |
| §12 microSD slot (always-on baseline) | PASS | 5P 0F 2I 1S |  |
| §13 RTC (always-on baseline) | PASS | 3P 0F 1I 1S |  |
| §14 Memory | PASS | 4P 0F 1I 1S |  |
| §15 QSPI/FlexSPI (documented absence) | PASS | 0P 0F 2I 0S |  |
| §16 HW watchdog | PASS | 4P 0F 1I 1S |  |
| §17 Temperature sensors | PASS | 2P 0F 3I 1S |  |
| §18 Wayland / display | PASS | 6P 0F 1I 0S |  |
| §19 Wi-Fi radio | PASS | 5P 0F 0I 1S |  |
| §20 Bluetooth | FAIL | 6P 1F 1I 1S | BT scan (devices discovered) -> `0` — FAIL unless bench is RF-isolated / nothing advertising |
| §21 Audio | PASS | 4P 0F 2I 1S |  |
| §22 PCIe | PASS | 1P 0F 2I 1S |  |
