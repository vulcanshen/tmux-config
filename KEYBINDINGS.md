# Tmux Keybindings Cheatsheet

> Prefix key: `` ` `` (backtick)

## Window/Pane 分割
| Key | Action |
|---|---|
| `prefix -` | 上下分割（同 pane 路徑） |
| `prefix _` | 上下分割（全寬） |
| `prefix \` | 左右分割 |
| `prefix \|` | 左右分割（全寬） |

## Window 操作
| Key | Action |
|---|---|
| `prefix t` | 新 window |
| `prefix D` | 關閉 window（無確認） |
| `prefix p` | 上一個 window |
| `prefix w` | window 選擇器（fzf popup） |
| `prefix ,` | 改 window 名稱（popup，空字串重置為自動命名） |
| `prefix B` | 把 pane 拉出來成獨立 window（break） |
| `prefix M` | 把 pane 合併到指定 window（merge popup） |

## Pane 操作
| Key | Action |
|---|---|
| `prefix x` | 關閉 pane（無確認） |
| `prefix v` | 進 copy mode（vi） |

### Copy Mode 內
| Key | Action |
|---|---|
| `v` | 開始選取 |
| `y` | copy selection |

## Resize Pane
進 resize mode 後可連按 HJKL 不需重按 prefix。

| Key | Action |
|---|---|
| `prefix H` | 向左 |
| `prefix J` | 向下 |
| `prefix K` | 向上 |
| `prefix L` | 向右 |

## App Popups
先按 `prefix o` 進入 open mode，再按下列鍵。

| Key | Action |
|---|---|
| `prefix o o` | zoom toggle |
| `prefix o f` | 開 spf (fullscreen) |
| `prefix o k` | 開 km8 (fullscreen) |
| `prefix o g` | 開 lazygit (fullscreen) |

## Session 操作
| Key | Action |
|---|---|
| `prefix s` | session 選擇器（含「New Session」選項） |
| `prefix .` | 改 session 名稱 |
| `prefix q` | detach 並關掉客戶端 |
| `prefix Q` | 殺整個 tmux server（有確認） |

## Scroll Mode
按下後自動進 mode，可連按。mode 內按 `q` 或 `Esc` 退出。

| Key | Action |
|---|---|
| `prefix u` | page up |
| `prefix d` | page down |
| `prefix k` | 上一行 |
| `prefix j` | 下一行 |
| `prefix G` | 跳到最底 |
| `prefix g g` | 跳到最頂（vim 的 gg） |

## 雜項
| Key | Action |
|---|---|
| `prefix r` | 重載 config |
| `prefix ?` | 顯示所有 keybinding（fzf popup） |
| `` prefix ` `` | 傳送一個字面 backtick |
