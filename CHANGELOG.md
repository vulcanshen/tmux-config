# Changelog

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
