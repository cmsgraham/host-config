#!/bin/sh
# Stop ollama before ext4/vhdx can fill host G: and wedge WSL.
THRESHOLD_G=850          # ext4 used (GiB) that trips the guard; the vhdx lives on G: (SN730, 954 GB) since 2026-10-05
CHECK_SECS=5
FLAG=/home/cmadrigal/ollama-gateway/disk-guard.tripped
while :; do
  USED=$(df -BG --output=used / | tail -1 | tr -dc '0-9')
  if [ "${USED:-0}" -ge "$THRESHOLD_G" ]; then
    logger -t disk-guard "ext4 used ${USED}G >= ${THRESHOLD_G}G — stopping ollama to protect G:"
    echo "$(date '+%F %T') tripped at ${USED}G — ollama stopped. Free space then: sudo systemctl start ollama" >> "$FLAG"
    systemctl stop ollama.service ollama-b.service
  fi
  sleep "$CHECK_SECS"
done
