#!/usr/bin/env bash
# Called by Claude Code's hooks (install.sh lists them); the event name comes in the JSON on stdin.
# Keeps two tmux flags in step with Claude, which the window tab in tmux.conf turns into colours:
#   pane option @cc       run while Claude is working on a turn, idle once it stops; unset when Claude exits
#   window option @ready  on when Claude finishes or needs an answer, unless the window is on screen right now
#
# No-op when not inside a tmux pane.

[ -n "$TMUX_PANE" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

input=$(cat)
field() { printf '%s' "$input" | sed -n "s/.*\"$1\" *: *\"\([^\"]*\)\".*/\1/p" | head -n 1; }

state() { tmux set -p -t "$TMUX_PANE" @cc "$1" >/dev/null 2>&1; }
# The window is on screen when it is its session's current window and the session has a client
ready() {
  [ "$(tmux display -p -t "$TMUX_PANE" '#{&&:#{window_active},#{session_attached}}' 2>/dev/null)" = 1 ] ||
    tmux set -w -t "$TMUX_PANE" @ready on >/dev/null 2>&1
}

case "$(field hook_event_name)" in
  SessionStart) state idle ;;
  UserPromptSubmit) state run ;;
  # Tools a subagent calls keep coming after the turn ends when the agent runs in the background
  PreToolUse) [ -n "$(field agent_id)" ] || state run ;;
  Stop|StopFailure) state idle; ready ;;
  # Only the notifications that wait on an answer; not the reminder after 60s of idling, which comes after Stop
  Notification)
    case "$(field notification_type)" in
      permission_prompt|worker_permission_prompt|elicitation_dialog|elicitation_url_dialog|agent_needs_input) ready ;;
    esac ;;
  SessionEnd) tmux set -pu -t "$TMUX_PANE" @cc >/dev/null 2>&1 ;;
esac
exit 0
