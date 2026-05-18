#!/bin/bash
# ============================================================================
# Interface test for the imx8mq-evk — device-side script.
# Runs all "always-on baseline" rows from fio-test-plan-imx8mq-evk.md
# §6.x; skips destructive/optional rows (USB/SD with media, RTC
# persistence, memtester, WDT trigger, thermal-load).
#
# Usage (from the host):
#   sshpass -p fio ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
#       -o LogLevel=ERROR fio@<DEVICE_IP> 'bash -s' < interface-test-imx8mq-evk.sh \
#       > interface-test-results-<TS>.md
#
# Output is GitHub-flavored markdown.
# ============================================================================

row()    { printf "| %s | %s | %s |\n" "$1" "$2" "$3"; }
header() { printf "\n## %s\n\n| Check | Result | Verdict |\n|---|---|---|\n" "$1"; }
SUDO()   { echo fio | sudo -S -p '' "$@" 2>&1; }

PASS_TOTAL=0; FAIL_TOTAL=0; INFO_TOTAL=0; SKIP_TOTAL=0
P() { PASS_TOTAL=$((PASS_TOTAL+1)); }
F() { FAIL_TOTAL=$((FAIL_TOTAL+1)); }
I() { INFO_TOTAL=$((INFO_TOTAL+1)); }
S() { SKIP_TOTAL=$((SKIP_TOTAL+1)); }

HOSTNAME=$(hostname)
IP=$(ip -4 -o addr show end0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
KERNEL=$(uname -r)
LMPVER=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '"')
NOW=$(date -u --iso-8601=seconds)

cat <<MD
# Interface test results — imx8mq-evk on \`nxp-imx\`

