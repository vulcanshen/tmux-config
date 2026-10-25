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
- **window 連成一條長條**：分開的膠囊光外框（兩個圓角 + 兩個空白 + 分隔）每個
  就佔 5 欄。改成每個 window 一段編號、一段目錄名，換色處用一格斜線 `U+E0BC`
  （前景色是左邊那段、背景色是右邊那段），開頭 `U+E0BA`、結尾 `U+E0BC`；帶目錄
  的 window 每個省 3 欄，只有編號的省 2 欄
- **寬度夠時每個 window 都顯示名字**，不夠時只剩當前 window 顯示
- **`status-justify right`**：長條靠右貼著 IP。原本的 `absolute-centre` 會直接把
  list 畫在左右資訊之上（`format-draw.c`：「drawing them over the rest」），寬度
  不足就重疊；`centre` / `right` 把 list 限制在左右之間，放不下時走 tmux 內建捲動
  （`<` `>` marker，`list=focus` 保證當前 window 可見）

斜線要知道前一個 window 最後一段的顏色，但 window 的 format 看不到相鄰的 window。
`@status_prev_tail` 是一個範本，`#{E:#{s|XX|#I|:@status_prev_tail}}` 先把 `XX`
換成自己的編號，再展開範本：`s` 的替換字串是在外層（這個 window）展開的，範本裡
的 `#{W:}` 迴圈因此能挑出「編號減 1」的那個 window，取它最後一段的顏色。這依賴
`renumber-windows on` 讓編號連續。相鄰兩個 window 同色時（兩個只有編號的灰色
window），實心斜線會看不見，改用細斜線 `U+E0BB`。

寬度不足時的退讓順序：所有名字 → 只有當前名字 → 隱藏 IP → 捲動。連成長條後，
只有編號的 window 每個佔 2 欄，跟原本「拿掉外框的編號」一樣窄，那一層退讓就拿掉了。
判斷式 `@status_names_fit` / `@status_ip_fit` 用 `#{w:#{W:...}}` 以佔位字元
估算列表寬度，加上 status-left 與 IP 的寬度，跟 `client_width` 比較：

- 估算不直接量 `window-status-format`（它引用了判斷式本身，會自我遞迴）
- status-left 寬度用 `#{W:,#{w:#{T:status-left}}}` 量：只在當前 window 那一輪
  展開，zoom / copy 提示才會取到當前 window 的狀態，而不是被迴圈到的 window
- IP 寬度以常數 `@status_ip_w`（18）預留：tmux-primary-ip 只替換 status-right
  裡的 `#{primary_ip}`，別處量不到，在 status-right 裡量自己又會遞迴
- **坑**：巢狀 `#{W:}` 迴圈裡不能用 `loop_last_flag` — 外層跑到最後一個 window
  時，內層每一輪都會讀到 1，最後一個 window 的判斷因此跟其他 window 不同。
  結尾斜線改用 `window_end_flag` 判斷，它是 window 自己的屬性，不受迴圈影響
- 任何估算誤差的最壞結果都是提早或延後進入捲動，不會重疊

否決過：

- 平均截短名字：150 欄、12 個 window 時每個名字只剩 3 個字（`clo…`），認不出來
- 多行 status：行數是 session 選項、無法依寬度自動決定，切換時 pane 整體跳動，
  膠囊也不會自動折行
- 側邊欄：常駐版只能用 pane 模擬，會被平均排列、zoom、pane 導航波及且永久
  佔寬；popup 版是 modal，無法常駐
- 保留 absolute-centre 的混合模式：要整段複製 tmux 預設的 `status-format[0]`
  只為改 `align=`，tmux 升級時容易脫節
- 長條的其他收邊字元：開頭用三角 `U+E0B2`、交界用圓角 `U+E0B4`（一串凸起，不順）、
  梯形 `U+E0D2` / `U+E0D4`、像素 `U+E0C4`，以及編號左右用不同字元的組合；斜線雖然
  有角，但最簡潔。預覽各種組合時，在 pane 裡印出真彩色的樣本比較快（Claude Code
  的畫面顯示不出 Nerd Fonts 的私用區字元）

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

## popup 的框由 fzf 畫

