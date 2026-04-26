# Changelog

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
