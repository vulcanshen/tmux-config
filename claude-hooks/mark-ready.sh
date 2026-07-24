#!/usr/bin/env bash
# Called by Claude Code's Stop / Notification hooks.
# Marks the current tmux pane's window as "ready" so the window tab
# picks up the @ready style in status-format (a distinct color meaning
# "Claude is waiting for you").
#
# No-op when not inside a tmux pane.

[ -n "$TMUX_PANE" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

tmux set-window-option -t "$TMUX_PANE" @ready on >/dev/null 2>&1 || true