- **Run:** \`$NOW\`
- **Device:** \`$HOSTNAME\` @ \`$IP\`
- **LmP version:** \`$LMPVER\`
- **Kernel:** \`$KERNEL\`
- **Boot mode:** eMMC (\`SW802\`=\`ON,OFF\` internal boot, \`SW801\`=\`OFF,OFF,ON,OFF\`)
- **Note:** If the device is **not registered** with FoundriesFactory, aktualizr-lite + fioconfig are intentionally inactive (no \`/var/sota/sql.db\`) — expected pre-registration baseline, not a regression.
- **Skipped (optional / destructive):** §11/§12 with media inserted, §13 persistence/alarm, §14 memtester, §16 WDT trigger, §17 thermal-load.
MD

header "§0 Pre-flight"
who=$(whoami)
[ "$who" = "fio" ] && { row "SSH login as \`fio\`" "\`whoami\`=\`$who\`" "PASS"; P; } || { row "SSH login" "got \`$who\`" "FAIL"; F; }
sr=$(SUDO uname -r)
[ -n "$sr" ] && { row "sudo works" "\`$sr\`" "PASS"; P; } || { row "sudo works" "no output" "FAIL"; F; }

header "§1 System"
row "Kernel" "\`$KERNEL\`" "INFO"; I
row "OS \`VERSION_ID\`" "\`$LMPVER\`" "PASS"; P
state=$(systemctl is-system-running 2>&1)
[ "$state" = "running" ] && { row "\`systemctl is-system-running\`" "\`$state\`" "PASS"; P; } || { row "\`systemctl is-system-running\`" "\`$state\`" "FAIL"; F; }
fl=$(systemctl --failed --no-legend --no-pager --plain 2>/dev/null | awk 'NF{print $1}')
fc=$(echo "$fl" | grep -c .)
[ "$fc" -eq 0 ] && { row "Failed systemd units" "0" "PASS"; P; } || { row "Failed systemd units" "\`$fc\`: $(echo "$fl" | paste -sd, -)" "FAIL"; F; }
zl=$(swapon --show --noheadings | awk '$1=="/dev/zram0" && $2=="partition" && $3+0>0 {print $3}')
[ -n "$zl" ] && { row "zram swap (\`/dev/zram0\`)" "size=\`$zl\`" "PASS"; P; } || { row "zram swap" "not found" "FAIL"; F; }
za=$(grep -oE '\[[^]]+\]' /sys/block/zram0/comp_algorithm 2>/dev/null | tr -d '[]')
row "zram compression" "\`$za\`" "INFO"; I
zu=$(systemctl is-active dev-zram0.swap 2>&1)
[ "$zu" = "active" ] && { row "\`dev-zram0.swap\` unit" "\`$zu\`" "PASS"; P; } || { row "\`dev-zram0.swap\`" "\`$zu\`" "FAIL"; F; }
# kernel-log scan: unambiguous oops/BUG/stall markers (WARN-only backtraces excluded to avoid false FAIL)
kt=$(SUDO dmesg 2>/dev/null | grep -aEc 'Internal error:|Unable to handle kernel|Oops|kernel BUG|BUG:|rcu.*stall|soft lockup|hard LOCKUP|blocked for more than|kernel panic')
[ "${kt:-0}" -eq 0 ] && { row "Kernel oops/BUG/stall scan (dmesg)" "none this boot" "PASS"; P; } || { row "Kernel oops/BUG/stall scan (dmesg)" "\`$kt\` hit(s) — investigate dmesg" "FAIL"; F; }
de=$(SUDO dmesg --level=err,crit,alert,emerg 2>/dev/null | grep -ac .)
row "Kernel error-level log lines (dmesg)" "\`${de:-0}\` err+ lines (INFO — trend across OTAs; some probe-defer noise is benign)" "INFO"; I

header "§2 OSTree"
dc=$(SUDO ostree admin status | grep -cE '^[[:space:]]+Version:')
[ "$dc" -ge 1 ] && { row "OSTree deployments" "\`$dc\` (≥1; 2 after first OTA)" "PASS"; P; } || { row "OSTree deployments" "0" "FAIL"; F; }
ov=$(SUDO ostree admin status 2>/dev/null | awk '/Version:/ {print $2; exit}')
[ "$ov" = "$LMPVER" ] && { row "OSTree Version == \`os-release\`" "\`$ov\`" "PASS"; P; } || { row "OSTree Version vs os-release" "\`$ov\` vs \`$LMPVER\`" "FAIL"; F; }
oh=$(SUDO ostree admin status 2>/dev/null | awk '/^\* lmp/{print $2; exit}')
row "Active OSTree hash" "\`${oh:0:32}…\`" "INFO"; I

header "§3 Foundries OTA stack"
if SUDO test -e /var/sota/sql.db; then
  row "Device registered (\`/var/sota/sql.db\`)" "present" "PASS"; P
  for u in aktualizr-lite fioconfig; do
    s=$(systemctl is-active $u 2>&1)
    [ "$s" = "active" ] && { row "\`$u\` service" "\`$s\`" "PASS"; P; } || { row "\`$u\` service" "\`$s\`" "FAIL"; F; }
  done
else
  row "Device registered (\`/var/sota/sql.db\`)" "absent (expected pre-registration)" "INFO"; I
  for u in aktualizr-lite fioconfig; do
    s=$(systemctl is-active $u 2>&1)
    row "\`$u\` service" "\`$s\` (expected pre-registration)" "INFO"; I
  done
fi

header "§4 Containers"
dv=$(SUDO docker version --format '{{.Server.Version}}' 2>&1)
[ -n "$dv" ] && { row "Docker server version" "\`$dv\`" "PASS"; P; } || { row "Docker server version" "no output" "FAIL"; F; }
hw=$(SUDO docker run --rm hello-world 2>&1 | grep -c "Hello from Docker")
[ "$hw" -ge 1 ] && { row "\`docker run hello-world\`" "ran cleanly" "PASS"; P; } || { row "\`docker run hello-world\`" "failed" "FAIL"; F; }

header "§5 Networking"
ls=$(ip -o link show end0 2>/dev/null | awk '{print $9}')
[ "$ls" = "UP" ] && { row "\`end0\` link" "\`$ls\`" "PASS"; P; } || { row "\`end0\` link" "\`$ls\`" "FAIL"; F; }
hc=$(SUDO curl -s -o /dev/null -w "%{http_code}" --max-time 5 https://api.foundries.io/ 2>&1)
[ "$hc" = "200" ] && { row "Outbound HTTPS (api.foundries.io)" "HTTP \`$hc\`" "PASS"; P; } || { row "Outbound HTTPS" "HTTP \`$hc\`" "FAIL"; F; }

header "§6 Time sync"
ns=$(timedatectl show -p NTPSynchronized --value 2>/dev/null)
[ "$ns" = "yes" ] && { row "Clock synchronized (NTP)" "\`$ns\`" "PASS"; P; } || { row "Clock synchronized" "\`$ns\`" "FAIL"; F; }
na=$(timedatectl show -p NTP --value 2>/dev/null)
[ "$na" = "yes" ] && { row "NTP service active" "\`$na\`" "PASS"; P; } || { row "NTP service active" "\`$na\`" "FAIL"; F; }

header "§7 OP-TEE / TEE"
{ [ -e /dev/tee0 ] && [ -e /dev/teepriv0 ]; } && { row "TEE devices" "\`/dev/tee0\` + \`/dev/teepriv0\`" "PASS"; P; } || { row "TEE devices" "missing" "FAIL"; F; }
pgrep -f tee-supplicant >/dev/null && { row "\`tee-supplicant\` process" "running" "PASS"; P; } || { row "\`tee-supplicant\`" "not running" "FAIL"; F; }
xo=$(SUDO xtest regression_1001 2>&1 | grep -E "subtests of which" | tail -1)
xf=$(echo "$xo" | awk '{for(i=1;i<=NF;i++) if($i=="failed") print $(i-1)}')
[ "$xf" = "0" ] && { row "\`xtest regression_1001\`" "\`$xo\`" "PASS"; P; } || { row "\`xtest regression_1001\`" "\`$xo\`" "FAIL"; F; }
xftmp=$(mktemp)
SUDO timeout 1200 xtest >"$xftmp" 2>&1
xfo=$(grep -E "(subtests|test cases) of which" "$xftmp" | tail -2 | paste -sd' ' -)
grep -qE "test cases of which 0 failed" "$xftmp" && { row "Full \`xtest\` suite" "\`$xfo\`" "PASS"; P; } || { row "Full \`xtest\` suite" "\`${xfo:-incomplete / timed out}\`" "FAIL"; F; }
rm -f "$xftmp"

header "§8 U-Boot environment"
# Boot partition (/mnt/boot — holds uboot.env): verify systemd mounts it via the fstab
# x-systemd.automount entry (the meta-partner per-machine fstab fix). This script does NOT
# mount it itself — exercising the automount IS the test. The vfat fs mounts on access and
# idle-unmounts after ~2s; the fw_printenv checks below rely on that automount.
fstabe=$(grep -E '^[^#]*[[:space:]]/mnt/boot[[:space:]].*x-systemd\.automount' /etc/fstab)
[ -n "$fstabe" ] && { row "Boot partition \`/etc/fstab\` automount entry" "\`x-systemd.automount\` present for \`/mnt/boot\`" "PASS"; P; } || { row "Boot partition \`/etc/fstab\` entry" "no \`x-systemd.automount\` line for \`/mnt/boot\`" "FAIL"; F; }
amu=$(systemctl is-active var-rootdirs-mnt-boot.automount 2>&1)
[ "$amu" = "active" ] && { row "Boot automount unit (\`var-rootdirs-mnt-boot.automount\`)" "\`$amu\`" "PASS"; P; } || { row "Boot automount unit" "\`$amu\` (expected \`active\`)" "FAIL"; F; }
ls /mnt/boot >/dev/null 2>&1   # access the mountpoint — triggers the systemd automount
[ -e /mnt/boot/uboot.env ] && { row "Boot partition auto-mounts on access" "\`/mnt/boot/uboot.env\` visible — systemd mounted it on demand" "PASS"; P; } || { row "Boot partition auto-mount on access" "\`/mnt/boot/uboot.env\` not visible — systemd did not mount the boot partition" "FAIL"; F; }
fo=$(SUDO fw_printenv 2>&1)
fl=$(echo "$fo" | wc -l)
[ "$fl" -gt 50 ] && { row "\`fw_printenv\` returns env" "$fl vars" "PASS"; P; } || { row "\`fw_printenv\`" "\`$fo\`" "FAIL"; F; }
for v in bootcount bootlimit upgrade_available bootupgrade_available rollback; do
  val=$(echo "$fo" | awk -F= -v v="$v" '$1==v{print $2; exit}')
  case "$v" in bootlimit) exp="3";; *) exp="0";; esac
  [ "$val" = "$exp" ] && { row "\`$v\`" "\`$val\`" "PASS"; P; } || { row "\`$v\`" "\`$val\` (expected \`$exp\`)" "FAIL"; F; }
done
ki=$(echo "$fo" | awk -F= '$1=="kernel_image"{print $2}')
[ -n "$ki" ] && { row "\`kernel_image\` set" "\`${ki:0:56}…\`" "PASS"; P; } || { row "\`kernel_image\`" "empty" "FAIL"; F; }
fcnt=$(echo "$fo" | grep -c '^fiovb\.')
[ "$fcnt" -ge 9 ] && { row "\`fiovb.*\` namespace" "\`$fcnt\` vars (≥9)" "PASS"; P; } || { row "\`fiovb.*\`" "\`$fcnt\`" "FAIL"; F; }
for v in fiovb.is_secondary_boot fiovb.rollback fiovb.bootupgrade_available; do
  val=$(echo "$fo" | awk -F= -v v="$v" '$1==v{print $2; exit}')
  # fiovb.* is a U-Boot-written mirror that lags the authoritative plain vars
  # (e.g. fiovb.bootupgrade_available stays 1 until the next boot re-syncs it).
  # The plain bootcount/upgrade_available/bootupgrade_available/rollback checks
  # above are authoritative; report the fiovb mirror as INFO, not PASS/FAIL.
  row "\`$v\`" "\`$val\` (fiovb mirror — informational)" "INFO"; I
done

header "§9 Process tree"
for p in systemd dockerd containerd NetworkManager wpa_supplicant tee-supplicant; do
  pid=$(pgrep -f "$p" | head -1)
  [ -n "$pid" ] && { row "\`$p\`" "running (pid=$pid)" "PASS"; P; } || { row "\`$p\`" "NOT running" "FAIL"; F; }
done
for p in aktualizr-lite fioconfig; do
  pid=$(pgrep -f "$p" | head -1)
  [ -n "$pid" ] && { row "\`$p\`" "running (pid=$pid)" "PASS"; P; } || { row "\`$p\`" "not running (expected pre-registration)" "INFO"; I; }
done

header "§10 i.MX-specific surfaces"
si=$(cat /sys/devices/soc0/soc_id 2>/dev/null)
[ "$si" = "i.MX8MQ" ] && { row "\`soc_id\`" "\`$si\`" "PASS"; P; } || { row "\`soc_id\`" "\`$si\`" "FAIL"; F; }
hb=$(SUDO head -c8 /dev/hwrng 2>/dev/null | xxd -p)
[ -n "$hb" ] && { row "CAAM RNG (\`/dev/hwrng\`)" "8 bytes: \`$hb\`" "PASS"; P; } || { row "CAAM RNG" "no read" "FAIL"; F; }
vp=""; for d in /dev/mxc_hantro /dev/mxc_hantro_h1 /dev/video0; do [ -e "$d" ] && vp="$vp $d"; done
[ -n "$vp" ] && { row "VPU device nodes" "\`$vp\`" "PASS"; P; } || { row "VPU device nodes" "absent" "FAIL"; F; }
[ -e /dev/galcore ] && { row "Vivante GPU (\`/dev/galcore\`)" "present" "PASS"; P; } || { row "Vivante GPU" "absent — expected on \`lmp\`; appears on \`lmp-wayland\`" "INFO"; I; }
# The i.MX8MQ GPU is a single Vivante GC7000Lite (galcore model 0x7000) — a 2D/3D core with NO
# separate 2D/VG engine (unlike the 8M Mini's GC320 / 8M Plus's GC520L). So the kernel log
# `galcore: clk_get 2d core clock failed, disable 2d/vg!` at probe is EXPECTED, not a fault —
# 2D acceleration is still done by the GC7000Lite (NXP G2D API). Documentation row, not a probe.
row "GPU 2D/VG core" "none separate — the single GC7000Lite does 2D+3D; kernel \`disable 2d/vg!\` at probe is expected" "INFO"; I

header "§11 USB (always-on baseline)"
# imx8mq USB is DWC3 USB-3.0 (xHCI) — NOT the imx8mm's ChipIdea (ci_hdrc) USB-2.0-only controllers.
# Verified: two dwc3 controllers — usb@38100000 / usb@38200000 (compatible fsl,imx8mq-dwc3 + snps,dwc3),
# bound as 38100000.usb / 38200000.usb.
dwc=$(ls /sys/bus/platform/drivers/dwc3/ 2>/dev/null | grep -vE '^(bind|unbind|uevent|module)$' | wc -l)
[ "$dwc" -ge 1 ] && { row "DWC3 USB-3.0 controllers bound (\`dwc3\`)" "\`$dwc\` (expect 2: \`38100000.usb\` \`38200000.usb\`)" "PASS"; P; } || { row "DWC3 USB-3.0 controllers" "none bound" "FAIL"; F; }
xc=$(ls /sys/bus/platform/drivers/xhci-hcd/ 2>/dev/null | grep -vE '^(bind|unbind|uevent|module)$' | wc -l)
[ "$xc" -ge 1 ] && { row "xHCI host controllers bound (\`xhci-hcd\`)" "\`$xc\`" "PASS"; P; } || { row "xHCI host controllers" "none bound" "FAIL"; F; }
ud=$(ls /sys/class/udc/ 2>/dev/null | head -1)
[ -n "$ud" ] && { row "USB OTG/UDC controller" "\`$ud\`" "PASS"; P; } || { row "USB OTG/UDC" "absent" "FAIL"; F; }
rh=$(lsusb 2>/dev/null | grep -c "root hub")
row "USB root hubs" "\`$rh\` (INFO — 0 is fine if no port is in host mode)" "INFO"; I
# imx8mq xHCI presents both a USB-2.0 (1d6b:0002) and a USB-3.0 (1d6b:0003) root hub
rh3=$(lsusb 2>/dev/null | grep -c '1d6b:0003')
row "USB-3.0 root hub (\`1d6b:0003\`)" "\`$rh3\` present (INFO — 0 if no host-mode port up)" "INFO"; I
row "USB device-plugged-in checks" "skipped (requires lab presence)" "SKIP"; S

header "§12 microSD slot (always-on baseline)"
# imx8mq usdhc mmc hosts (verified): mmc0 = 30b40000.mmc (usdhc1, eMMC, non-removable),
# mmc1 = 30b50000.mmc (usdhc2, the microSD slot — has cd-gpios). Same base addresses as imx8mm.
[ -d /sys/class/mmc_host/mmc1 ] && { row "\`mmc1\` host controller" "present" "PASS"; P; } || { row "\`mmc1\`" "missing" "FAIL"; F; }
md=$(readlink -f /sys/class/mmc_host/mmc1 2>/dev/null | grep -oE '[0-9a-f]+\.(usdhc|mmc)' | head -1)
[ -n "$md" ] && { row "\`mmc1\` device node (SD slot = usdhc2)" "\`$md\` (expect \`30b50000.mmc\`)" "INFO"; I; } || { row "\`mmc1\` device" "no node" "FAIL"; F; }
# card-detect GPIO: from the current-boot kernel journal — INFO (not all board revs log "Got CD GPIO")
cg=$(SUDO journalctl -k -b 0 2>/dev/null | grep -E "(usdhc|mmc).*Got CD GPIO" | grep -c .)
[ "$cg" -ge 1 ] && row "Card-detect GPIO" "wired (\`Got CD GPIO\`)" "PASS" && P || { row "Card-detect GPIO" "no journal trace (INFO — verify per board)" "INFO"; I; }
ls /dev/mmcblk1* >/dev/null 2>&1 && { row "No microSD inserted" "/dev/mmcblk1 present (unexpected)" "INFO"; I; } || { row "No microSD inserted (expected baseline)" "no /dev/mmcblk1*" "PASS"; P; }
row "microSD-inserted checks" "skipped (requires lab presence)" "SKIP"; S
# --- eMMC boot-device health (board-agnostic, sysfs only — no mmc-utils dependency) ---
emmc=""
for b in /sys/block/mmcblk[0-9]; do
  [ "$(cat "$b/device/type" 2>/dev/null)" = "MMC" ] && { emmc="$b"; break; }
done
if [ -n "$emmc" ]; then
  row "eMMC boot device" "\`/dev/$(basename "$emmc")\` (non-removable, \`device/type\`=MMC)" "PASS"; P
  eol=$(cat "$emmc/device/pre_eol_info" 2>/dev/null)
  lt=$(cat "$emmc/device/life_time" 2>/dev/null)
  case "$eol" in
    0x01)    row "eMMC Pre-EOL health" "\`$eol\` Normal" "PASS"; P ;;
    0x02)    row "eMMC Pre-EOL health" "\`$eol\` WARNING — ~80% of rated life consumed" "FAIL"; F ;;
    0x03)    row "eMMC Pre-EOL health" "\`$eol\` URGENT — replace device" "FAIL"; F ;;
    0x00|"") row "eMMC Pre-EOL health" "\`pre_eol_info\` not reported (eMMC < v5.0)" "INFO"; I ;;
    *)       row "eMMC Pre-EOL health" "unexpected (\`$eol\`)" "INFO"; I ;;
  esac
  [ -n "$lt" ] && { row "eMMC life-time estimate" "\`$lt\` (typ A / typ B; 0x01=0-10% used … 0x0B=exceeded)" "INFO"; I; } || { row "eMMC life-time estimate" "no \`life_time\` attr (eMMC < v5.0)" "INFO"; I; }
else
  row "eMMC boot device" "no mmcblk with \`device/type\`=MMC found" "FAIL"; F
fi

header "§13 RTC (always-on baseline)"
[ -e /dev/rtc0 ] && { row "\`/dev/rtc0\`" "present" "PASS"; P; } || { row "\`/dev/rtc0\`" "missing" "FAIL"; F; }
rn=$(cat /sys/class/rtc/rtc0/name 2>/dev/null)
case "$rn" in *snvs_rtc*) row "RTC driver" "\`$rn\`" "PASS"; P;; *) row "RTC driver" "\`$rn\`" "FAIL"; F;; esac
hc2=$(SUDO hwclock --show 2>&1 | head -1)
echo "$hc2" | grep -qE '^[0-9]{4}-' && { row "\`hwclock --show\`" "\`$hc2\`" "PASS"; P; } || { row "\`hwclock --show\`" "\`$hc2\`" "FAIL"; F; }
hs=$(cat /sys/class/rtc/rtc0/hctosys 2>/dev/null)
row "\`hctosys\`" "\`$hs\` (0 expected without SNVS battery)" "INFO"; I
row "RTC alarm + persistence tests" "skipped (optional)" "SKIP"; S

header "§14 Memory"
mt=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
# imx8mq-evk has 3 GiB LPDDR4 → MemTotal reads 2,957,640 kB after firmware/CMA reservations (verified).
[ "$mt" -ge 2700000 ] && { row "\`MemTotal\`" "\`$mt\` kB (≥2,700,000 — 3 GiB board, expect ~2,957,640)" "PASS"; P; } || { row "\`MemTotal\`" "\`$mt\` kB (expected ≥2,700,000 for a 3 GiB board)" "FAIL"; F; }
cma=$(awk '/^CmaTotal:/{print $2}' /proc/meminfo)
# CMA pool: device-tree linux,cma = 0x38000000 = 896 MiB → CmaTotal 917504 kB (verified).
row "\`CmaTotal\`" "\`$cma\` kB (expect 917504 — DT \`linux,cma\` 0x38000000 / 896 MiB)" "INFO"; I
ratio=$(awk '/^MemAvailable:/{a=$2} /^MemTotal:/{t=$2} END{printf "%.3f", a/t}' /proc/meminfo)
awk -v r="$ratio" 'BEGIN{exit !(r+0>0.5)}' && { row "\`MemAvailable/MemTotal\`" "\`$ratio\` (>0.5)" "PASS"; P; } || { row "\`MemAvailable/MemTotal\`" "\`$ratio\`" "FAIL"; F; }
# OOM scan: current-boot kernel journal (full retention — an early OOM would rotate out of dmesg)
oo=$(SUDO journalctl -k -b 0 2>/dev/null | grep -ciE 'out of memory|oom-kill|killed process')
[ "$oo" -eq 0 ] && { row "OOM events (this boot)" "0" "PASS"; P; } || { row "OOM events" "\`$oo\`" "FAIL"; F; }
dy=$(awk '/^Dirty:/{print $2}' /proc/meminfo)
[ "$dy" -lt 100000 ] && { row "\`Dirty\` pages" "\`$dy\` kB (<100,000)" "PASS"; P; } || { row "\`Dirty\` pages" "\`$dy\` kB" "FAIL"; F; }
row "memtester stress test" "skipped (optional)" "SKIP"; S

header "§15 QSPI/FlexSPI (documented absence)"
sm=$(ls /sys/class/spi_master/ 2>/dev/null | tr '\n' ' ' | tr -s ' ' | sed 's/ $//')
[ "$sm" = "spi1" ] && { row "SPI masters (only \`spi1\` ECSPI)" "\`$sm\`" "PASS"; P; } || { row "SPI masters (drift if FlexSPI bound)" "\`$sm\`" "INFO"; I; }
mc=$(ls /dev/mtd* 2>/dev/null | wc -l)
[ "$mc" -eq 0 ] && { row "MTD devices (none expected)" "\`$mc\`" "PASS"; P; } || { row "MTD devices (drift)" "\`$mc\`" "INFO"; I; }

header "§16 HW watchdog"
[ -e /dev/watchdog0 ] && { row "\`/dev/watchdog0\`" "present" "PASS"; P; } || { row "\`/dev/watchdog0\`" "missing" "FAIL"; F; }
wo=$(SUDO wdctl -O /dev/watchdog0 2>/dev/null)
id=$(echo "$wo" | grep -oE 'IDENTITY="[^"]*"' | sed 's/IDENTITY=//; s/"//g')
to=$(echo "$wo" | grep -oE '\bTIMEOUT="[^"]*"' | sed 's/TIMEOUT=//; s/"//g')   # \b so it doesn't also match PRETIMEOUT=
case "$id" in *imx2*) row "WDT identity" "\`$id\`" "PASS"; P;; *) row "WDT identity" "\`$id\`" "FAIL"; F;; esac
[ "$to" = "60" ] && { row "WDT \`TIMEOUT\`" "\`${to}\`s" "PASS"; P; } || { row "WDT \`TIMEOUT\`" "\`${to}\`s (expected 60)" "INFO"; I; }
bnz=$(echo "$wo" | grep -oE '[A-Z_]+_BOOT="[^"]*"' | grep -v '"0"' | wc -l)
[ "$bnz" -eq 0 ] && { row "WDT \`*_BOOT\` flags" "all 0 (clean reset)" "PASS"; P; } || { row "WDT \`*_BOOT\`" "$bnz non-zero" "INFO"; I; }
rw=$(systemctl show -p RebootWatchdogUSec --value 2>/dev/null)
rtw=$(systemctl show -p RuntimeWatchdogUSec --value 2>/dev/null)
row "systemd \`RebootWatchdogUSec\` / \`RuntimeWatchdogUSec\`" "\`$rw\` / \`$rtw\`" "INFO"; I
row "Destructive WDT trigger" "skipped (would reboot)" "SKIP"; S

header "§17 Temperature sensors"
# imx8mq TMU exposes one thermal zone, `cpu-thermal` (verified — same as imx8mm).
zc=$(ls /sys/class/thermal/ | grep -c '^thermal_zone')
[ "$zc" -ge 1 ] && { row "Thermal zones" "\`$zc\` (expect 1: \`cpu-thermal\`)" "INFO"; I; } || { row "Thermal zones" "\`$zc\` (none found)" "FAIL"; F; }
t0=$(awk '{printf "%.1f", $1/1000}' /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
t0t=$(cat /sys/class/thermal/thermal_zone0/type 2>/dev/null)
row "\`thermal_zone0\` (\`$t0t\`)" "\`${t0}°C\`" "INFO"; I
awk -v t="$t0" 'BEGIN{exit !(t>=15 && t<=85)}' && { row "\`thermal_zone0\` temp in 15-85°C" "\`${t0}°C\`" "PASS"; P; } || { row "\`thermal_zone0\` temp" "\`${t0}°C\` out of range" "FAIL"; F; }
pa=$(awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone0/trip_point_0_temp 2>/dev/null)
cr=$(awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone0/trip_point_1_temp 2>/dev/null)
row "\`thermal_zone0\` trip points" "passive=\`${pa}°C\` critical=\`${cr}°C\` (expect 85 / 95)" "INFO"; I
ct=$(cat /sys/class/thermal/cooling_device0/type 2>/dev/null)
cs=$(cat /sys/class/thermal/cooling_device0/cur_state 2>/dev/null)
[ "$ct" = "cpufreq-cpu0" ] && { row "Cooling device" "\`$ct\` cur_state=\`$cs\`" "PASS"; P; } || { row "Cooling device" "\`$ct\`" "FAIL"; F; }
row "Thermal-load smoke test" "skipped (optional)" "SKIP"; S

header "§18 Wayland / display"
# imx8mq-evk display path: DCSS (Display Controller Subsystem) driving HDMI. Verified: the DRM
# connector is `card0-HDMI-A-1`. The connector probe below still auto-detects, so a build that
# brings up a different connector (e.g. DP-1) is handled without edits.
# Whole section only applies on lmp-wayland DISTRO. Detect via weston unit presence.
if systemctl list-unit-files weston.service >/dev/null 2>&1 && [ -e /dev/galcore ]; then
  wa=$(systemctl is-active weston 2>&1)
  [ "$wa" = "active" ] && { row "\`weston\` service" "\`$wa\`" "PASS"; P; } || { row "\`weston\` service" "\`$wa\`" "FAIL"; F; }
  pgrep -ax weston >/dev/null && { row "weston process" "running" "PASS"; P; } || { row "weston process" "not running" "FAIL"; F; }
  [ -e /dev/galcore ] && { row "Vivante GPU (\`/dev/galcore\`)" "present" "PASS"; P; } || { row "\`/dev/galcore\`" "absent" "FAIL"; F; }
  { [ -e /dev/dri/card0 ] && [ -e /dev/dri/renderD128 ]; } && { row "DRM nodes (\`card0\`+\`renderD128\`)" "present" "PASS"; P; } || { row "DRM nodes" "missing" "FAIL"; F; }
  # seatd is OPTIONAL — weston commonly uses the logind libseat backend; inactive seatd is INFO, never FAIL
  sd=$(systemctl is-active seatd 2>&1)
  row "\`seatd\` service (optional — logind backend is fine)" "\`$sd\`" "INFO"; I
  # display-attached: INFO unless a monitor is connected. Auto-detects the first card0 connector;
  # on the imx8mq-evk this is HDMI-A-1 (verified).
  conn=$(ls -d /sys/class/drm/card0-* 2>/dev/null | head -1)
  if [ -n "$conn" ]; then
    cn=$(basename "$conn")
    hs=$(cat "$conn/status" 2>/dev/null)
    if [ "$hs" = "connected" ]; then
      hm=$(head -1 "$conn/modes" 2>/dev/null)
      fb=$(cat /sys/class/graphics/fb0/virtual_size 2>/dev/null)
      row "Display connector (\`$cn\`, expect \`HDMI-A-1\`)" "\`connected\`, mode \`$hm\`, fb0 \`$fb\`" "PASS"; P
    else
      row "Display connector (\`$cn\`, expect \`HDMI-A-1\`)" "\`${hs:-unknown}\` (INFO — headless bench is fine)" "INFO"; I
    fi
  else
    row "Display connector" "no \`card0-*\` connector found" "INFO"; I
  fi
  # 3D GPU functional check — actually render, don't just probe nodes. weston-simple-egl is a
  # GLES client; run it against the live compositor under `timeout`. If EGL/GLES init or the
  # Vivante UMD is broken the client exits at once (rc≠124); if the GPU renders, it runs until
  # `timeout` stops it (rc 124/137). Catches a UMD/kernel-driver mismatch or GPU hang that the
  # /dev/galcore + DRM-node presence checks above cannot. Non-destructive (~5 s).
  wpid=$(pgrep -x weston | head -1)
  if ! command -v weston-simple-egl >/dev/null 2>&1; then
    row "3D GPU render" "\`weston-simple-egl\` not in image — not run" "SKIP"; S
  elif [ "$wa" != "active" ] || [ -z "$wpid" ]; then
    row "3D GPU render" "weston not active — not run" "SKIP"; S
  else
    # reuse the compositor's own runtime dir + wayland socket (read from its /proc environ)
    xrd=$(SUDO cat /proc/"$wpid"/environ | tr '\0' '\n' | sed -n 's/^XDG_RUNTIME_DIR=//p' | head -1)
    wdpy=$(SUDO ls "$xrd" | grep -E '^wayland-[0-9]+$' | head -1)
    if [ -z "$xrd" ] || [ -z "$wdpy" ]; then
      row "3D GPU render" "could not resolve the compositor Wayland socket — not run" "SKIP"; S
    else
      eglout=$(SUDO env XDG_RUNTIME_DIR="$xrd" WAYLAND_DISPLAY="$wdpy" timeout -k 2 5 weston-simple-egl)
      rc=$?
      if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
        row "3D GPU render (\`weston-simple-egl\`, GLES on GC7000Lite)" "EGL/GLES context created + rendered ~5 s, no crash" "PASS"; P
      else
        row "3D GPU render (\`weston-simple-egl\`)" "client exited early (rc=\`$rc\`): \`$(printf %s "$eglout" | tr '\n|' '  ' | tr -d '\r' | tail -c 110)\`" "FAIL"; F
      fi
    fi
  fi
else
  row "Wayland / display section" "N/A — DISTRO is \`lmp\` (no compositor), not \`lmp-wayland\`" "INFO"; I
fi

header "§19 Wi-Fi radio"
# imx8mq-evk Wi-Fi is on the M.2 slot — verified module: Broadcom, driver `brcmfmac`, station
# interface `wlp1s0` (PCIe-attached, hence wlp* predictable naming). Note the M.2 card is swappable,
# so the chip/driver is module-dependent; the checks below stay generic across ath*/mlan/brcmfmac.
wlif=$(ip -br link show 2>/dev/null | awk '/^(wl|mlan)/{print $1; exit}')
if [ -n "$wlif" ]; then
  row "Wi-Fi station interface" "\`$wlif\` (expect \`wlp1s0\`; M.2-card-dependent)" "PASS"; P
  drv=$(lsmod 2>/dev/null | awk '/^(ath10k|ath11k|ath6kl|ath|moal|mlan|brcmfmac|brcmutil|iwlwifi)/{print $1}' | paste -sd, -)
  [ -n "$drv" ] && { row "Wi-Fi driver module" "\`$drv\` (expect \`brcmfmac\`; M.2-card-dependent)" "PASS"; P; } || { row "Wi-Fi driver module" "none loaded" "FAIL"; F; }
  ws=$(systemctl is-active wpa_supplicant 2>&1)
  [ "$ws" = "active" ] && { row "\`wpa_supplicant\` service" "\`$ws\`" "PASS"; P; } || { row "\`wpa_supplicant\`" "\`$ws\`" "FAIL"; F; }
  wr=$(nmcli radio wifi 2>/dev/null)
  [ "$wr" = "enabled" ] && { row "\`nmcli radio wifi\`" "\`$wr\`" "PASS"; P; } || { row "\`nmcli radio wifi\`" "\`$wr\`" "FAIL"; F; }
  # scan — the meaningful radio test (~7s, no credentials)
  echo fio | sudo -S -p '' ip link set "$wlif" up 2>/dev/null
  echo fio | sudo -S -p '' nmcli device wifi rescan 2>/dev/null
  sleep 6
  apc=$(echo fio | sudo -S -p '' nmcli -t -f SSID device wifi list 2>/dev/null | grep -c .)
  if [ "${apc:-0}" -ge 1 ]; then
    g24=$(echo fio | sudo -S -p '' nmcli -t -f CHAN device wifi list 2>/dev/null | awk -F: '$1>0 && $1<=13' | wc -l)
    g5=$(echo fio | sudo -S -p '' nmcli -t -f CHAN device wifi list 2>/dev/null | awk -F: '$1>=32' | wc -l)
    row "Wi-Fi scan (AP count)" "\`$apc\` APs — 2.4GHz:\`$g24\` 5GHz:\`$g5\`" "PASS"; P
  else
    row "Wi-Fi scan (AP count)" "\`0\` APs — FAIL unless bench is RF-isolated" "FAIL"; F
  fi
  row "Wi-Fi associate/DHCP/traffic test" "skipped (optional, needs SSID+PSK)" "SKIP"; S
else
  row "Wi-Fi radio section" "N/A — no \`wl*\` interface on this board" "INFO"; I
fi

header "§20 Bluetooth"
if echo fio | sudo -S -p '' hciconfig hci0 >/dev/null 2>&1; then
  row "HCI controller (\`hci0\`)" "present" "PASS"; P
  bs=$(systemctl is-active bluetooth 2>&1)
  [ "$bs" = "active" ] && { row "\`bluetooth.service\`" "\`$bs\`" "PASS"; P; } || { row "\`bluetooth.service\`" "\`$bs\`" "FAIL"; F; }
  # imx8mq-evk BT (verified): UART-attached NXP controller, driver `btnxpuart`, `hci0` Bus: UART.
  # M.2-module-dependent like Wi-Fi; the lsmod match below stays generic.
  bdrv=$(lsmod 2>/dev/null | awk '/^(btqca|hci_uart|btnxpuart|btrtl|btbcm|btintel|hci_bcm)/{print $1}' | paste -sd, -)
  [ -n "$bdrv" ] && { row "BT driver module" "\`$bdrv\` (expect \`btnxpuart\` — UART-attached NXP BT)" "PASS"; P; } || { row "BT driver module" "none loaded" "FAIL"; F; }
  rfb=$(rfkill list 2>/dev/null | awk '/hci0/{f=1} f&&/Soft blocked/{print $3; f=0}')
  [ "$rfb" = "no" ] && { row "rfkill (\`hci0\` not blocked)" "soft-blocked=\`$rfb\`" "PASS"; P; } || { row "rfkill \`hci0\`" "soft-blocked=\`$rfb\`" "FAIL"; F; }
  ident=$(echo fio | sudo -S -p '' bluetoothctl show 2>/dev/null | awk -F': ' '/Manufacturer:/{print $2}')
  [ -n "$ident" ] && { row "Controller enumerated (\`bluetoothctl show\`)" "Manufacturer \`$ident\`" "PASS"; P; } || { row "Controller enumerated" "show returned nothing" "FAIL"; F; }
  # power-on + scan — the meaningful radio test (~17s, no paired device needed)
  echo fio | sudo -S -p '' bluetoothctl power on >/dev/null 2>&1
  sleep 2
  up=$(echo fio | sudo -S -p '' hciconfig hci0 2>/dev/null | grep -c 'UP RUNNING')
  [ "$up" -ge 1 ] && { row "Controller power-on" "\`hci0 UP RUNNING\`" "PASS"; P; } || { row "Controller power-on" "did not come UP" "FAIL"; F; }
  echo fio | sudo -S -p '' bluetoothctl --timeout 15 scan on >/dev/null 2>&1
  bdc=$(echo fio | sudo -S -p '' bluetoothctl devices 2>/dev/null | grep -c '^Device')
  if [ "${bdc:-0}" -ge 1 ]; then
    row "BT scan (devices discovered)" "\`$bdc\` device(s)" "PASS"; P
  else
    row "BT scan (devices discovered)" "\`0\` — FAIL unless bench is RF-isolated / nothing advertising" "FAIL"; F
  fi
  bhe=$(echo fio | sudo -S -p '' hciconfig hci0 2>/dev/null | grep -oE 'errors:[0-9]+' | paste -sd' ' -)
  row "HCI link errors post-scan" "\`$bhe\`" "INFO"; I
  row "BT pair/connect test" "skipped (optional, needs a target device)" "SKIP"; S
else
  row "Bluetooth section" "N/A — no \`hci0\` controller on this board" "INFO"; I
fi

header "§21 Audio"
# imx8mq-evk audio (verified): 4 ALSA cards — imxspdif, imxhdmiarc, imxaudiohdmi, wm8524audio
# (SPDIF, HDMI-ARC, HDMI-audio, and the WM8524 analog DAC).
acards=$(grep -cE '^ *[0-9]+ \[' /proc/asound/cards 2>/dev/null)
[ "${acards:-0}" -ge 1 ] && { row "ALSA sound cards (\`/proc/asound/cards\`)" "\`$acards\` (expect 4)" "PASS"; P; } || { row "ALSA sound cards" "\`${acards:-0}\` (none registered)" "FAIL"; F; }
 acn=$(awk -F'[][]' '/^ *[0-9]+ \[/{printf "%s ", $2}' /proc/asound/cards 2>/dev/null | sed 's/ *$//')
row "ALSA card names" "\`${acn:-none}\` (expect \`imxspdif imxhdmiarc imxaudiohdmi wm8524audio\`)" "INFO"; I
pbk=$(aplay -l 2>/dev/null | grep -c '^card ')
[ "${pbk:-0}" -ge 1 ] && { row "Playback devices (\`aplay -l\`)" "\`$pbk\` device(s)" "PASS"; P; } || { row "Playback devices" "none" "FAIL"; F; }
cap=$(arecord -l 2>/dev/null | grep -c '^card ')
[ "${cap:-0}" -ge 1 ] && { row "Capture devices (\`arecord -l\`)" "\`$cap\` device(s)" "PASS"; P; } || { row "Capture devices" "none" "FAIL"; F; }
snd=$(ls /dev/snd/ 2>/dev/null | grep -cE '^(controlC|pcmC)')
[ "${snd:-0}" -ge 2 ] && { row "\`/dev/snd\` device nodes" "\`$snd\` control/pcm nodes" "PASS"; P; } || { row "\`/dev/snd\` nodes" "\`${snd:-0}\`" "FAIL"; F; }
row "Deferred-probe audio nodes" "optional audio-expansion / BT-SCO codec nodes may stay unbound — expected on a bare EVK" "INFO"; I
row "Tone-playback test" "skipped (optional — needs a speaker/headset)" "SKIP"; S

header "§22 PCIe"
# imx8mq has two PCIe Gen2 controllers (DesignWare-based, driver imx6q-pcie). A PCIe link comes
# up only with an endpoint card fitted in a slot; on a bare bench a controller often stays
# unbound ("PHY link never came up") — expected, so these rows are INFO/SKIP, never FAIL.
pcienode=$(for d in /sys/bus/platform/devices/*.pcie; do [ -e "$d" ] && basename "$d"; done | paste -sd, -)
[ -n "$pcienode" ] && { row "PCIe controller node(s) in devicetree" "\`$pcienode\`" "INFO"; I; } || { row "PCIe controller node(s)" "no \`*.pcie\` node — PCIe not enabled in this devicetree" "INFO"; I; }
pciebound=$(ls /sys/bus/platform/drivers/imx6q-pcie/ 2>/dev/null | grep -E '\.pcie$' | paste -sd, -)
[ -n "$pciebound" ] && { row "PCIe host bridge(s) bound (\`imx6q-pcie\`)" "\`$pciebound\` — link is up" "INFO"; I; } || { row "PCIe host bridge bound" "not bound — no link (expected with no endpoint card)" "INFO"; I; }
pcin=$(ls /sys/bus/pci/devices/ 2>/dev/null | grep -c .)
if [ "${pcin:-0}" -ge 2 ]; then
  row "PCI devices on the bus (\`/sys/bus/pci/devices\`)" "\`$pcin\` — host bridge + endpoint(s)" "PASS"; P
elif [ "${pcin:-0}" -eq 1 ]; then
  row "PCI devices on the bus (\`/sys/bus/pci/devices\`)" "\`1\` — host bridge only, no endpoint card" "INFO"; I
else
  row "PCI devices on the bus" "\`0\` — no PCI bus up (no link / no card)" "INFO"; I
fi
row "PCIe endpoint-card link + traffic test" "skipped (optional — needs a card in a PCIe/M.2 slot)" "SKIP"; S

TOTAL=$((PASS_TOTAL + FAIL_TOTAL + INFO_TOTAL + SKIP_TOTAL))
cat <<MD

---

## Summary

| Verdict | Count |
|---|---|
| PASS | $PASS_TOTAL |
| FAIL | $FAIL_TOTAL |
| INFO | $INFO_TOTAL |
| SKIP | $SKIP_TOTAL |
| **Total** | **$TOTAL** |

MD
if [ "$FAIL_TOTAL" -eq 0 ]; then
  echo "**Overall: PASS** — no FAIL rows. INFO rows are intentional documentation (unregistered services, expected absences, baseline-informational values)."
else
  echo "**Overall: FAIL** — $FAIL_TOTAL row(s) failed. Investigate before sign-off."
fi
echo