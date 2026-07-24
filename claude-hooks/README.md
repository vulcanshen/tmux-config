# Claude Code → tmux Ready Signal

當 Claude Code 講完話或需要 input 時，讓 tmux window tab 亮起專屬顏色（例如藍色），這樣即使切到別的 window 也能一眼看到「Claude 在等妳」。

## 為什麼需要

tmux 內建的 activity / silence flag 是靠 tty output 判斷，Claude Code 有 spinner / caret 這種持續閃爍的 UI，會讓 `monitor-silence` 永遠不觸發，window tab 永遠橘色。

透過 Claude Code 的 `Stop` / `Notification` hooks，Claude 自己告訴 tmux「我完成/在等 input 了」，脫鉤 tty 動畫。

## 安裝

```bash
./install.sh
```

會做這些事：

1. `chmod +x mark-ready.sh`
2. 把兩個 hook（`Stop` / `Notification`）加到 `~/.claude/settings.json`
   - 現有其他 hooks / 設定會保留
   - 修改前寫 timestamped 備份（`settings.json.bak.YYYYMMDD-HHMMSS`）
3. Idempotent：重複跑不會重複安裝

安裝完後，開新的 Claude Code session 就會生效。

## 移除

```bash
./uninstall.sh
```

只移除本 repo 的 `mark-ready.sh` 對應的 hook entry，其他 hooks 不動。同樣會寫備份。

## 檔案

- `mark-ready.sh` — 實際被 Claude Code 呼叫的 script。跑 `tmux set-window-option @ready on`。
- `install.sh` — 把 hook 併入 `~/.claude/settings.json`。
- `uninstall.sh` — 反向操作。
- `README.md` — 本檔。

## tmux 側

`mark-ready.sh` 只負責打 flag。要讓 tmux 顯示對應顏色，`tmux.conf` 需要在 `window-status-format` 加一個 `#{?#{==:#{@ready},on},...,...}` 分支，並在切到該 window 時自動清 flag（例如透過 `after-select-window` hook）。這部分定義在主 tmux.conf 裡，不在此目錄。
