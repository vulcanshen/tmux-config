# Claude Code → tmux 狀態訊號

讓 tmux window 標籤的顏色跟著 Claude Code 的狀態走：處理中是橘色，講完或在等妳回答時是綠色。即使切到別的 window，也能一眼看出哪個 Claude 在忙、哪個在等妳。

## 為什麼需要

tmux 內建的 activity / silence 旗標只看 pane 有沒有輸出。閒著的 Claude Code 也會重畫畫面（statusline、標題），所以沒在做事也會變橘；silence 旗標一設上又要等切進去才會清掉，真的在跑反而可能是灰的。

透過 Claude Code 的 hooks，由 Claude 自己告訴 tmux「開始處理了」「講完了」「在等妳回答」，不再從輸出猜。

## 安裝

```bash
./install.sh
```

會做這些事：

1. `chmod +x mark-ready.sh`
2. 把 `SessionStart`、`UserPromptSubmit`、`PreToolUse`、`Stop`、`StopFailure`、`Notification`、`SessionEnd` 七個 hook 加到 `~/.claude/settings.json`
   - 現有其他 hooks / 設定會保留
   - 修改前寫 timestamped 備份（`settings.json.bak.YYYYMMDD-HHMMSS`）
3. Idempotent：重複跑不會重複安裝

安裝後立即生效，已經在跑的 Claude Code 也會套用。

## 移除

```bash
./uninstall.sh
```

只移除本 repo 的 `mark-ready.sh` 對應的 hook entry，其他 hooks 不動。同樣會寫備份。

## 檔案

- `mark-ready.sh` — 被 Claude Code 呼叫的 script。在 pane 上記錄 Claude 是否在處理（`@cc`），講完或等妳回答時把 window 標成綠色（`@ready`）。
- `install.sh` — 把 hooks 併入 `~/.claude/settings.json`。
- `uninstall.sh` — 反向操作。
- `README.md` — 本檔。

## tmux 側

`mark-ready.sh` 只負責打 flag。顏色、切進 window 時清除綠色、離開時檢查 `Esc` 中斷，都定義在主 `tmux.conf` 與 `scripts/cc-leave.sh`，不在此目錄。運作細節見 `docs/dev-remarks.md`。
