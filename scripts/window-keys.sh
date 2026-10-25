#!/bin/sh
# Bind prefix + 0-9 and then the given letters to windows 0, 1, 2, ... in that order; a key whose window does not
# exist pops up a warning in the middle of the screen instead of tmux's own error
#   window-keys.sh <letters for windows 10 and up>
i=0
for k in $(printf '%s' "0123456789$1" | sed 's/./& /g'); do
  msg="No window $k"
  tmux bind "$k" if -F "#{W:#{?#{==:#{window_index},$i},1,}}" "select-window -t :=$i" \
    "display-popup -B -w $((${#msg} + 6)) -h 4 -x C -y C -E \"~/.config/tmux/scripts/warn-popup.sh '$msg'\""
  i=$((i + 1))
done
