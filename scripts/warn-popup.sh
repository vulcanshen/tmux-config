#!/bin/zsh
# A red warning box in the middle of the client that does not hold up the next key: a key pressed before it closes
# by itself (1.5s) closes it and is passed on. The prefix puts the client in the prefix table, Esc only closes, any
# other key goes to the pane. The box is drawn here below one blank row, like the fzf popups (see "popup 的框由 fzf 畫"
# in docs/dev-remarks.md)
#   warn-popup.sh <client> <message>          open the popup on the client (run-shell gives the client name)
#   warn-popup.sh <client> <message> --box    inside the popup
client=$1
if [[ $3 != --box ]]; then
  tmux display-popup -c "$client" -B -w $(( ${#2} + 6 )) -h 4 -x C -y C -E "${(q)0} ${(q)client} ${(q)2} --box"
  exit
fi
red=$'\e[38;2;243;139;168m' bold=$'\e[1m' reset=$'\e[0m'
bar=${(l:$(( ${#2} + 4 ))::─:)}
printf '\e[?25l\n%s╭%s╮\n│ %s✗ %s%s%s │\n╰%s╯%s' "$red" "$bar" "$bold" "$2" "$reset" "$red" "$bar" "$reset"
read -rs -k1 -t 1.5 key || exit 0
case $key in
  $'\e' | $'\x03') ;;
  "$(tmux show -gv prefix)") tmux switch-client -c "$client" -T prefix ;;
  *) tmux send-keys -t "$(tmux display -p -c "$client" '#{pane_id}')" -l -- "$key" ;;
esac