狀態列放在上方時，tmux（3.7c 實測）保護 popup 的範圍會往下偏一列。pane 以同步輸出
（DECSET 2026）、scroll region 捲動或插入／刪除列的方式更新時，tmux 會整塊重畫 pane，
這時 popup 的第一列沒被保護、被 pane 內容蓋掉，popup 正下方那一列反而被擋住、停在
舊內容。逐格寫入、清行（EL、ECH）不受影響；狀態列改放下方就不會偏，跟 pane 邊框
標題列無關。

Claude Code 的 fullscreen 模式用同步輸出，搭配持續重畫的側邊欄（ccdrawu），popup
一開著上邊框就被吃掉。縮窄 popup 沒有用：只改側邊欄那一塊，tmux 也是整個 pane 重畫。

因此所有 fzf popup 改成：

- `display-popup -B` 不讓 tmux 畫框，改由 fzf 畫，並在框的上方留一列給 tmux 蓋
- 清單類（`prefix ?`、`prefix s w`、`prefix m i`、session picker）：`--border=rounded`
  加 `--margin=1,0,0,0` 留白
- 單行輸入框（`prefix :`、`prefix p`、rename、新增 session）：`--input-border` 只框
  輸入列，框上方空的清單區就是留給 tmux 蓋的那一列，popup 4 列、框維持原本的 3 列。
  不能用 margin：fzf 至少要留一列清單區，只給 4 列時會先省掉 margin，框頂又被蓋掉；
  給 5 列則框裡多一列空白。新增 session 因此不用 `--reverse`（輸入列要在清單區下面），
  名稱重複的警告改放在框的標題，不另佔一列
- popup 開著時，框正下方那一列不會更新（中文字剛好跨在框的左緣時會少一個字），
  關掉 popup 就恢復
- 哪天 tmux 修好這個偏移，留白那一列只會變成框上方的一條空白
- 全螢幕 popup（o-mode）不受影響：第一列落在狀態列上，pane 重畫碰不到

否決過：

- 改用狀態列上的 `command-prompt`（`prefix p` 試過一版）：不碰 pane 所以不受影響，
  但輸入時狀態列整條被取代，`status-keys vi` 下 Esc 也不會直接取消，user 選擇保留 popup
- 狀態列改放下方：可以根治，但整個版面都要跟著改

### 驗證方式：在巢狀 tmux 裡模擬持續重畫的 pane

沿用上面「用巢狀 tmux 實際渲染狀態列」的做法，內層 pane 改跑一個模擬 Claude Code＋
側邊欄的腳本，再開 popup、`capture-pane` 外層，看框是否完整：

