#!/bin/bash
# fxplat hourly data update into the PARTITIONED store (since 2026-10-11).
# `fxplat.data ingest update` routes each new day to its partition (new days land in
# forward/), runs the quality gate, and resumes from each symbol's last stored day.
# The old flat-store writer is kept as fxplat-update.sh.flat-2026-10-11.
set -u
D=/home/cmadrigal/fxdata
if [ -f "$D/.lock" ]; then
  pid=$(tr -dc 0-9 < "$D/.lock")
  if [ -n "$pid" ] && /mnt/c/Windows/System32/tasklist.exe /FI "PID eq $pid" /NH 2>/dev/null | grep -qi python; then
    echo "a Windows dukascopy writer (pid $pid) holds $D/.lock; skipping this run"
    exit 0
  fi
fi
cd /home/cmadrigal/Dukascopy || exit 1
exec .venv/bin/python -m fxplat.data ingest update --data-dir "$D" >> "$D/update.log" 2>&1
