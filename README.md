# Tmux 設定檔

個人的 Tmux 設定檔，基於 Catppuccin 主題打造簡潔、現代且實用的終端體驗。

此設定檔參考了 [這個 GitHub 討論串](https://github.com/catppuccin/tmux/discussions/317#discussioncomment-11064512)。

## 截圖

![Tmux 設定截圖](Screenshot.png?v=20260426)

## 功能特色

### 主題配色

*   使用 Catppuccin (Mocha) 色票，色彩定義於 `colors.conf`。

### 自訂狀態列

狀態列位於頂部，共兩行：

**第一行左側：**
*   工作階段名稱（按下 prefix 時高亮顯示）
*   當前執行的指令
*   縮放狀態
*   CPU 使用率
*   記憶體使用率

**第一行右側：**
*   主要 IP 位址
*   電池電量
*   日期與時間

**第二行：**
*   當前面板的完整路徑（`$HOME` 顯示為 `~`）

### 視窗顯示

*   使用編號模式顯示視窗（自動重新命名）
*   視窗索引從 1 開始

### Prefix 鍵

本設定將 prefix 改為 `` ` ``（backtick），取代預設的 `Ctrl+b`，操作更順手。

> **如果想恢復預設的 `Ctrl+b`：** 將 `tmux.conf` 中以下三行註解掉即可：
> ```bash
> # set -g prefix `
> # unbind C-b
> # bind ` send-prefix
> ```

### 快捷鍵概覽

熱鍵設計採用 **mode-based namespace**：將相關操作分組到單字母 mode entry 下，避免單層字母用完、提升直觀度。每個 mode 都可用 `q` 或 `Esc` 退出，當前 mode 會顯示在 status bar 左側（橘色齒輪）。

`` prefix + ? `` 可隨時打開 fzf 搜索 cheatsheet（內容存於 `keybindings.txt`）。

#### 單鍵直接執行

| Key | Action |
| :--- | :--- |
| `prefix -` | 上下分割（同 pane 路徑） |
| `prefix _` | 上下分割（全寬） |
| `prefix \` | 左右分割 |
| `prefix \|` | 左右分割（全寬） |
| `prefix t` | 新 window |
| `prefix q` | detach 並關掉客戶端 |
| `prefix Q` | 殺整個 tmux server（有確認） |
| `prefix c` | 進入 copy mode (vi) |
| `prefix u/d/k/j` | page up/down、上/下一行 + 進 scroll mode |
| `prefix G` | 跳到最底 + 進 scroll mode |
| `prefix g g` | 跳到最頂（vim gg） |
| `prefix ?` | 顯示 keybinding 搜索 popup |
| `` prefix ` `` | 傳送一個字面 backtick |

#### Mode Entries（兩層 namespace）

**`prefix o` → o-mode（open apps）**

| Sub-key | Action |
| :--- | :--- |
| `oo` | zoom pane toggle |
| `ok` | 開 km8 (fullscreen) |
| `og` | 開 lazygit (fullscreen) |
| `of` | 開 spf (fullscreen) |

**`prefix s` → s-mode（search）**

| Sub-key | Action |
| :--- | :--- |
| `sw` | search window picker（fzf popup） |
| `ss` | search session picker（含「New Session」選項） |

**`prefix m` → m-mode（move）**

| Sub-key | Action |
| :--- | :--- |
| `mi` | move in（合併 pane 到指定 window） |
| `mo` | move out（break pane 成獨立 window） |

**`prefix r` → r-mode（action namespace）**

| Sub-key | Action |
| :--- | :--- |
| `rl` | reload config |
| `rs` | 進 rs-mode（resize） |
| `rn` | 進 rn-mode（rename） |
| `rm` | 進 rm-mode（remove） |

**`prefix rs` → rs-mode（resize）** — 進入後直接連按 `h/j/k/l` 調整方向

**`prefix rn` → rn-mode（rename）**

| Sub-key | Action |
| :--- | :--- |
| `rnw` | rename window（空字串重置為自動命名） |
| `rns` | rename session |

**`prefix rm` → rm-mode（remove）**

| Sub-key | Action |
| :--- | :--- |
| `rmw` | remove window |
| `rmp` | remove pane |

### 複製模式（Copy Mode）

`prefix + c` 進入 copy mode（vi 風格）：

| 快捷鍵 | 功能 |
| :--- | :--- |
| `h/j/k/l` | 移動游標 |
| `v` | 開始選取 |
| `y` | 複製選取內容並退出 |
| `prefix ]` | 貼上複製的內容 |

### 其他設定

*   啟用滑鼠支援
*   啟用 passthrough 模式
*   監控視窗活動
*   使用 vi 模式按鍵
*   256 色終端支援
*   escape-time 設為 0（適合 Neovim 使用者）

### 外掛（透過 TPM 管理）

TPM 會在首次啟動時自動安裝。使用的外掛如下：

| 外掛 | 用途 |
| :--- | :--- |
| `tmux-plugins/tpm` | Tmux 外掛管理器 |
| `tmux-plugins/tmux-battery` | 電池狀態顯示 |
| `tmux-plugins/tmux-cpu` | CPU 使用率顯示 |
| `thewtex/tmux-mem-cpu-load` | 記憶體使用率顯示 |
| `christoomey/vim-tmux-navigator` | Vim 與 Tmux 間無縫切換面板 |
| `dreknix/tmux-primary-ip` | 主要 IP 位址顯示 |

## 安裝

1.  **複製專案：**
    ```bash
    git clone https://github.com/vulcanshen/tmux-config.git ~/.config/tmux
    ```
2.  **啟動 Tmux**，TPM 會自動安裝。或手動安裝：
    ```bash
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ```
3.  **安裝外掛：**
    *   啟動 Tmux 後按下 `prefix` + `I`（大寫 I）來安裝外掛。

## Neovim (Lualine)

本專案包含 `lualine.lua` 設定檔，用於配置 Neovim 的 Lualine 狀態列外掛，使其與 Tmux 主題風格一致。

### 安裝方式

將 `lualine.lua` 複製到 LazyVim 的外掛目錄下：

```bash
cp ~/.config/tmux/lualine.lua ~/.config/nvim/lua/plugins/lualine.lua
```

### 功能特色

*   **Catppuccin 配色：** 使用與 Tmux 相同的 Catppuccin mocha 色票
*   **自訂元件：** 狀態列包含以下資訊：
    *   模式指示器
    *   Git 分支與差異狀態
    *   檔案圖示、名稱與狀態
    *   緩衝區列表（目前/總計）
    *   檔案格式、編碼與大小
    *   診斷資訊（錯誤、警告、提示）
    *   進度與游標位置
*   **自訂分隔符號：** 使用 `|` 作為分隔符號，呈現簡潔現代的外觀

## Neovim (vim-tmux-navigator)

搭配 `christoomey/vim-tmux-navigator` 外掛，可以在 Tmux 與 Neovim 之間使用 `Ctrl` + `h/j/k/l` 無縫切換面板。

### Neovim 端設定

將以下設定檔放置於 LazyVim 的外掛目錄下 `~/.config/nvim/lua/plugins/vim-tmux-navigator.lua`：

```lua
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
```

### 快捷鍵對照

| 快捷鍵 | 功能 |
| :--- | :--- |
| `Ctrl` + `h` | 切換到左方面板 |
| `Ctrl` + `j` | 切換到下方面板 |
| `Ctrl` + `k` | 切換到上方面板 |
| `Ctrl` + `l` | 切換到右方面板 |
| `Ctrl` + `\` | 切換到上一個面板 |

## 色票

色票定義於 `colors.conf`，基於 Catppuccin Mocha 主題。

| 色彩名稱 | 色碼 |
| :--- | :--- |
| Rosewater | `#f5e0dc` |
| Flamingo | `#f2cdcd` |
| Pink | `#f5c2e7` |
| Mauve | `#cba6f7` |
| Red | `#f38ba8` |
| Maroon | `#eba0ac` |
| Peach | `#fab387` |
| Yellow | `#f9e2af` |
| Green | `#a6e3a1` |
| Teal | `#94e2d5` |
| Sky | `#89dceb` |
| Sapphire | `#74c7ec` |
| Blue | `#89b4fa` |
| Lavender | `#b4befe` |
| Text | `#cdd6f4` |
| Subtext1 | `#bac2de` |
| Subtext0 | `#a6adc8` |
| Overlay2 | `#9399b2` |
| Overlay1 | `#7f849c` |
| Overlay0 | `#6c7086` |
| Surface2 | `#585b70` |
| Surface1 | `#45475a` |
| Surface0 | `#313244` |
| Base | `#1e1e2e` |
| Mantle | `#181825` |
| Crust | `#11111b` |

## 附錄：實用的 Tmux 原生快捷鍵

以下為 Tmux 內建的常用操作，不需要額外設定即可使用。更完整的快捷鍵列表可參考 [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)。

### 面板（Pane）操作

| 快捷鍵 | 功能 |
| :--- | :--- |
| `prefix` + `!` | 將當前面板拆出為獨立視窗 |
| `prefix` + `{` | 將當前面板與上一個面板交換位置 |
| `prefix` + `}` | 將當前面板與下一個面板交換位置 |
| `prefix` + `z` | 縮放/還原當前面板（全螢幕切換） |
| `prefix` + `q` | 顯示面板編號，按數字可快速切換 |

### 面板佈局切換

| 快捷鍵 | 功能 |
| :--- | :--- |
| `prefix` + `Space` | 循環切換佈局（垂直/水平等） |
| `prefix` + `Alt` + `1` | 水平平均排列（even-horizontal） |
| `prefix` + `Alt` + `2` | 垂直平均排列（even-vertical） |

### 合併面板

透過指令將其他視窗的面板合併到當前視窗：

```
prefix + : 後輸入 join-pane -s <來源視窗編號>
```

## Credits

Inspired by / based on [naivecynics](https://github.com/naivecynics/primary-tmux)