```zsh
printf '\e[?1049h'
for r in {1..16}; do printf '\e[%d;1H第%d列 中文寬字元測試中文寬字元測試' $r $r; done
t=0
while true; do
  t=$((t+1)); printf '\e[?2026h'   # synchronized output, like Claude Code
  for r in {1..16}; do printf '\e[%d;100Hside%02d-t%-5d' $r $r $t; done
  printf '\e[?2026l'; sleep 0.2
done
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
- popup 的 `-E` 指令不會展開 tmux format，框上的目錄標題改在 shell 裡用 `pwd` 算；
  超過 40 字只留結尾（`…` 開頭），因為 fzf 會把放不下的標題整個藏掉
- 曾考慮過「送回當前 pane 執行」（send-keys）：pane 是 shell 時體驗最好，
  但 pane 跑 TUI（Claude Code、vim）時按鍵會被 TUI 吃掉造成誤動作，
  判斷分流又增加複雜度，最終捨棄

## session 關閉後的 picker 只給失去 session 的 client

`detach-on-destroy off` 讓 session 被關掉時，client 移到別的 session 而不是離開
tmux；`session-closed` hook 再呼叫 vulcanzsh 的 `tmux_on_session_close` 彈出 picker。
原本任何 session 關閉都會彈，其他專案的自動化測試在同一個 server 上建立、關閉暫存
session 時，picker 就會莫名彈出來。

`session-closed` 觸發時，tmux 只說哪個 session 關了，分不出有沒有 client 在上面。
實測各事件的順序與 `client_last_session`：

| 情境 | 事件順序 | `client_last_session` |
| :--- | :--- | :--- |
| client 所在的 session 被關 | `client-session-changed` → `session-closed` | 空 |
| 正常切換 session | `client-session-changed` | 前一個 session |
| 新 terminal attach | `client-session-changed` → `client-attached` | 空 |
| 背景 session 關閉 | `session-closed` | — |

因此：

- `client-session-changed` 在 `client_last_session` 為空時，把 `@session_lost` 設成
  該 client；正常切換時設成空字串
- `client-attached` 清掉 `@session_lost`（attach 也會留下同樣的標記）
- `tmux_on_session_close` 讀完就清掉：沒有標記就不彈；有標記就用 `display-popup -c`
  彈在那個 client 上。同時有多個 terminal attach 時，不指定 client 會彈到別的 terminal
- tmux.conf 與 vulcanzsh 要一起更新：只有新版 vulcanzsh 時，picker 永遠不會彈

**坑**：`set-hook -g <hook> …` 不指定位置時，會把該 hook 整組換掉。locku 的補鎖 hook
掛在 `[90]`，這裡的 hook 用固定位置 `[10]`，不論載入順序都不會互相覆蓋。
`session-closed` 也一樣：`[5]` 是 o-mode 工具的收尾（見下一節），`[10]` 是 picker。
改用固定位置時，執行中的 server 會留著舊的 `[0]`，要 `set-hook -gu "session-closed[0]"`
拿掉，不然 picker 會跑兩次。

## o-mode 工具的縮小：popup 只是接到隱藏的 session

popup 關掉時，裡面的程式就跟著結束。tmux 沒有「藏起 popup」的指令；3.7 的浮動 pane
目前也只能建立，沒有隱藏與顯示。所以工具改在隱藏的 session 裡執行，popup 只負責
attach 過去（`scripts/o-popup.sh`）：

- session 名稱是 `_o<session id 的數字>_<工具>`，每個 session 每個工具一份。建立時
  設 `status off`、`detach-on-destroy on`、`pane-border-status off`
- popup 裡執行 `env -u TMUX tmux -S <socket> -T RGB attach -f active-pane`：
  - 拿掉 `TMUX`，否則 attach 會被當成巢狀而拒絕
  - popup 的終端是 `tmux-256color`，沒有 RGB，工具的顏色會掉成 256 色
  - `active-pane` 在只有一個 pane 的 session 裡沒有作用，只用來標記「這是 popup 的 client」
- 縮小（`prefix o o`）就是 `detach-client`：attach 結束、popup 關閉，工具留在背景。
  工具正常結束時 session 跟著結束，`detach-on-destroy on` 讓 popup 的 client 離開，
  popup 也就關了；沒有這個設定，client 會被移到別的 session，變成 popup 裡又套一層 tmux
- popup 關閉後，腳本檢查隱藏 session 還在不在；還在就在所屬 session 設 `@o_<工具>`，
  pane 標題列據此顯示
- `prefix o o` 看 client 所在的 session 決定行為：在隱藏 session 裡就縮小，其他地方
  照舊 zoom。用 `prefix (` `)` 切進隱藏 session 的 client 有 `client_last_session`，
  改為切回去，而不是 detach 離開 tmux

收尾（`session-closed[5]` 執行 `o-popup.sh --gc`）：

- 所屬 session 關掉時，結束它的隱藏 session；工具在背景自己結束時，拿掉留下的標記
- client 所在的 session 被關掉時，tmux 會把它移到最近用過的 session，可能正是隱藏
  session。收尾先把這種 client（沒有 `active-pane` 標記）移到工具所屬的 session，
  所屬 session 也不在了就移到最近用過的其他 session，然後才結束隱藏 session；
  順序反過來，client 會跟著被 detach 離開 tmux
- 收尾必須排在 picker 的 hook（`[10]`）之前，而且要等它跑完（不加 `-b`）：picker 的
  hook 會一直等使用者選完，排在後面的收尾就跑不到
- 移動 client 會觸發 `client-session-changed`，被當成正常切換而清掉 `@session_lost`，
  收尾移完要補回去，失去 session 時 picker 才會照常彈出
- vulcanzsh 的 session picker 列表與「剩幾個 session」的計數，都要排除 `_o` 開頭的
  session，兩個 repo 要一起更新

**坑**：`set -t "=name"` 會回報找不到 session（`has-session -t "=name"` 卻可以）；
選項與 `send-keys` 的目標要寫成 `=name:`。

縮小鍵否決過：

- 單按 `Esc`：filu、kbu、webu、lazygit 都用 `Esc` 退回上一層
- `prefix Esc`：按了 prefix 想取消時習慣按 `Esc`，會變成誤觸
- 連按兩下 `Esc`：想快速退兩層時會誤觸

標記的樣式：放在最右上那條 pane 標題列、branch 的左邊，往左延伸。它就在狀態列的
window 長條正下方，用同樣的斜線長條會看混，所以只用文字：熱鍵字母藍色加粗，其他
字母 `subtext0`，工具之間的 `|` 用 `overlay0`。試過並否決的：crust 底（跟終端機
背景同色，看不出來）、每個工具一顆圓角小膠囊、斜線長條。

已知限制：

- 工具停在第一次開啟時的目錄
- 窄 pane 裡左邊的目錄會蓋住右邊標題的開頭；原本目錄和 branch 就會互相重疊，
  標記只是讓右邊那段變長，比較早碰到

### 驗證方式：巢狀 tmux 裡按真的鍵

用「狀態列與膠囊列的版面」一節的巢狀 tmux，對外層 `send-keys` 送 `` ` `` `o` `g`，
就是在內層 client 按下 `prefix o g`；`capture-pane` 外層看 popup，`list-sessions`、
`show -t <session> @o_lazygit` 看狀態。要測的情境：開啟、縮小、叫回（狀態保留）、
在工具裡結束、別的 session 被關、所屬 session 被關、從 `prefix )` 切進隱藏 session。
`sim.conf` 每次由測試腳本產生，暫存目錄被清掉時才不會讓內層 tmux 不載設定、
按鍵全部沒有作用。

