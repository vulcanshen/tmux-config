#!/bin/zsh
# A red warning box for a display-popup -B (4 rows, the message's width + 6): the box is drawn here below one blank row,
# like the fzf popups (see "popup 的框由 fzf 畫" in docs/dev-remarks.md). Closes after 1.5s or on any key
#   warn-popup.sh <message>
msg="✗ $1"
red=$'\e[38;2;243;139;168m' bold=$'\e[1m' reset=$'\e[0m'
bar=${(l:$(( ${#1} + 4 ))::─:)}
printf '\e[?25l\n%s╭%s╮\n│ %s%s%s%s │\n╰%s╯%s' "$red" "$bar" "$bold" "$msg" "$reset" "$red" "$bar" "$reset"
read -rs -k1 -t 1.5
