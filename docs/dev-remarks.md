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

## 狀態列與膠囊列的版面

視窗一多（同時開十幾個專案）膠囊列就破版，因此狀態列整體重新配置：

- **只放 tmux 本身的資訊**：CPU、記憶體、電量、日期時間全部移除（macOS 選單列
  已有），左右兩側從約 70 欄縮到不到 30 欄
- **只有當前 window 顯示名字**：12 個專案 window 的全名膠囊約需 166 欄，光外框
  （兩個圓角 + 兩個空白）每個就佔 4 欄；名字放不下是常態，所以非當前 window
  一律只顯示編號 + 燈號顏色，不再依寬度切換
- **`status-justify centre`**：原本的 `absolute-centre` 會直接把 list 畫在左右
  資訊之上（`format-draw.c`：「drawing them over the rest」），寬度不足就重疊；
  `centre` 把 list 限制在左右之間，放不下時走 tmux 內建捲動（`<` `>` marker，
  `list=focus` 保證當前 window 可見）。代價是置中基準變成左右之間的空白

寬度不足時的退讓順序：膠囊編號 → 拿掉外框的編號（每個省 2 欄）→ 隱藏 IP →
捲動。判斷式 `@status_caps_fit` / `@status_ip_fit` 用 `#{w:#{W:...}}` 以佔位字元
估算列表寬度，加上 status-left 與 IP 的寬度，跟 `client_width` 比較：

- 估算不直接量 `window-status-format`（它引用了判斷式本身，會自我遞迴）
- status-left 寬度用 `#{W:,#{w:#{T:status-left}}}` 量：只在當前 window 那一輪
  展開，zoom / copy 提示才會取到當前 window 的狀態，而不是被迴圈到的 window
- IP 寬度以常數 `@status_ip_w`（18）預留：tmux-primary-ip 只替換 status-right
  裡的 `#{primary_ip}`，別處量不到，在 status-right 裡量自己又會遞迴
- **坑**：巢狀 `#{W:}` 迴圈裡不能用 `loop_last_flag` — 外層跑到最後一個 window
  時，內層每一輪都會讀到 1，最後一個 window 的判斷因此跟其他 window 不同。
  估算一律每個 window 算一格分隔（多估 1 欄）
- 任何估算誤差的最壞結果都是提早或延後進入捲動，不會重疊

否決過：

- 平均截短名字：150 欄、12 個 window 時每個名字只剩 3 個字（`clo…`），認不出來
- 多行 status：行數是 session 選項、無法依寬度自動決定，切換時 pane 整體跳動，
  膠囊也不會自動折行
- 側邊欄：常駐版只能用 pane 模擬，會被平均排列、zoom、pane 導航波及且永久
  佔寬；popup 版是 modal，無法常駐
- 保留 absolute-centre 的混合模式：要整段複製 tmux 預設的 `status-format[0]`
  只為改 `align=`，tmux 升級時容易脫節

### 驗證方式：用巢狀 tmux 實際渲染狀態列

`display -p` 量得到寬度，但看不到實際畫面，而且從外部 shell 執行時沒有 client
context（`client_width` 為空、`#()` job 尚無輸出）。要看真實渲染，用獨立 socket
起一個外層 tmux，在裡面以本設定跑內層 tmux，再 `capture-pane` 外層：

```sh
tmux -L simout -f /dev/null new-session -d -s out -x 120 -y 6 \
  "env -u TMUX tmux -L simin -f sim.conf new-session -s test"
tmux -L simout resize-window -t out -x 80     # 換寬度
tmux -L simout capture-pane -p -t out | head -1
```

`sim.conf` 必須在**同一次載入**裡關掉 locku：內層 client 從不收按鍵，載入當下
若已閒置超過 `lock-after-time` 會立刻被鎖，事後再補 `set` 來不及：

```tmux
source-file ~/.config/tmux/tmux.conf
set -g lock-after-time 0
set -g lock-command true
set -gu @locked
```

## locku 鎖定整合的機制

tmux 的 lock 是 **client 層級的一次性動作** — session / server 沒有「已鎖定」的
持久狀態，關掉視窗重新 attach 的新 client 不會被鎖，等於繞過。持久化由
`@locked` flag + 兩條 hook 補上：

- locku 啟動時自己立 `@locked` flag（global）；`client-attached` 與
  `client-session-changed` 兩條 hook 檢查到 flag 就對新 client 補鎖
  （hook 用 `run -C` + `lock-client -t #{hook_client}` 明確鎖「觸發事件的那個
  client」— hook context 下未指定目標的 `lock-client` 對象有歧義）
- flag 生命週期完全歸 locku 管：啟動立旗（冪等）、密碼驗證成功清旗、
  tty 斷線死亡**不**清旗（fail-closed）。config 端不立旗，因為
  `lock-after-time` 的內部觸發路徑繞不過 config
- scope 採 **server 級**：tmux session 之間沒有隔離
  （`capture-pane -t` 可跨 session 讀取內容），session 級的鎖守不住承諾
- `lock-command` 用 `set -gF` 在 config 載入時烘入 `socket_path`：
  lock-command 執行時 tmux 不做 format 展開、也不提供識別 client 的環境變數，
  tty 與烘入的 socket path 是 lock 程式回呼 tmux 的唯一管道

**設定所有權**：鎖定相關設定（`lock-command`、`lock-after-time`、alias、hooks、
`prefix l`）由 locku 的設定畫面產生並覆寫 `~/.config/locku/locku.tmux.conf`，
`tmux.conf` 僅 `source-file -q` 讀入。未安裝 locku 的環境該檔不存在、整段靜默
略過 — 早期「開發版絕對路徑寫死在 tmux.conf、外人 clone 後觸發即失敗」的
可攜性問題由此解決。

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
