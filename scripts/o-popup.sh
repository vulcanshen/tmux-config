#!/bin/sh
# o-mode tools in a popup that prefix o o can hide: the tool runs in a hidden session (one per session and tool) and
# the popup only attaches to it, so hiding is a detach and the tool keeps running. When the tool quits, its session
# ends and the popup closes for good. A hidden tool is marked on its session as @o_<name>, shown on the pane border
#   o-popup.sh <name> <session id> <dir> <client> <command>   open the tool, or bring a hidden one back
#   o-popup.sh --gc                                          drop hidden sessions and marks left behind

if [ "$1" = --gc ]; then
  ids=$(tmux list-sessions -F '#{session_id}')
  # A client whose session closed may have been moved into a hidden session (the most recently used one): send it to
  # that tool's session, or the newest other one. A popup's own client is tagged active-pane and stays. The switch
  # looks like an ordinary one to client-session-changed, so the lost-session mark for the picker is put back
  lost=$(tmux show -gqv @session_lost)
  tmux list-clients -F '#{client_name} #{client_flags} #{session_name}' | while read -r client flags session; do
    case $session in _o[0-9]*_*) ;; *) continue ;; esac
    case $flags in *active-pane*) continue ;; esac
    id=${session#_o}
    id=${id%%_*}
    if printf '%s\n' "$ids" | grep -qxF "\$$id"; then
      target="\$$id"
    else
      target=$(tmux list-sessions -F '#{session_activity} #{session_id} #{session_name}' | grep -v ' _o[0-9]*_' \
        | sort -rn | head -1 | cut -d' ' -f2)
    fi
    [ -n "$target" ] && tmux switch-client -c "$client" -t "$target"
    [ "$lost" = "$client" ] && tmux set -g @session_lost "$client"
  done
  # A hidden session whose session is gone
  tmux list-sessions -F '#{session_name}' | grep '^_o[0-9]*_' | while read -r hidden; do
    id=${hidden#_o}
    id=${id%%_*}
    printf '%s\n' "$ids" | grep -qxF "\$$id" || tmux kill-session -t "=$hidden"
  done
  # A mark whose tool quit while hidden
  for sid in $ids; do
    tmux show -t "$sid" 2>/dev/null | sed -n 's/^@o_\([^ ]*\) .*/\1/p' | while read -r name; do
      tmux has-session -t "=_o${sid#\$}_$name" 2>/dev/null || tmux set -t "$sid" -u "@o_$name"
    done
  done
  exit 0
fi

name=$1 parent=$2 dir=$3 client=$4 cmd=$5
hidden="_o${parent#\$}_$name"
if ! tmux has-session -t "=$hidden" 2>/dev/null; then
  # No idle lock of its own: its activity is passed on to the session behind the popup, which does the locking.
  # The only client here is the one in the popup, which answers no colour queries: without a background of its own
  # tmux has no answer to OSC 11, and without a palette it passes OSC 4 on to the popup and holds every later reply
  # (OSC 11, DA1) until that times out (about 500ms). So the window gets the terminal's background and palette, set
  # in the same command as the session so they are there before the tool's first query
  set -- new-session -d -s "$hidden" -c "$dir" "$cmd" \; \
    set -t "=$hidden:" status off \; \
    set -t "=$hidden:" detach-on-destroy on \; \
    set -t "=$hidden:" lock-after-time 0 \; \
    set -w -t "=$hidden:" pane-border-status off \; \
    set -w -t "=$hidden:" window-style "bg=$(tmux show -gv @term_bg)"
  i=0
  for colour in $(tmux show -gv @term_palette); do
    set -- "$@" \; set -w -t "=$hidden:" "pane-colours[$i]" "$colour"
    i=$((i + 1))
  done
  tmux "$@"
fi
tmux set -t "$parent" -u "@o_$name"

# Keys typed in the popup count as activity only for the hidden session, so the session behind it would reach
# lock-after-time while the tool is in use. While the popup is open, whenever the hidden session has seen keys,
# switch the client to the session it is already on: tmux counts that as activity and nothing changes on screen.
# The switch runs the client-session-changed hooks, so the lost-session mark for the picker is put back after it
idle=$(tmux display -p -t "$parent" '#{lock-after-time}')
if [ "${idle:-0}" -gt 0 ]; then
  every=$((idle / 2))
  [ "$every" -gt 30 ] && every=30
  [ "$every" -lt 1 ] && every=1
  (
    last=$(tmux display -p -t "=$hidden:" '#{session_activity}')
    while sleep "$every"; do
      now=$(tmux display -p -t "=$hidden:" '#{session_activity}') || exit
      [ "$now" = "$last" ] && continue
      last=$now
      lost=$(tmux show -gqv @session_lost)
      tmux switch-client -c "$client" -t "$parent"
      if [ -n "$lost" ]; then tmux set -g @session_lost "$lost"; else tmux set -gu @session_lost; fi
    done
  ) > /dev/null 2>&1 &
  watcher=$!
fi

# TMUX is unset so the attach is not refused as nested; the popup's terminal is tmux-256color, so ask for RGB.
# active-pane changes nothing in a one-pane session, it only tags the popup's client for --gc
sock=$(tmux display -p '#{socket_path}')
tmux display-popup -c "$client" -b rounded -w 100% -h 100% -S "fg=#89b4fa" \
  -E "env -u TMUX tmux -S '$sock' -T RGB attach -f active-pane -t '=$hidden'"
[ -n "$watcher" ] && kill "$watcher" 2>/dev/null
# The popup is closed: the tool is hidden if its session is still there
if tmux has-session -t "=$hidden" 2>/dev/null; then
  tmux set -t "$parent" "@o_$name" 1
fi
