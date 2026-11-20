#!/bin/sh
# The window the client just left (a window id): a Claude pane still marked as working whose screen no longer shows
# Claude's working line ("✻ Pondering… (12s · ↓ 1.2k tokens)") is marked idle. Pressing Esc to stop Claude runs no
# hook, so without this the window would stay orange.
[ -n "$1" ] || exit 0
for pane in $(tmux list-panes -t "$1" -F '#{?#{==:#{@cc},run},#{pane_id},}' 2>/dev/null); do
  tmux capture-pane -p -t "$pane" | grep -qE '^(·|✢|✳|✶|✻|✽|\*) [^ ].*… \(' || tmux set -p -t "$pane" @cc idle
done
