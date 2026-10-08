# 開發者備忘

README 只放使用者需要知道的；運作機制、設計決定與理由放這裡。

## 視窗標籤的 `@ready` 綠燈：為什麼不用 `monitor-silence`

tmux 內建的 `monitor-silence` 靠 tty 輸出停頓判斷「做完了」，但 spinner 型 TUI
（Claude Code、k9s 等）會持續寫 tty 畫動畫，silence 永遠不會觸發 — 對這類程式
tmux 端的任何推斷都是盲的，訊號必須由應用程式自己發出。

因此「Claude 等你」的訊號改由 Claude Code 的 `Stop` / `Notification` hook 主動
打上 window 的 `@ready=on`（`claude-hooks/mark-ready.sh`），tmux 端只負責顯示與清除：

- 優先級 `bell > @ready > activity > default` — `@ready` 高於 activity，
  spinner 繼續寫 tty 也不會把綠燈蓋回橘色
- `after-select-window` hook 在切到該 window 時自動清掉 `@ready`（看過即讀取）
- silence 沒有獨立顏色：「活動後靜默」與「從未活動」是同一個終態
  （都是「沒東西要看」），一律收斂到灰色

## locku 鎖定整合的機制

tmux 的 lock 是 **client 層級的一次性動作** — session / server 沒有「已鎖定」的
持久狀態，關掉視窗重新 attach 的新 client 不會被鎖，等於繞過。持久化由
`@locked` flag + 兩條 hook 補上：

- locku 啟動時自己立 `@locked` flag（global）；`client-attached` 與
  `client-session-changed` 兩條 hook 檢查到 flag 就對新 client 補鎖
- flag 生命週期完全歸 locku 管：啟動立旗（冪等）、密碼驗證成功清旗、
  tty 斷線死亡**不**清旗（fail-closed）。config 端不立旗，因為
  `lock-after-time` 的內部觸發路徑繞不過 config
- scope 採 **server 級**：tmux session 之間沒有隔離
  （`capture-pane -t` 可跨 session 讀取內容），session 級的鎖守不住承諾
- `lock-command` 用 `set -gF` 在 config 載入時烘入 `socket_path`：
  lock-command 執行時 tmux 不做 format 展開、也不提供識別 client 的環境變數，
  tty 與烘入的 socket path 是 lock 程式回呼 tmux 的唯一管道

**已知限制**：`lock-command` 目前指向本機開發版的絕對路徑，公開 repo 的使用者
clone 後這段設定不可用（觸發即失敗、立即解鎖）。待 locku 發佈後由其安裝器
處理（偵測環境、寫入正確路徑），tmux.conf 這邊不做 workaround。

## `prefix p`（command prompt）的設計取捨

定位是 **fire-and-forget 發射台**（`idea .`、`open .` 這類「我知道我要幹嘛」的
指令），不是觀察窗 — 需要看輸出的場景本來就該開 pane。因此：

- 成功不顯示任何輸出，popup 直接關閉；失敗才在 status line 跳紅字提示
  （exit code + 錯誤第一行，`display-message -d 0` 停到按鍵為止）
- 指令**同步執行**（否則抓不到 exit code），長駐型指令會卡住 popup，
  屬預期外用法
- 用 `zsh -ic` 執行讓 alias / function 可用；若 rc 啟動太慢可拿掉 `-i`
- 曾考慮過「送回當前 pane 執行」（send-keys）：pane 是 shell 時體驗最好，
  但 pane 跑 TUI（Claude Code、vim）時按鍵會被 TUI 吃掉造成誤動作，
  判斷分流又增加複雜度，最終捨棄
