#!/usr/bin/env bash
# Remove the Stop / Notification hooks installed by install.sh.
#
# Only removes hook entries whose command matches this repo's mark-ready.sh
# — other hooks in settings.json stay untouched. A timestamped backup is
# written before any change.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/mark-ready.sh"
SETTINGS="$HOME/.claude/settings.json"

if [ ! -f "$SETTINGS" ]; then
  echo "nothing to do: $SETTINGS does not exist"
  exit 0
fi

python3 - "$SETTINGS" "$SCRIPT" <<'PY'
import json, shutil, sys, time
from pathlib import Path

settings_path = Path(sys.argv[1])
command = sys.argv[2]

data = json.loads(settings_path.read_text() or "{}")
hooks = data.get("hooks", {})

changed = False
for event in ("Stop", "Notification"):
    entries = hooks.get(event)
    if not entries:
        continue
    new_entries = []
    for entry in entries:
        remaining = [
            h for h in entry.get("hooks", [])
            if not (h.get("type") == "command" and h.get("command") == command)
        ]
        if remaining == entry.get("hooks", []):
            new_entries.append(entry)
        elif remaining:
            entry["hooks"] = remaining
            new_entries.append(entry)
            changed = True
        else:
            changed = True  # entry becomes empty → drop it
    if new_entries:
        hooks[event] = new_entries
    else:
        hooks.pop(event, None)
        changed = True

if not changed:
    print("nothing to remove: hooks not present")
    raise SystemExit(0)

backup = settings_path.with_suffix(
    settings_path.suffix + f".bak.{time.strftime('%Y%m%d-%H%M%S')}"
)
shutil.copy2(settings_path, backup)

if not hooks:
    data.pop("hooks", None)

settings_path.write_text(json.dumps(data, indent=2) + "\n")
print(f"removed hooks from {settings_path}")
print(f"backup written to  {backup}")
PY
