#!/bin/bash
# Switch Ollama to the patched binary (ollama-wslquiet) at a safe moment, or roll back with --rollback.
# Safe moment = the fxplat pipeline is validating / at the merge gate (no model calls for minutes) and the
# gateway has nothing in flight. Research: ~/agent-ci/docs/research/2026-10-17-ollama-discovery-dxg.md
set -u
target=/home/cmadrigal/.local/ollama/bin/ollama-wslquiet
[ "${1:-}" = "--rollback" ] && target=/home/cmadrigal/.local/ollama/bin/ollama
echo "switching ~/.local/bin/ollama -> $target at the next safe moment (Ctrl-C to abort)"
cd ~/Dukascopy || exit 1
while true; do
  st=$(~/agent-ci/.venv/bin/agent-ci status 2>/dev/null | grep -E '^(status:|merge gate|no active run)' | head -1)
  inf=$(curl -s -m5 http://127.0.0.1:11434/_dash/data | python3 -c "import json,sys;print(len(json.load(sys.stdin).get('inflight') or []))" 2>/dev/null)
  if echo "$st" | grep -qE 'VALIDATING|merge gate' && [ "$inf" = "0" ]; then break; fi
  echo "  $(date +%T) waiting (${st:-?}, in flight ${inf:-?})"; sleep 15
done
echo "$(date +%T) safe: $st"
ln -sfn "$target" /home/cmadrigal/.local/bin/ollama
sudo systemctl restart ollama.service
sleep 6
echo "ollama.service: $(systemctl is-active ollama.service)"
echo "binary: $(readlink -f /home/cmadrigal/.local/bin/ollama)"
echo "version via gateway: $(curl -s -m5 http://127.0.0.1:11434/api/version)"
