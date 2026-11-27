#!/bin/sh
# Move the client to the next or previous session in name order, wrapping around like switch-client -n / -p, but
# skipping the hidden o-mode tool sessions (_o<id>_<tool>, see o-popup.sh)
#   session-nav.sh next|prev <client>
dir=$1 client=$2
# display -c only says where a message goes; its #{session_name} is not the client's session
current=$(tmux list-clients -F '#{client_name} #{client_session}' | awk -v c="$client" '$1 == c { sub(/^[^ ]* /, ""); print }')
target=$(tmux list-sessions -F '#{session_name}' | grep -v '^_o[0-9]*_' | awk -v cur="$current" -v dir="$dir" '
  { name[NR] = $0; if ($0 == cur) at = NR }
  END { if (!at || NR < 2) exit; print name[dir == "next" ? at % NR + 1 : (at + NR - 2) % NR + 1] }')
# No other session to go to (only one left): stay, like switch-client -n / -p, without an error
[ -z "$target" ] || tmux switch-client -c "$client" -t "=$target"
