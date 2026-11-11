#!/usr/bin/env bash
# msi31-backup (2026-10-19): weekly full copy of this WSL machine to the NAS 6TB drive over NFS
# (/mnt/nas-usb, fstab; no-squash export keeps owners/perms/symlinks). Runs as root from
# msi31-backup.service. Incremental: rsync only sends what changed. Phone alert on failure.
set -uo pipefail
DEST=/mnt/nas-usb/msi31-backup/current
LOG=/var/log/msi31-backup.log
NOTIFY="runuser -u cmadrigal -- /home/cmadrigal/agent-ci/.venv/bin/agent-ci --config /home/cmadrigal/Dukascopy/config.yaml notify"
fail() { echo "$(date -Is) FAILED: $1" >> "$LOG"; $NOTIFY --priority 4 "msi31 backup FAILED" "$1" >/dev/null 2>&1; exit 1; }

mountpoint -q /mnt/nas-usb || mount /mnt/nas-usb || fail "NAS 6TB not mounted (NFS 192.168.1.200)"
mkdir -p "$DEST/_meta" || fail "cannot write to $DEST"
echo "$(date -Is) start" >> "$LOG"

# Restore aids: installed packages, apt sources, crontabs, disk layout.
dpkg --get-selections > "$DEST/_meta/dpkg-selections.txt"
cp -a /etc/apt/sources.list* "$DEST/_meta/" 2>/dev/null
crontab -u cmadrigal -l > "$DEST/_meta/crontab-cmadrigal.txt" 2>/dev/null
df -h > "$DEST/_meta/df.txt"; date -Is > "$DEST/_meta/started"

rc=0
for src in /home/cmadrigal /etc /usr/local /root; do
  nice -n 19 ionice -c3 rsync -aH --numeric-ids --delete --delete-excluded \
    --exclude='/home/cmadrigal/.cache/' --exclude='/home/cmadrigal/malware-lab/' --exclude='.local/share/Trash/' \
    --exclude='/home/cmadrigal/.vscode-server/data/logs/' --exclude='__pycache__/' \
    --exclude='.pytest_cache/' --exclude='.ruff_cache/' --exclude='.mypy_cache/' \
    --relative "$src" "$DEST/" >> "$LOG" 2>&1
  r=$?; [ $r -eq 24 ] && r=0          # 24 = files vanished during the copy (normal on a live system)
  [ $r -ne 0 ] && { echo "$(date -Is) rsync $src exit $r" >> "$LOG"; rc=$r; }
done
# 2026-11-11 (disaster-recovery prep): the Windows profile, which no other backup covers (OneDrive's folder is
# already in the cloud; AppData and caches are reinstall material). Local disk (drvfs), so it works with no logon.
WIN=/mnt/c/Users/crist
if [ -d "$WIN" ]; then
  nice -n 19 ionice -c3 rsync -rlt --delete --delete-excluded --modify-window=2 \
    --exclude='/AppData/' --exclude='/OneDrive/' --exclude='/.cache/' --exclude='/Application Data/' \
    --exclude='/Local Settings/' --exclude='/NTUSER*' --exclude='/ntuser*' --exclude='/.vscode/extensions/' \
    --exclude='node_modules/' --exclude='__pycache__/' --exclude='/.docker/' --exclude='*.tmp' \
    "$WIN/" "$DEST/windows-profile/" >> "$LOG" 2>&1
  r=$?; [ $r -eq 24 ] || [ $r -eq 23 ] && r=0   # 23/24: locked or vanished files on a live Windows profile
  [ $r -ne 0 ] && { echo "$(date -Is) rsync windows-profile exit $r" >> "$LOG"; rc=$r; }
fi
date -Is > "$DEST/_meta/finished"
[ $rc -eq 0 ] || fail "rsync exit $rc - see $LOG"
echo "$(date -Is) done ($(du -sh "$DEST" 2>/dev/null | cut -f1))" >> "$LOG"
