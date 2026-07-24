#!/usr/bin/env bash
# Install Claude Code hooks that ping tmux when Claude finishes / needs input.
#
# Idempotent: running multiple times leaves settings.json in the same state.
# Non-destructive: existing hooks / other settings are preserved; a timestamped
# backup is written next to the file before any change.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/mark-ready.sh"
SETTINGS="$HOME/.claude/settings.json"

if [ ! -f "$SCRIPT" ]; then
  echo "error: mark-ready.sh not found next to install.sh" >&2
  exit 1
fi

chmod +x "$SCRIPT"

mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

python3 - "$SETTINGS" "$SCRIPT" <<'PY'
import json, os, shutil, sys, time
from pathlib import Path

settings_path = Path(sys.argv[1])
command = sys.argv[2]

data = json.loads(settings_path.read_text() or "{}")

backup = settings_path.with_suffix(
    settings_path.suffix + f".bak.{time.strftime('%Y%m%d-%H%M%S')}"
)
shutil.copy2(settings_path, backup)

hooks = data.setdefault("hooks", {})

def ensure_event(event: str) -> None:
    entries = hooks.setdefault(event, [])
    for entry in entries:
        for h in entry.get("hooks", []):
            if h.get("type") == "command" and h.get("command") == command:
                return  # already installed
    entries.append({"hooks": [{"type": "command", "command": command}]})

for event in ("Stop", "Notification"):
    ensure_event(event)

settings_path.write_text(json.dumps(data, indent=2) + "\n")
print(f"installed hooks into {settings_path}")
print(f"backup written to     {backup}")
PY
