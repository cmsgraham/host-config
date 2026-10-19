"""Smoke test: spawn server.py over stdio, do the MCP handshake, list tools."""

import json
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).parent
# the interpreter this test runs under (the WSL .venv, or the old Windows venv)
cmd = sys.argv[1:] or [sys.executable, str(HERE / "server.py")]

proc = subprocess.Popen(
    cmd,
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    text=True, encoding="utf-8")


def send(obj):
    proc.stdin.write(json.dumps(obj) + "\n")
    proc.stdin.flush()


def recv():
    while True:
        line = proc.stdout.readline()
        if not line:
            raise SystemExit(f"server died: {proc.stderr.read()[:2000]}")
        try:
            return json.loads(line)
        except json.JSONDecodeError:
            continue


send({"jsonrpc": "2.0", "id": 1, "method": "initialize",
      "params": {"protocolVersion": "2025-06-18",
                 "capabilities": {},
                 "clientInfo": {"name": "smoke", "version": "0"}}})
init = recv()
print("server:", init["result"]["serverInfo"]["name"])
send({"jsonrpc": "2.0", "method": "notifications/initialized"})
send({"jsonrpc": "2.0", "id": 2, "method": "tools/list"})
tools = recv()
print("tools:", ", ".join(t["name"] for t in tools["result"]["tools"]))

send({"jsonrpc": "2.0", "id": 3, "method": "tools/call",
      "params": {"name": "recent_sessions", "arguments": {"n": 5}}})
result = recv()
print("recent_sessions sample:")
print(result["result"]["content"][0]["text"][:500])
proc.kill()
print("OK")
