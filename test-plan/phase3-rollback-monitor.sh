#!/usr/bin/env bash
# phase3-rollback-monitor.sh — watch the test-plan Phase 3 panic/rollback sequence
# on one or more boards by tailing their logged serial consoles.
#
# Usage:
#   phase3-rollback-monitor.sh [-n N] [-i SECS] [-t SECS] NAME=LOGFILE[:OFFSET] ...
#
#   -n N      panic cycles expected before rollback   (default 3, = U-Boot bootlimit)
#   -i SECS   poll interval                           (default 15)
#   -t SECS   overall timeout                         (default 1800)
#   NAME=LOGFILE          monitor LOGFILE, label it NAME; baseline = its size now
#   NAME=LOGFILE:OFFSET   monitor from 1-based byte OFFSET (replay / forensics)
#
# Per board it reports boots seen, panics seen, and rollback state. A board is
# DONE once it has >= N panics followed by a healthy `login:` prompt. Exits 0
# when every board is DONE, 1 on timeout, 2 on thrash (panics past N with no
# healthy boot by the deadline).
#
# Why this is not the original one-liner: the first version slurped each
# multi-hundred-KB serial log into a shell variable and re-`echo`'d it through
# grep. That pipeline returned empty under load, so the panic count came back
# blank ("integer expected") and detection broke. This version greps the log
# *files* directly by byte offset — no large shell variables.

set -u

PANICS_EXPECTED=3
INTERVAL=15
TIMEOUT=1800

while getopts "n:i:t:h" opt; do
  case "$opt" in
    n) PANICS_EXPECTED=$OPTARG ;;
    i) INTERVAL=$OPTARG ;;
    t) TIMEOUT=$OPTARG ;;
    h) sed -n '2,26p' "$0"; exit 0 ;;
    *) echo "bad option; -h for help" >&2; exit 64 ;;
  esac
done
shift $((OPTIND - 1))

[ "$#" -ge 1 ] || { echo "error: no NAME=LOGFILE arguments; -h for help" >&2; exit 64; }

NAMES=() LOGS=() OFFS=()
for arg in "$@"; do
  name=${arg%%=*}
  spec=${arg#*=}
  log=${spec%:*}
  off=${spec##*:}
  [ "$off" = "$spec" ] && off=""          # no :OFFSET given
  [ -f "$log" ] || { echo "error: no such log file: $log" >&2; exit 66; }
  [ -n "$off" ] || off=$(( $(wc -c < "$log") + 1 ))   # baseline = current end
  NAMES+=("$name"); LOGS+=("$log"); OFFS+=("$off")
  echo "monitoring $name : $log  (from byte $off)"
done

PANIC_RE='Kernel panic - not syncing'
BOOT_RE='U-Boot SPL 20'
LOGIN_RE='login:'

# integer; 0 on any miss
intgrep() { local c; c=$(grep -ac "$1" "$2" 2>/dev/null); echo "$(( ${c:-0} + 0 ))"; }
lastline() { grep -an "$1" "$2" 2>/dev/null | tail -1 | cut -d: -f1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

start=$(date +%s)
n=${#NAMES[@]}
declare -a STATE                         # per board: wait | done | thrash
for ((b = 0; b < n; b++)); do STATE[b]=wait; done

echo "start $(date -u +%H:%M:%SZ) — expecting $PANICS_EXPECTED panic(s) then rollback"

while :; do
  now=$(date +%s); elapsed=$(( now - start ))
  alldone=1; line=""
  for ((b = 0; b < n; b++)); do
    slice="$tmp/slice.$b"
    tail -c +"${OFFS[b]}" "${LOGS[b]}" 2>/dev/null | tr -d '\000\r' > "$slice"
    panics=$(intgrep "$PANIC_RE" "$slice")
    boots=$(intgrep "$BOOT_RE" "$slice")
    lp=$(lastline "$PANIC_RE" "$slice"); lp=${lp:-0}
    ll=$(lastline "$LOGIN_RE" "$slice"); ll=${ll:-0}

    if [ "$panics" -ge "$PANICS_EXPECTED" ] && [ "$ll" -gt "$lp" ]; then
      STATE[b]=done
    elif [ "$panics" -gt "$PANICS_EXPECTED" ]; then
      STATE[b]=thrash                     # more panics than expected, still no healthy boot
    fi
    [ "${STATE[b]}" = done ] || alldone=0
    line+=$(printf ' | %s: boots=%s panics=%s %s' \
            "${NAMES[b]}" "$boots" "$panics" "${STATE[b]}")
  done
  echo "[$(date -u +%H:%M:%SZ) +${elapsed}s]${line}"

  [ "$alldone" = 1 ] && { echo "ALL BOARDS ROLLED BACK after ${elapsed}s"; exit 0; }

  for ((b = 0; b < n; b++)); do
    if [ "${STATE[b]}" = thrash ]; then
      echo "THRASH: ${NAMES[b]} panicked more than $PANICS_EXPECTED times without a healthy boot" >&2
      exit 2
    fi
  done

  if [ "$elapsed" -ge "$TIMEOUT" ]; then
    echo "TIMEOUT after ${elapsed}s — not all boards rolled back" >&2
    exit 1
  fi
  sleep "$INTERVAL"
done
