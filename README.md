# Tmux 設定檔

個人的 Tmux 設定檔，基於 Catppuccin 主題打造簡潔、現代且實用的終端體驗。

此設定檔參考了 [這個 GitHub 討論串](https://github.com/catppuccin/tmux/discussions/317#discussioncomment-11064512)。

## 功能特色

### 主題配色

*   使用 Catppuccin (Mocha) 色票，色彩定義於 `colors.conf`。

### 自訂狀態列

狀態列位於頂部，只放 tmux 本身的資訊（時間、電量、CPU 等交給 macOS 選單列）：

*   **左側**：工作階段名稱（按下 prefix 時高亮顯示）、縮放狀態、當前 mode（`copy` 或各 mode 名稱）、縮小中的 o-mode 工具（見下方「o-mode 工具縮小」）
*   **右側**：視窗列表（見下方「視窗顯示」），緊貼著主要 IP 位址（IP 在寬度不夠時自動隱藏）

每個面板上緣另有一條標題列，顯示該面板的完整路徑（`$HOME` 顯示為 `~`）、git branch 與執行中的程式。

### 視窗顯示

*   使用編號模式顯示視窗（自動重新命名，命名格式為當前路徑的最末層目錄名）
*   視窗索引從 1 開始
*   所有 window 連成一條以斜線分段的長條，每個 window 是「編號 + 目錄名」兩段，**寬度夠時每個 window 都顯示目錄名**；編號的底色表示狀態（當前 window 為天藍）：

    | 顏色 | 有 Claude Code 的 window | 其他 window |
    | :--- | :--- | :--- |
    | 紅 | 收到 `^G`（terminal bell） | 收到 `^G`（terminal bell） |
    | 綠 | Claude 講完、或在等妳核准權限 / 回答問題 | — |
    | 橘 | Claude 正在處理 | pane 有輸出、且還沒安靜下來 |
    | 灰 | 其他時候 | 沒動過，或動完停下來了 |

    優先級：紅 > 綠 > 橘 > 灰。切進該 window 後綠色就會清除。Claude Code 的狀態要先裝好 hooks，見「[Claude Code 整合](#claude-code-整合)」。
*   視窗多、寬度不夠時依序自動退讓，不會蓋到左右兩側的資訊：
    1.  只有當前 window 顯示目錄名，其他 window 只剩有顏色的編號
    2.  隱藏右側的 IP 位址
    3.  還是放不下就捲動，兩端以 `<` `>` 標示，當前 window 永遠在畫面內
*   第 1～9 個 window 用 `prefix 1`～`prefix 9` 切換；第 10 個以後改用字母，狀態列上也顯示該字母（取代 `10`、`11`）：

    | window | 熱鍵 |
    | :--- | :--- |
    | 10～22 | `prefix a` `b` `c` `d` `e` `g` `h` `j` `k` `u` `w` `x` `y` |
    | 23～40 | `prefix A` `B` `D` `F` `G` `M` `N` `O` `P` `Q` `R` `S` `T` `V` `W` `X` `Y` `Z` |

    按到不存在的 window 時，畫面中央會跳出提示，1.5 秒後自動消失。提示不會擋住下一個按鍵：直接按 prefix 接著切 window、繼續打字都可以（按鍵會關掉提示並照常生效），`Esc` 只關閉提示。

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
| `prefix q` | 取消 prefix pending state |
| `prefix H` | 前一個 window，並進入 `w-nav` mode 可連按（`q`/`Esc` 退出） |
| `prefix L` | 下一個 window，並進入 `w-nav` mode 可連按 |
| `prefix J` | 下一個 session（照名稱排序，跳過縮小中工具的背景 session），並進入 `w-nav` mode 可連按 |
| `prefix K` | 上一個 session，並進入 `w-nav` mode 可連按；在 `w-nav` 裡 `H` `L` `J` `K` 可以混著按 |
| `prefix 1`～`9`、`prefix a` `b` `c`… | 切換 window（見「視窗顯示」） |
| `prefix v` | 進入 view mode：翻頁、捲動、選取與複製（見下方「檢視模式」） |
| `prefix :` | popup command line |
| `prefix p` | prompt：在 pane 當前目錄執行 shell 指令（fire-and-forget；失敗時顯示錯誤提示） |
| `prefix ?` | 顯示 keybinding 搜索 popup |
| `` prefix ` `` | 傳送一個字面 backtick |

#### Mode Entries（兩層 namespace）

**`prefix o` → o-mode（open apps）**

| Sub-key | Action |
| :--- | :--- |
| `oo` | zoom pane toggle；在工具的 popup 裡則是縮小工具 |
| `ok` | 開 kbu (fullscreen)；縮小中則叫回 |
| `og` | 開 gittu (fullscreen)；縮小中則叫回 |
| `of` | 開 filu (fullscreen)；縮小中則叫回 |
| `ow` | 開 webu (fullscreen)；縮小中則叫回 |
| `ot` | 開 tetru (fullscreen)；縮小中則叫回 |

**o-mode 工具縮小**：`ok` / `og` / `of` / `ow` / `ot` 開的工具，在 popup 裡按 `prefix o o` 就縮小，工具繼續在背景執行；再按一次同一個鍵叫回原本的畫面。在工具裡正常結束（例如 gittu 按 `q`）才算真的關閉。

*   每個 session 裡同一個工具只有一份，停在第一次開啟時的目錄；要換 repo，先在工具裡結束再重開
*   縮小中的工具顯示在狀態列左上角、session 名稱後面，每個工具一顆深色圓角膠囊，熱鍵字母以藍色標示
*   session 關閉時，它縮小中的工具一併結束
*   在工具裡持續操作時，不會被閒置鎖定（locku）鎖住；開著不碰，照樣在閒置時間到時鎖定

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
| `rs` | 進 rs-mode（resize、平均排列） |
| `rn` | 進 rn-mode（rename） |
| `rm` | 進 rm-mode（remove） |

**`prefix rs` → rs-mode（resize）** — 進入後直接連按 `h/j/k/l` 調整方向；`V` 所有 pane 上下平均排列、`H` 左右平均排列（排完自動離開 rs-mode）

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

### 檢視模式（View Mode）

`prefix v` 進入 view mode，之後可以連按；`q` / `Esc` 離開，按其他鍵也會離開（該鍵照常送進 pane）：

| 快捷鍵 | 功能 |
| :--- | :--- |
| `u` / `d` | 上 / 下翻頁 |
| `k` / `j` | 上 / 下一行 |
| `G` / `gg` | 跳到最底 / 最頂 |
| `v` | 從游標所在那一行開始整行選取，再用上面的鍵往上下延伸 |
| `y` | 複製選取內容並離開 |

*   Claude Code、nvim、less 這類全螢幕程式：翻頁鍵直接交給程式；按 `v` 時畫面才進入 tmux 的 copy mode，可以選取畫面上的字
*   一般 shell pane：進入時就是 tmux 的 copy mode，捲動的是 scrollback；滑鼠滾輪往上捲也會進入 copy mode
*   想逐字選取：按 `h` `l` `w` `b` 等鍵切到 tmux 原生的 copy mode（vi 風格），在那裡 `v` 開始選取、`y` 複製
*   `prefix ]` 貼上複製的內容

### 其他設定

*   啟用滑鼠支援
*   啟用 passthrough 模式
*   監控視窗活動
*   使用 vi 模式按鍵
*   256 色終端支援
*   escape-time 設為 0（適合 Neovim 使用者）
*   沿用終端機自己的配色：tmux 3.8 起內建的配色主題不套用，popup 與選單沒有背景色

### 外掛（透過 TPM 管理）

TPM 會在首次啟動時自動安裝。使用的外掛如下：

| 外掛 | 用途 |
| :--- | :--- |
| `tmux-plugins/tpm` | Tmux 外掛管理器 |
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

搭配 `christoomey/vim-tmux-navigator` 外掛，可以在 Tmux 與 Neovim 之間使用 `Option` + `h/j/k/l` 無縫切換面板。

> 預設綁定為 `Ctrl` + `h/j/k/l`，但 `Ctrl + h/l` 在 terminal 內常與行編輯快捷鍵衝突，因此本設定將兩邊一起改成 `Option`（macOS 的 Meta 鍵）。
> macOS 需在 terminal 設定中開啟 `option-as-alt`（Ghostty: `macos-option-as-alt = true`），否則 Option 會被當作 dead-key 用於輸入特殊字元。

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
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  keys = {
    { "<M-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<M-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<M-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<M-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<M-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
```

### 快捷鍵對照

| 快捷鍵 | 功能 |
| :--- | :--- |
| `Option` + `h` | 切換到左方面板 |
| `Option` + `j` | 切換到下方面板 |
| `Option` + `k` | 切換到上方面板 |
| `Option` + `l` | 切換到右方面板 |
| `Option` + `\` | 切換到上一個面板 |

## Claude Code 整合

window 標籤的顏色跟著 Claude Code 的狀態走：處理中是橘色，講完或在等妳回答時是綠色。即使妳在別的 window，也能一眼看出哪個 Claude 在忙、哪個在等妳。

*   不管用什麼方式切進該 window（`H` / `L`、數字或字母鍵、`J` / `K`、session 清單），綠色都會清除；Claude 在妳正看著的 window 講完，不會變綠
*   只有要妳核准權限或回答問題的通知會變綠，閒置 60 秒的提醒不會
*   Claude 處理到一半按 `Esc` 中斷，切走後會轉回灰色
*   有 Claude 的 window 只看 Claude 的狀態，閒著的 Claude 重畫畫面不會讓它變橘；其他 window 照舊看 pane 有沒有輸出

腳本位於 `claude-hooks/`：

| 檔案 | 用途 |
| :--- | :--- |
| `mark-ready.sh` | 由 Claude Code 的 hooks 呼叫，記錄每個 pane 的 Claude 是否在處理，講完或等妳回答時讓 window 變綠 |
| `install.sh` | 安裝 hooks 到 `~/.claude/settings.json`（idempotent、寫 timestamped backup、非破壞性合併） |
| `uninstall.sh` | 反向移除，只清這個 repo 的 hook entry |

### 安裝

```bash
~/.config/tmux/claude-hooks/install.sh
```

安裝後立即生效，已經在跑的 Claude Code 也會套用。tmux 端的顏色與清除機制已內建在 `tmux.conf`，不需額外設定。

> 設計緣由（為什麼不用 tmux 內建的 activity / silence 判斷）見 [docs/dev-remarks.md](docs/dev-remarks.md)。

## 螢幕鎖定（locku）

整合 locku（terminal 螢幕鎖定程式），提供類似螢幕保護的鎖定：

| 觸發方式 | 說明 |
| :--- | :--- |
| `prefix l` | 手動鎖定（所有 client 一起鎖） |
| `prefix :` 後輸入 `locku` | 同上（command alias） |
| 閒置逾時 | 自動鎖定（秒數由 locku 設定畫面控制） |

鎖定具有持久性：鎖定期間重新 attach 或切換 session，新 client 會立刻被重新鎖上。

鎖定相關設定由 locku 的設定畫面（Integration > tmux）產生於 `~/.config/locku/locku.tmux.conf`，`tmux.conf` 僅以 `source-file -q` 讀入 — 未安裝 locku 的環境該檔不存在，整段自動略過。機制說明見 [docs/dev-remarks.md](docs/dev-remarks.md)。

## 色票

色票定義於 [`colors.conf`](colors.conf)，基於 [Catppuccin](https://github.com/catppuccin/catppuccin) Mocha 主題 — 狀態列、視窗標籤與 popup 邊框的顏色皆取自這份定義。

## 附錄：實用的 Tmux 原生快捷鍵

以下為 Tmux 內建的常用操作，不需要額外設定即可使用。更完整的快捷鍵列表可參考 [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)。

### 面板（Pane）操作

| 快捷鍵 | 功能 |
| :--- | :--- |
| `prefix` + `{` | 將當前面板與上一個面板交換位置 |
| `prefix` + `}` | 將當前面板與下一個面板交換位置 |
| `prefix` + `z` | 縮放/還原當前面板（全螢幕切換） |

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

## 相關連結

- [CHANGELOG](CHANGELOG.md) — 版本變更紀錄
- [docs/dev-remarks.md](docs/dev-remarks.md) — 運作機制與設計決定（開發者備忘）
- [keybindings.txt](keybindings.txt) — `prefix ?` cheatsheet 的資料來源

## Credits

Inspired by / based on [naivecynics](https://github.com/naivecynics/primary-tmux)