## window 熱鍵：第 10 個以後用字母

tmux 預設的 `prefix 0`～`9` 一按就切換，不會等第二個數字，第 10 個 window 永遠到不了。
第 10 個以後改用字母，順序是小寫、再大寫，跳過 prefix 底下已有用途的字母：

- 字母清單只有一份：`@win_keys`。載入設定時 `scripts/window-keys.sh` 依序把 `0`～`9`
  與清單裡的字母綁到 window 0、1、2…，狀態列也從同一份清單取字母顯示
- 清單是在決定當下照「沒有綁定」挑的；之後要把其中一個字母拿去綁別的功能，要從清單
  拿掉，否則誰在 `tmux.conf` 裡比較後面，誰就蓋掉另一個
- 狀態列的字母用 `#{=1:#{=-K:@win_keys}}` 取：先留最後 K 個字（K = 清單長度 −
  (編號 − 10)），再取第一個。用正規表示式 `#{s/^.{N}(.).*/\1/:…}` 取不行，pattern 裡
  的 `{` 會讓 format 解析失敗
- 寬度估算也用同一個標籤（`@win_label`），字母只佔 1 欄
- 不存在的 window：綁定先用 `#{W:#{?#{==:#{window_index},N},1,}}` 判斷，不存在就跳
  `scripts/warn-popup.sh` 畫的紅框。框一樣畫在一列空白下方（見「popup 的框由 fzf 畫」），
  1.5 秒或按任意鍵關閉；popup 會吃掉那個鍵，不會漏進 pane

為了騰出字母：`prefix c`（copy mode）拿掉，copy mode 改從 view mode 進；View Mode 的
`prefix u/d/k/j/G/g` 改成 `prefix v` 進入後再按。tmux 預設的 `f`（找 window）、`i`
（顯示資訊）、`n`（下一個 window）、`z`（zoom）還留著。

## View Mode：`prefix v` 之後的按鍵

`prefix v` 只負責進入：全螢幕 TUI 只切到 `view` 按鍵表，一般 shell pane 同時進 copy
mode。`view` 表裡的鍵用 `pane_in_mode` 判斷，而不是 `alternate_on`：

- 在 copy mode 裡（shell pane，或 TUI 按了 `v` 之後）移動 tmux 的游標，其他時候把
  PageUp、`M-k` 這類鍵送給 TUI 自己翻頁。用 `alternate_on` 判斷的話，TUI 進了 copy
  mode 之後 `k` `j` 還是送 `M-k` `M-j`，copy mode 不認得，游標動不了
- `v` 是整行選取（`select-line`）：view 表只有上下移動的鍵，逐字選取的起點只能是游標
  所在的那一欄，實測複製出來只有零碎的幾個字
- `view` 表沒綁的鍵（`h` `l` `w` `b`…），tmux 會離開這個表、改到 root 表重找；pane
  在 copy mode 時就落到 copy-mode-vi，那裡的 `v` / `y` 是逐字選取與複製
