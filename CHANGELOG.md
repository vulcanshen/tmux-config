# Changelog

## 2026-07-24

- **`prefix q` 取消 prefix pending state**：按下 prefix 後想反悔，按 `q` 即可退出（無 side effect）
  - 沒加 `prefix Escape`（Esc 在 Claude Code 是 interrupt 鍵，容易連按第二下 leak 到 pane 誤取消對話）
- **`prefix H/L` 改用 `w-nav` mode chain**：不再靠 `-r` timeout（2 秒容易斷）
  - 進入後可連按 `H/L` 切換 window，直到 `q`/`Esc` 手動退出
  - 跟 view / o-mode / r-mode 的操作 pattern 一致
- **視窗狀態燈號重新設計**（四狀態，優先級 bell > @ready > activity > default）
  - `bell`：紅色，收到 `^G`
  - `@ready`：綠色，Claude Code hook 主動通知「講完話 / 等妳 input」
  - `activity`：橘色（peach），有 tty 輸出且未靜默
  - `default`：灰色，包含「從未活動」與「活動結束（silence）」
  - `silence` 不再有獨立顏色 — 動完停了 = 平靜 = 跟預設同狀態
- **`claude-hooks/` 新增**：一鍵安裝的 Claude Code Stop/Notification hook
  - `install.sh` / `uninstall.sh`：idempotent、backup、非破壞性合併到 `~/.claude/settings.json`
  - `mark-ready.sh`：hook 觸發時把當前 pane 的 window 打上 `@ready=on`
  - 切到該 window 時透過 `set-hook -g after-select-window` 自動清 flag

## 2026-06-21

- **`prefix H/L`**：`previous-window` / `next-window`（`-r` repeatable，2s 內連按不需 prefix）
- **`prefix V`**：`select-layout even-vertical`
- **`prefix q/Q` 移除**：太容易誤觸 detach / kill-server；sub-mode 內的 `q` 退出功能保留

## 2026-05-31

- **View Mode 取代 Scroll Mode**（`prefix + u/d/k/j/G/gg`）
  - Alt-screen TUI（Claude Code / nvim / less）：把 key 傳給 app 讓它自己處理
  - Normal pane（shell prompt）：進入 tmux copy mode 真的滾 scrollback
  - Status bar 顯示 `copy` 或當前 key-table 名稱

## 2026-05-23

- **Keybinding 大重構：mode-based namespace**
  - `prefix o` → o-mode（open apps：`oo` zoom、`ok` km8、`og` lazygit、`of` spf）
  - `prefix s` → s-mode（search：`sw` window、`ss` session）
  - `prefix m` → m-mode（move：`mi` merge in、`mo` break out）
  - `prefix r` → r-mode（action namespace：`rl` reload、`rs` resize、`rn` rename、`rm` remove）
    - `rn` → rn-mode（`rnw` window、`rns` session）
    - `rm` → rm-mode（`rmw` window、`rmp` pane）
    - `rs` → rs-mode（`h/j/k/l` resize，可連按）
  - 每個 mode 內 `q` / `Esc` 退出
  - Status bar 加當前 mode indicator（橘色齒輪，緊接在 zoom 之後）
- **`prefix :`**：popup command line 取代原本 tmux 內建 command-prompt
- **Message style**：黑底 + matrix 綠字，加粗
- **`prefix ?`**：改用自訂 `keybindings.txt`（fzf 過濾），不再吐 tmux `list-keys` 全部內建
- **Wheel 進 copy-mode + `-e`**：滾輪自然進 copy mode，滾到最底自動退出
- **vim-tmux-navigator：Ctrl → Option**（`Meta+hjkl`）
  - Ctrl+h/l 在 shell 內跟 line editor 衝突，改用 Option 完全脫鉤
  - macOS 需 Ghostty 設 `macos-option-as-alt = true`

## 2026-05-15

- **Session 生命週期強化**
  - `detach-on-destroy off`：session 關閉時不會自動跳出 tmux
  - `session-closed` hook：session 關閉後自動彈 fzf picker 讓妳選其他 session
  - Entrance session pattern：開新 terminal 自動接管，第一 session 是暫時的
- **`prefix s`**：session picker（fzf popup，含「New Session」）
- **Battery 顏色**：tier 4–8 全部改 teal（避免亮綠色）
- **記憶體使用率**：改用 `vm_stat` 原生指令替代 `tmux-mem-cpu-load` 外掛
- **`prefix + k`**：kill-window（無確認）

## 2026-04-26

- 視窗標籤改為膠囊形狀（圓弧邊角）
  - Active：天藍色、Activity：綠色、Bell：紅色、Inactive：深灰
  - 視窗名稱另以灰底顯示，與索引顏色區隔
- 新增 scroll mode（`prefix + u/d` 進入），支援 vim 風格導航
  - `u/d` 翻頁、`j/k` 單行（送 `Option+j/k`）、`gg/G` 跳頂底、`q/Esc` 離開
- 新增 `prefix + l g` 開啟 lazygit popup（chord）
- 新增 `prefix + ?` 用 fzf 搜尋所有 keybindings
- 新增 `prefix + ,` 重新命名視窗（fzf popup，ESC 取消）
- 新增 `prefix + _` 全寬下方分割、`prefix + |` 全高右側分割
- Pane border 增強：左側目錄路徑、右側 git branch + 當前指令
  - 指令依類型顯示對應 icon（zsh、nvim、spf、bash、ssh、claude）
  - 非 git 目錄不顯示 git icon
- 將目錄路徑從第二行 status bar 移至 pane border（移除第二行）
- `repeat-time` 從 300ms 增至 2000ms
- 移除 extrakto 外掛
- 更新截圖

## 2026-04-14

- 新增 `prefix + Q` 關閉 tmux server（含確認提示）
- 新增 `renumber-windows` 設定，關閉 window 後自動重新編號

## 2026-04-12

- 將 CPU 和記憶體使用率從狀態列右側移至左側
- 移除狀態列項目之間的分隔線，呈現更簡潔的外觀
- 更新截圖

## 2026-04-03

- 新增第二行狀態列，顯示當前面板的完整路徑
- 將 prefix 從 `Ctrl+b` 改為 `` ` ``（backtick）
- 新增 `` ` `` + `p` 切換到上一個使用過的視窗（last-window）
- 改進 resize-pane 快捷鍵，使用自訂 key-table 支援自由切換方向連按
- 新增 README 說明：Resize Mode、Copy Mode、Extrakto 使用方式
- 新增附錄：實用的 Tmux 原生快捷鍵
- 將 `.claude/` 從 git 追蹤中移除
- GitHub repo 更名為 `tmux-config`
