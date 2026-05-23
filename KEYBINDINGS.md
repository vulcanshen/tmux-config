# Tmux Keybindings Cheatsheet

> Prefix key: `` ` `` (backtick)
> 每個 mode 都可用 `q` 或 `Esc` 退出

---

## 單鍵直接執行

### 分割
| Key | Action |
|---|---|
| `prefix -` | 上下分割（同 pane 路徑） |
| `prefix _` | 上下分割（全寬） |
| `prefix \` | 左右分割 |
| `prefix \|` | 左右分割（全寬） |

### Window / Session
| Key | Action |
|---|---|
| `prefix t` | 新 window |
| `prefix q` | detach 並關掉客戶端 |
| `prefix Q` | 殺整個 tmux server（有確認） |

### Mode 入口（單鍵直入）
| Key | Action |
|---|---|
| `prefix c` | 進入 copy mode（vi） |
| `prefix u` | page up + 進 scroll mode |
| `prefix d` | page down + 進 scroll mode |
| `prefix k` | 上一行 + 進 scroll mode |
| `prefix j` | 下一行 + 進 scroll mode |
| `prefix G` | 跳到最底 + 進 scroll mode |
| `prefix g g` | 跳到最頂（vim 的 gg） |

### 雜項
| Key | Action |
|---|---|
| `prefix ?` | 顯示所有 keybinding（fzf popup） |
| `` prefix ` `` | 傳送一個字面 backtick |

---

## Mode Entries（兩層 namespace）

### `prefix o` → o-mode (open apps)
| Key | Action |
|---|---|
| `oo` | zoom pane toggle |
| `ok` | 開 km8 (fullscreen) |
| `og` | 開 lazygit (fullscreen) |
| `of` | 開 spf (fullscreen) |

### `prefix s` → s-mode (search)
| Key | Action |
|---|---|
| `sw` | search window picker（fzf popup） |
| `ss` | search session picker（含「New Session」選項） |

### `prefix m` → m-mode (move)
| Key | Action |
|---|---|
| `mi` | move in（合併 pane 到指定 window，fzf popup） |
| `mo` | move out（break pane 成獨立 window） |

### `prefix r` → r-mode (action namespace)
| Key | Action |
|---|---|
| `rl` | reload config |
| `rs` | 進 rs-mode（resize） |
| `rn` | 進 rn-mode（rename） |
| `rm` | 進 rm-mode（remove） |

#### `prefix rs` → rs-mode (resize)
進入後直接連按方向鍵。

| Key | Action |
|---|---|
| `h` | 向左 |
| `j` | 向下 |
| `k` | 向上 |
| `l` | 向右 |

#### `prefix rn` → rn-mode (rename)
| Key | Action |
|---|---|
| `rnw` | rename window（popup，空字串重置為自動命名） |
| `rns` | rename session |

#### `prefix rm` → rm-mode (remove)
| Key | Action |
|---|---|
| `rmw` | remove window |
| `rmp` | remove pane |

---

## Copy Mode 內部

| Key | Action |
|---|---|
| `v` | 開始選取 |
| `y` | copy selection |

---

## Scroll Mode 內部

進入 scroll mode 後可連按以下鍵不需重按 prefix。

| Key | Action |
|---|---|
| `u` | page up |
| `d` | page down |
| `k` | 上一行 |
| `j` | 下一行 |
| `G` | 跳到最底 |
| `g g` | 跳到最頂 |
| `q` / `Esc` | 退出 |

---

## namespace 規則總結

| Mode | 含義 | Sub-keys |
|---|---|---|
| `o` | open | apps (oo/ok/og/of) |
| `s` | search | sw / ss |
| `m` | move | mi / mo |
| `r` | action | rl / rs / rn / rm |
| `rn` | rename | rnw / rns |
| `rm` | remove | rmw / rmp |
| `rs` | resize | h/j/k/l |

---

## Status Bar Mode Indicator

進入非 root mode 時，status bar 左側（zoom 旁邊）會顯示橘色齒輪 + mode 名稱。

可能出現的 mode 名稱：
- `o-mode` / `s-mode` / `m-mode` / `r-mode` / `rs-mode` / `rn-mode` / `rm-mode`
- `scroll` / `scroll-g`
- `copy-mode-vi`
