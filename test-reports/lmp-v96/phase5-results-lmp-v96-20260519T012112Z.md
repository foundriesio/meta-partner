# Phase 5 — compose-app enablement (shellhttpd) — lmp-v96 — PASS (all 4 boards)

APPS_TARGET = 20 (adds shellhttpd; OSTree == target 18, apps-only delta — no reboot).
Revealed target 20 + assigned shellhttpd to all 4 devices (fioctl devices config updates
--apps shellhttpd). Each board OTA'd to 20 and started the container.

| Board / device | docker ps | localhost:8080 | host-side :8080 | aktualizr | fioctl |
|---|---|---|---|---|---|
| imx8mm-evk-dev | shellhttpd-httpd-1 Up, 0.0.0.0:8080 | Hello world | Hello world | Active 20, shellhttpd on | lmp-20, Docker Apps: shellhttpd |
| imx8mn-evk-dev | shellhttpd-httpd-1 Up, 0.0.0.0:8080 | Hello world | Hello world | Active 20, shellhttpd on | lmp-20, Docker Apps: shellhttpd |
| imx8mp-evk-dev | shellhttpd-httpd-1 Up, 0.0.0.0:8080 | Hello world | Hello world | Active 20, shellhttpd on | lmp-20, Docker Apps: shellhttpd |
| imx8mq-evk-dev | shellhttpd-httpd-1 Up, 0.0.0.0:8080 | Hello world | Hello world | Active 20, shellhttpd on | lmp-20, Docker Apps: shellhttpd |

All boards: container running, HTTP payload "Hello world" both device-local and from the
host LAN; aktualizr-lite Active image 20 with shellhttpd in the compose-apps list.

Verdict: Phase 5 PASS, all four boards.
