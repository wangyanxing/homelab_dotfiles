# homelab_dotfiles

一套现代化、跨平台（macOS / Linux）、可一键复现的个人 dotfiles。

用 [chezmoi](https://www.chezmoi.io/) 管理，从 [YADR](https://github.com/skwp/dotfiles) 迁移了核心使用习惯，
但**彻底去掉了 Ruby/rake 那套过时的底座**，改用当下轻量、透明、性能更好的工具链。

设计原则：**每个文件都短、带注释、你能看懂、能改** —— 强掌控，无黑盒。

---

## 目录

- [特性一览](#特性一览)
- [快速开始](#快速开始)
  - [全新机器一键安装](#全新机器一键安装)
  - [在已有机器上应用](#在已有机器上应用)
- [仓库结构](#仓库结构)
- [从 YADR 迁移了什么](#从-yadr-迁移了什么)
- [日常使用](#日常使用)
  - [prompt 提示符](#prompt-提示符)
  - [常用 alias](#常用-alias)
  - [目录跳转 z](#目录跳转-z)
  - [历史命令搜索](#历史命令搜索)
  - [本地个性化：.zsh.before / .zsh.after](#本地个性化zshbefore--zshafter)
  - [快速改 alias：ar / ae](#快速改-aliasar--ae)
- [zellij 终端复用](#zellij-终端复用)
- [各组件说明](#各组件说明)
- [常见操作速查](#常见操作速查)
- [自定义与扩展](#自定义与扩展)
- [常见问题排查](#常见问题排查)
- [卸载 / 回滚](#卸载--回滚)

---

## 特性一览

| 能力 | 实现 | 说明 |
|---|---|---|
| 跨平台一键复现 | **chezmoi** | 一条命令在新的 macOS/Linux 机器上还原完整环境 |
| 提示符 | **starship** | 复刻 YADR skwp 主题配色 + git 状态圆点，**不再显示 `[ruby-x.x]`** |
| 智能目录跳转 | **zoxide** (`z`) | `z down` → `~/Downloads`，替代 fasd，用法一致 |
| 历史子串搜索 | zsh-history-substring-search | 输入 `cu` 按 ↑，找到之前的 `curl ...` |
| 模糊补全 / 纠错 | zsh 原生 + fzf-tab | 打错目录名 Tab 自动纠正 |
| 输入目录名即跳转 | `AUTO_CD` | 不用敲 `cd` |
| 现代 CLI | eza / bat / fd / ripgrep / delta / fzf / atuin | `ll` `cat` `find` `grep` `git diff` 全面升级 |
| 现代 CLI（扩展） | lazygit / lazydocker / jq / yq / dust / duf / procs / btop / gh / tldr / glow / httpie | git·docker TUI、JSON/YAML、磁盘/进程监控、GitHub CLI 等 |
| 编辑器 | **Neovim + LazyVim** | 语言支持：Python/JS/TS/JSON/YAML/C·C++/Docker/Markdown/TOML（LSP+格式化）+ 常见配置文件 treesitter + 自定义键位 |
| 终端复用 | **zellij**（tmux 风格 Ctrl-b 前缀 + `quad`/`dual` 预设布局）+ tmux 兜底（键位/配色对齐） | 降低从 tmux 迁移的不适应 |
| 运行时版本管理 | **mise** | 替代 rbenv/nvm，全局默认版本 + **不污染 prompt** |
| 统一配色 | **tokyonight** | ghostty / zellij / nvim / tmux 观感一致 |
| macOS 系统调优 | `macos-defaults`（可选，手动运行） | 键盘重复/Finder/Dock/截图等一键设置 |
| zsh 插件管理 | **antidote** | 静态编译缓存，启动快 |
| zsh 插件 | autosuggestions / syntax-highlighting / substring-search / fzf-tab / completions / you-should-use | 补全·高亮·历史·别名提醒 |

---

## 快速开始

### 全新机器一键安装

只需机器上有 `git` 和 `curl`。本仓库是 **private**，用 SSH 拉取（`<用户名>/repo` 简写会走 HTTPS，
GitHub 已不支持密码认证，会失败）：

```sh
# 前提：本机 SSH key 已加到 GitHub。验证：ssh -T git@github.com
# 安装 chezmoi 并从你的 GitHub 仓库初始化 + 应用
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:wangyanxing/homelab_dotfiles.git
```

> 还没配 SSH key？先生成并加到 GitHub：
> ```sh
> ssh-keygen -t ed25519 -C "你的邮箱"        # 一路回车
> cat ~/.ssh/id_ed25519.pub                    # 复制输出
> # 打开 https://github.com/settings/keys → New SSH key → 粘贴保存
> ssh -T git@github.com                        # 出现 "successfully authenticated" 即可
> ```

`chezmoi init --apply` 会自动：
1. 拉取本仓库到 `~/.local/share/chezmoi`
2. 运行 `run_once_before_10-install-packages.sh` 装齐所有依赖（macOS 与 Linux 策略不同，见下）
3. 把所有配置写入 `$HOME`

首次启动 zsh 时，antidote 会自动 clone 并编译 zsh 插件（约十几秒，仅一次）。

#### macOS：用 Homebrew

安装脚本会自动装 Homebrew + starship/zoxide/eza/fzf/bat/fd/ripgrep/delta/atuin/
zellij/neovim/mise/antidote/tmux + JetBrainsMono Nerd Font。

**并非「零干预」，有几步需你配合：**

| 环节 | 你要做什么 | 说明 |
|---|---|---|
| Xcode 命令行工具 | 弹框点「安装」，等几分钟 | 全新 Mac 没有 git，系统级 GUI 弹框，脚本无法替你点。脚本会自动触发并等待其完成 |
| Homebrew 密码 | 输一次 sudo 密码 | brew 首次要创建 `/opt/homebrew` |
| 重开终端 | 装完后 `exec zsh` 或新开窗口 | prompt / 插件需新 shell 加载 |
| 首次启动 | 新 shell 第一次卡十几秒 | antidote 在 clone 5 个 zsh 插件 |
| Neovim 首次打开 | 第一次 `nvim` 自动装插件 | LazyVim 拉插件 |
| Ghostty 字体 | 通常无需操作 | 字体已随本仓库自动安装，Ghostty 配置也已纳入管理 |

> CLT 弹框和 sudo 密码是 macOS 的安全机制，**任何 dotfiles 方案都绕不开**；其余全程自动。

> **没有管理员权限 / 装不了 Homebrew？** 脚本会自动降级：不再中断，改从 GitHub release
> 拉静态二进制到 `~/.local/bin`（starship/zoxide/bat/fd/rg/delta/atuin/zellij/fzf/
> lazygit/lazydocker/dust/duf/procs/glow/gh/neovim/mise），无需 sudo。唯一例外是
> `eza`（无 macOS 二进制发布），此时 `ll` 自动回退到原生 `ls`。日后有权限了再装
> Homebrew 并 `brew bundle --file ~/.config/homebrew/Brewfile` 即可补齐。

#### Ubuntu / Linux：不需要 Homebrew

Linux 分支**完全不装 Homebrew**。策略是：

- **apt** 装基础工具：`zsh git curl wget file unzip tar build-essential`、
  `fzf bat fd-find ripgrep tmux`（`batcat`/`fdfind` 自动软链成 `bat`/`fd`）
- **GitHub release 静态二进制**装到 `~/.local/bin`：`starship zoxide eza delta zellij atuin`
- **官方安装器**：`mise`（→ `~/.local/bin`）、`neovim`（官方 tarball，因为 apt 版本太旧带不动 LazyVim）
- **git clone**：`antidote`（→ `~/.antidote`）

自动支持 `x86_64` 和 `aarch64`（ARM）两种架构。

**Ubuntu 上需你配合的几步：**

```sh
# 1. 先装 git 和 curl（如果没有）
sudo apt update && sudo apt install -y git curl

# 2. 一键安装（脚本里的 apt 部分会要一次 sudo 密码）
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <你的GitHub用户名>/homelab_dotfiles

# 3. 把默认 shell 切成 zsh（Ubuntu 默认是 bash）
chsh -s "$(command -v zsh)"

# 4. 重新登录（或 exec zsh）让一切生效
exec zsh
```

| 环节 | 说明 |
|---|---|
| sudo 密码 | 仅 apt 装基础包时输一次；其余工具装到 `~/.local/bin`，无需 sudo |
| `~/.local/bin` 在 PATH 里 | 已由 `~/.zshenv` 保证 |
| 默认 shell | 需手动 `chsh -s $(which zsh)`，Ubuntu 不会自动切 |
| 字体 | 脚本不自动装 Linux 字体；如需 Nerd Font 图标，在你的终端模拟器里自行装 JetBrainsMono Nerd Font 即可 |
| Neovim 首次打开 | 第一次 `nvim` 自动装 LazyVim 插件 |

#### 与「样子一致」相关的说明

- **`z` 记忆为空**：zoxide 数据库不跨机器同步，新机上 `z down` 一开始跳不动，正常 `cd` 几次喂给它即可。
- **主机名**：prompt 里 `@host` 会显示新机的主机名，属预期。
- **Linux 图标**：starship 的分支符号/圆点需终端使用 Nerd Font；未装则可能显示为方框，功能不受影响。


### 在已有机器上应用

已经在用别的 dotfiles（如 YADR）时，**建议先看差异、备份，再应用**。
旧的 `~/.yadr` 目录**不用删**，备份掉它占用的入口软链即可，随时能回滚。

#### macOS（从 YADR 迁移）

```sh
# 安装 chezmoi
brew install chezmoi

# 从 GitHub 初始化（拉到 ~/.local/share/chezmoi，不修改任何 HOME 文件）
chezmoi init git@github.com:wangyanxing/homelab_dotfiles.git

# 只读预览：将会对 $HOME 做哪些改动
chezmoi diff

# 备份 YADR 的入口软链（不删 ~/.yadr 本体）
mkdir -p ~/dotfiles-backup
mv ~/.zshrc ~/.zshenv ~/.gitconfig ~/.tmux.conf ~/dotfiles-backup/ 2>/dev/null

# 应用新配置
chezmoi apply
exec zsh
```

#### Ubuntu / Linux（从 YADR 迁移）

```sh
# 1. 确保有 git 和 curl
sudo apt update && sudo apt install -y git curl

# 2. 先看看 YADR 占用了哪些入口文件（确认是不是指向 ~/.yadr 的软链）
ls -la ~/.zshrc ~/.zshenv ~/.gitconfig ~/.tmux.conf ~/.vimrc 2>/dev/null

# 3. 备份 YADR 的入口软链/文件（不删 ~/.yadr 本体，可随时回滚）
mkdir -p ~/dotfiles-backup
mv ~/.zshrc ~/.zshenv ~/.gitconfig ~/.tmux.conf ~/.vimrc ~/dotfiles-backup/ 2>/dev/null

# 4. 用 chezmoi 拉取并应用（自动跑 apt + 装二进制到 ~/.local/bin，无需 brew）
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:wangyanxing/homelab_dotfiles.git

# 5. 把默认 shell 切成 zsh（YADR 可能已切过，跑一下确保）
chsh -s "$(command -v zsh)"

# 6. 重新登录，或直接：
exec zsh
```

**回滚到 YADR**（如果想退回去）：

```sh
mv ~/dotfiles-backup/.zshrc ~/.zshrc     # 把软链搬回来（其他文件同理）
exec zsh
```

> 说明：
> - `~/.zshrc` 只能有一份，YADR 与本配置**不能同时生效**，靠备份/还原切换。
> - 第 2 步若显示 `~/.zshrc -> /home/你/.yadr/...`，即为 YADR 软链，备份掉即可。
> - Ubuntu 默认 shell 是 bash，需手动 `chsh` 切 zsh（第 5 步）。
> - Nerd Font 图标需在你的终端模拟器里自行安装 JetBrainsMono Nerd Font。


---

## 仓库结构

chezmoi 约定：`dot_xxx` → `~/.xxx`，`.tmpl` 结尾为模板，`run_once_before_*` 为首次安装脚本。

```
homelab_dotfiles/                              # chezmoi source 目录
├── .chezmoi.toml.tmpl                         # chezmoi 配置模板（editor 等变量）
├── .chezmoiignore                             # 不纳入管理的文件（README/LICENSE/.git）
├── run_once_before_10-install-packages.sh.tmpl# 新机器自动装依赖（macOS 用 brew；Linux 用 apt+二进制）
│
├── dot_zshenv.tmpl                            # ~/.zshenv  环境变量、PATH（含 ~/.local/bin、macOS brew）
├── dot_zshrc                                  # ~/.zshrc   加载链入口
├── dot_zsh_plugins.txt                        # ~/.zsh_plugins.txt  antidote 插件清单
│
├── dot_config/
│   ├── starship.toml                          # ~/.config/starship.toml  提示符
│   ├── zsh/                                    # ~/.config/zsh/  拆分的 zsh 模块
│   │   ├── options.zsh                         #   AUTO_CD / 补全 / history 等 setopt
│   │   ├── plugins.zsh                         #   antidote 加载 + 键位绑定
│   │   ├── aliases.zsh                         #   系统 alias（psg/psx/pk/ll/ar/ae/全局 alias）
│   │   ├── git.zsh                             #   git alias（gpl/gcm/gl/gs/gco...）
│   │   ├── functions.zsh                       #   函数（fn/mcd/extract）+ 键位绑定
│   │   └── tools.zsh                           #   zoxide/fzf/atuin/mise/bat/starship 初始化
│   ├── nvim/                                   # ~/.config/nvim/  LazyVim
│   │   ├── init.lua
│   │   ├── lazyvim.json                        #   语言 extras（py/js/ts/json/yaml/c++/docker/toml...）
│   │   ├── lua/config/lazy.lua                 #   lazy.nvim 引导（禁用冗余内置插件）
│   │   ├── lua/config/options.lua              #   编辑器选项（绝对行号等）
│   │   ├── lua/config/keymaps.lua              #   自定义键位（居中跳转/移动行/系统剪贴板）
│   │   └── lua/plugins/init.lua                #   自定义插件 / treesitter 解析器覆盖
│   ├── zellij/                                 # ~/.config/zellij/
│   │   ├── config.kdl                          #   主配置（tmux 风格前缀）
│   │   └── layouts/                            #   预设布局：quad（四宫格）/ dual（左右双栏）
│   ├── mise/config.toml                        # ~/.config/mise/  全局运行时版本（node/python）
│   └── ghostty/config                          # ~/.config/ghostty/config  终端字体/主题（tokyonight）
│
├── dot_local/bin/                             # ~/.local/bin/  纳管的可执行脚本
│   ├── dotfiles-doctor                        #   环境健康自检
│   └── macos-defaults                         #   macOS 系统调优（可选，手动运行）
│
├── dot_gitconfig.tmpl                         # ~/.gitconfig  git 子命令别名 + delta
├── dot_gitignore_global                       # ~/.gitignore_global
├── dot_tmux.conf.tmpl                         # ~/.tmux.conf  tmux 兜底（键位/配色对齐 zellij）
│
├── dot_zsh.before/                            # ~/.zsh.before/  主配置【之前】加载（本机私有）
│   └── README.zsh
└── dot_zsh.after/                             # ~/.zsh.after/   主配置【之后】加载（本机私有）
    └── README.zsh
```

**zsh 加载顺序**（见 `dot_zshrc`）：

```
~/.zsh.before/*.zsh              ← 本机私有覆盖（最先）
  └─ ~/.config/zsh/options.zsh
     ~/.config/zsh/plugins.zsh
     ~/.config/zsh/aliases.zsh
     ~/.config/zsh/git.zsh
     ~/.config/zsh/functions.zsh
     ~/.config/zsh/tools.zsh
~/.zsh.after/*.zsh               ← 本机私有覆盖（最后，优先级最高）
~/.secrets                        ← 密钥（不提交）
```

---

## 从 YADR 迁移了什么

| YADR 旧实现 | 本仓库 | 状态 |
|---|---|---|
| Ruby + rake 安装系统 | chezmoi | ✅ 替换 |
| prezto sorin/skwp 主题 | starship（复刻配色与状态圆点） | ✅ 复刻 |
| RPROMPT 的 `[ruby-4.0.6]` | 无 | ❌ 移除 |
| fasd `z` | zoxide `z` | ✅ 等价 |
| history-substring-search | 同名 zsh 插件 | ✅ 保留 |
| `.zsh.before` / `.zsh.after` | 同名约定 | ✅ 保留 |
| `ar` / `ae` 改 alias | `ar` 保留；`ae` 改为走 `chezmoi edit` | ♻️ 调整 |
| git alias（gpl/gcm/gl/gs...） | `git.zsh` | ✅ 全保留 |
| 系统 alias（psg/ll...） | `aliases.zsh` | ✅ 保留 |
| 全局 alias（`...` `G` `L`） | `aliases.zsh` | ✅ 保留 |
| `gar` 广播 SIGHUP 重载 alias | 无（会误伤非交互脚本） | ❌ 移除 |
| Ctrl-x Ctrl-l 插入上条命令输出 | 无（实为重跑历史命令，有副作用） | ❌ 移除 |
| 90+ vim 插件 | LazyVim（轻量） | ♻️ 精简 |
| Ruby/Rails/Zeus/spring alias | 无 | ❌ 移除 |

---

## 日常使用

### prompt 提示符

```
cjlm007@ai-618 ~/projects/av_mgr_repo (main●)$
└─绿──┘ └─橙─┘ └───青路径──────┘ └─分支+状态点─┘
```

git 状态圆点颜色（沿用 skwp 约定）：

| 颜色 | 含义 |
|---|---|
| 🟢 绿 | 已暂存 (staged) |
| 💗 粉 | 已修改 (modified) |
| 🟣 紫 | 未跟踪 (untracked) |
| 🟠 橙 | 已删除 (deleted) |

改配色 / 布局：编辑 `dot_config/starship.toml`。

### 常用 alias

```sh
# git（肌肉记忆全保留）
gs        # git status
gcm "msg" # git commit -m
gl        # git l（图形化 log）
gpl       # git pull
gco <br>  # git checkout
gnb <br>  # git checkout -b（新建分支）
ga        # git add -A
gd        # git diff

# 系统
ll        # eza -alh --git（彩色、带 git 状态）
psg <x>   # procs（进程搜索，如 psg nginx；未装 procs 则回退 ps aux | grep）
psx <x>   # 列出匹配进程（保留表头，如 psx node）
pk <x>    # fzf 交互选中进程并 kill（默认 SIGTERM，可 KILL_SIGNAL=9 pk）
lt        # eza --tree（目录树）

# 现代扩展工具（装了才生效）
lg        # lazygit（git TUI）
lzd       # lazydocker（docker TUI）
du        # dust（磁盘占用树）
df        # duf（磁盘概览）
top       # btop（系统监控）
zq        # zellij 四宫格布局
zd        # zellij 左右双栏布局
# 直接命令：jq / yq（JSON·YAML）、gh（GitHub CLI）、tldr（命令示例）、
#           glow file.md（渲染 Markdown）、http（HTTPie 调 API）

# 全局 alias（管道简写）
ls foo G bar   # = ls foo | grep bar
some_cmd L     # = some_cmd | less
```

完整列表见 `dot_config/zsh/aliases.zsh` 和 `dot_config/zsh/git.zsh`。

### 目录跳转 z

```sh
z down        # 跳到最常访问的、名字含 "down" 的目录（如 ~/Downloads）
z proj repo   # 多关键词
zi            # 交互式 fzf 选择
```

> `z` 靠使用频率学习，用得越多越准。刚装时数据库为空，正常 `cd` 几次后就生效。

### 历史命令搜索

```
输入命令的一部分（如 cu），按 ↑ / ↓
→ 只在匹配 "cu" 的历史里翻（找到 curl http://192.168.0.27:8098）
```

另外 `Ctrl-r` 由 atuin 接管（更强的全局历史搜索）。

### 本地个性化：.zsh.before / .zsh.after

不想把机器专属配置提交到公共仓库时：

```sh
# 主配置【之前】：设 PATH、代理、环境变量
echo 'export http_proxy=...' > ~/.zsh.before/00-proxy.zsh

# 主配置【之后】：覆盖 alias、加本机函数（优先级最高）
echo 'alias deploy="..."' > ~/.zsh.after/00-local.zsh
```

### 快速改 alias：ar / ae

```sh
ae   # 用 chezmoi edit 打开 aliases.zsh 源文件并 --apply（改动进仓库，不会被 apply 还原）
ar   # 重新加载 aliases.zsh（当前 shell 立即生效）
```

> 只想临时在当前 shell 加个别名，直接写 `~/.zsh.after/00-local.zsh`（机器专属，不进仓库）。

---

## zellij 终端复用

终端复用器（多面板 / 多标签 / 会话保留）。配置里加了 **`Ctrl-b` 前缀的 tmux 兼容模式**，
tmux 的肌肉记忆基本能直接沿用：先按 `Ctrl-b`，松开，再按下一个命令键。

### 启动 / 会话

```sh
zellij            # 普通启动
zq                # 四宫格布局（alias = zellij --layout quad）
zd                # 左右双栏布局（alias = zellij --layout dual）

zellij ls         # 列出会话
zellij attach     # 接回上一个会话（detach 后恢复）
```

### 快捷键（都是先按 `Ctrl-b`，再按后一个键）

**面板 pane**

| 按键 | 作用 |
|---|---|
| `Ctrl-b` `%` | 竖分屏（左右） |
| `Ctrl-b` `"` | 横分屏（上下） |
| `Ctrl-b` `h/j/k/l` | 面板间移动焦点（也可用方向键） |
| `Ctrl-b` `o` | 切到下一个面板 |
| `Ctrl-b` `z` | 当前面板全屏切换 |
| `Ctrl-b` `x` | 关闭当前面板 |

**标签 tab（相当于 tmux 的 window）**

| 按键 | 作用 |
|---|---|
| `Ctrl-b` `c` | 新建 tab |
| `Ctrl-b` `n` / `p` | 下一个 / 上一个 tab |
| `Ctrl-b` `1`..`5` | 跳到第 N 个 tab |
| `Ctrl-b` `,` | 重命名当前 tab |

**会话 / 其他**

| 按键 | 作用 |
|---|---|
| `Ctrl-b` `d` | detach（脱离，会话在后台保留） |
| `Ctrl-b` `[` | 进入滚动模式（翻历史，`q`/`Esc` 退出） |
| `Ctrl-b` `s` | 打开会话管理器 |
| `Ctrl-b` `Ctrl-b` | 把 `Ctrl-b` 透传给内部程序 |

### 小提示

- 开了 `copy_on_select` + `mouse_mode`：鼠标选中文本即自动复制。
- 底部状态栏会实时显示当前模式和可用快捷键，忘了就看它。
- 改了 `~/.config/zellij/` 配置后需 `chezmoi apply` 再重启 zellij 生效。
- 预设布局文件在 `~/.config/zellij/layouts/`（`quad.kdl` / `dual.kdl`），可自行增删。

---

## 各组件说明

- **chezmoi** — dotfiles 管理器。source 是本仓库，target 是 `$HOME`。改配置后用 `chezmoi apply` 同步。
- **starship** — 提示符。`~/.config/starship.toml`。
- **antidote** — zsh 插件管理器。插件清单在 `~/.zsh_plugins.txt`，改动后下次启动自动重编译缓存。
- **zoxide / fzf / eza / bat / fd / ripgrep / delta / atuin** — 现代 CLI，均在 `tools.zsh` 里做了「存在才启用」的安全初始化，缺任何一个都不会让 shell 报错。
- **mise** — 运行时（node/python/...）版本管理，`eval "$(mise activate zsh)"`，**刻意不在 prompt 显示版本号**。
  全局默认版本在 `~/.config/mise/config.toml`（默认 node=lts / python=latest），新机器 `mise install` 一键装齐；
  项目级用本地 `.mise.toml` 精确锁版本。
- **LazyVim** — Neovim 发行版；首次打开 `nvim` 会自动安装插件。语言支持通过 `lazyvim.json`
  的 extras 启用：Python / JavaScript·TypeScript / JSON / YAML / C·C++(clangd) / Docker /
  Markdown / TOML（含 LSP、补全、格式化 prettier），配置文件类语言的 treesitter 高亮在
  `lua/plugins/init.lua`；自定义键位在 `lua/config/keymaps.lua`，插件放 `~/.config/nvim/lua/plugins/`。
- **zellij** — 终端复用器，配置里加了 **Ctrl-b 前缀的 tmux 兼容模式**（`Ctrl-b` 后 `%` 竖分屏、
  `"` 横分屏、`c` 新标签、`hjkl` 切换面板）。另带两个预设布局：
  `zq`（四宫格 `zellij --layout quad`）、`zd`（左右双栏 `zellij --layout dual`）。
- **tmux** — 保留作为兜底，键位与 zellij 对齐（`Ctrl-b` 前缀，`hjkl` 切面板、`HJKL` 调大小、`z` 全屏、
  `n`/`p` 切窗口），状态栏与 nvim/zellij/ghostty 统一 tokyonight 配色，macOS 上 `y` 复制走 `pbcopy`。
- **终端配色** — ghostty / zellij / nvim / tmux 全部统一到 **tokyonight**，观感一致。
- **macos-defaults** — 可选的 macOS 系统调优脚本（`~/.local/bin/macos-defaults`，**不自动运行**）。
  新 Mac 手动跑一次：加快键盘重复、Finder 显示隐藏文件/扩展名/路径栏、Dock 自动隐藏、截图存
  `~/Screenshots`、关智能引号等。全部可逆，非 macOS 会直接退出。

---

## 常见操作速查

```sh
chezmoi edit ~/.zshrc      # 编辑（自动定位到 source 文件）
chezmoi apply              # 把 source 的改动同步到 $HOME
chezmoi diff               # 预览将要发生的改动
chezmoi cd                 # 进入 source 仓库目录
chezmoi update             # git pull + apply（多机同步）
chezmoi managed            # 列出所有被管理的文件
chezmoi add ~/.foorc       # 把一个新文件纳入管理
```

---

## 自定义与扩展

- **加 zsh 插件**：编辑 `~/.zsh_plugins.txt`，加一行 `owner/repo`，重启 shell。
- **加 alias**：`ae` 或直接编辑 `dot_config/zsh/aliases.zsh` / `git.zsh`。
- **加安装的软件**：
  - macOS → 编辑 `dot_config/homebrew/Brewfile`（`brew`/`cask` 一行一个）
  - Linux → 编辑 `run_once_before_10-install-packages.sh.tmpl`（apt 列表或加一行 `gh_install`）。核心工具装完用 `require <bin>` 标记为必需：缺失会让脚本非零退出、下次 `chezmoi apply` 自动重试；不加 `require` 的即为可选，失败只提示、不阻断。
- **改 prompt**：编辑 `dot_config/starship.toml`。
- **加 nvim 插件**：在 `dot_config/nvim/lua/plugins/` 下加 `.lua` 文件。

### 健康自检：dotfiles-doctor

装完或想确认环境是否完整时：

```sh
dotfiles-doctor    # 检查所有工具是否就位、配置文件、默认 shell、PATH、git 身份
```
输出 `ok / warn / missing` 汇总，缺东西会提示如何补装。

### git 身份

`chezmoi init` 时会**交互式询问一次** git 用户名和邮箱，存入 chezmoi data，
自动写进 `~/.gitconfig`。想改：`chezmoi init`（重新问）或直接建 `~/.gitconfig.user` 覆盖。

### secrets 加密（可选，chezmoi + age）

想把 SSH config、API token 等私密文件安全放进仓库（加密后再提交）：

```sh
# 1. 生成 age 密钥（私钥留本地，不进仓库）
age-keygen -o ~/.config/chezmoi/key.txt

# 2. 在 ~/.config/chezmoi/chezmoi.toml 里启用 age
#    [age]
#      identity = "~/.config/chezmoi/key.txt"
#      recipient = "age1......"   # 上一步输出的 public key
#    encryption = "age"

# 3. 加密纳管一个私密文件
chezmoi add --encrypt ~/.ssh/config

# 4. 新机器上把 key.txt 手动拷过去（唯一需要手动传的东西），其余 chezmoi 自动解密
```

> 私钥 `key.txt` 是唯一不能进仓库的东西，用你信任的渠道（如密码管理器）在机器间传递。

### CI（GitHub Actions）

`.github/workflows/ci.yml` 在每次 push 自动：渲染安装脚本并 `bash -n`、`shellcheck`、
`zsh -n` 校验所有 zsh 模块、`chezmoi init` 冒烟测试。**避免推了才发现脚本崩**。

---

## 常见问题排查

### `zsh: command not found: chezmoi`

`get.chezmoi.io` 安装脚本**默认把二进制装到运行命令时所在目录的 `./bin/chezmoi`**
（不是 `~/.local/bin`），所以新终端里可能找不到 `chezmoi`。

```sh
# 1. 找到 chezmoi 被装到哪了
find ~ -name chezmoi -type f 2>/dev/null
# 常见结果：~/bin/chezmoi 或 你当初运行安装命令的目录/bin/chezmoi

# 2a. 临时用全路径跑（把路径换成上面找到的）
~/projects/bin/chezmoi update

# 2b. 或一劳永逸：重装到 ~/.local/bin（本仓库 PATH 认这个位置）
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
# 之后
~/.local/bin/chezmoi update
exec zsh          # 重载后 chezmoi 就在 PATH 里了
```

> 建议初次安装就带 `-b ~/.local/bin` 指定位置，避免这个坑：
> ```sh
> sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply git@github.com:wangyanxing/homelab_dotfiles.git
> ```

### clone 报 `Authentication failed ... Password authentication is not supported`

私有仓库用 HTTPS clone 会失败（GitHub 不再支持密码认证）。改用 **SSH URL**：

```sh
chezmoi init --apply git@github.com:wangyanxing/homelab_dotfiles.git
# 前提：本机 SSH key 已加到 GitHub。测试：ssh -T git@github.com
```

### `<文件> has changed since chezmoi last wrote it`

你手动改过该文件、同时源也更新了，chezmoi 停下来保护你的改动。

```sh
# 看差异（左=源，右=你的当前文件）
diff ~/.local/share/chezmoi/dot_config/zsh/aliases.zsh ~/.config/zsh/aliases.zsh
```
- 想保留手动改动 → 先把它挪进 `~/.zsh.after/`（本机专属，不进共享源）
- 确认可丢弃、直接采用源版本 → `chezmoi apply --force <该文件>`

### vim 背景色错乱 / `neocomplete requires Vim ...` 报错

这是旧 YADR 的 `~/.vimrc` 软链还在，`vim` 加载了它。清掉即可：

```sh
mv ~/.vimrc ~/.vim ~/.vimrc.before ~/.vimrc.after ~/dotfiles-backup/ 2>/dev/null
```
本配置的 `vim`/`vi` 已别名到 `nvim`（LazyVim），清掉 YADR 软链后重开终端即正常。

### 往安装脚本加了新工具，但已装过的机器不自动装

`run_once_before_*` 脚本**每台机器只跑一次**（chezmoi 记住了它的哈希）。
之后你在脚本里新增了工具，已经跑过的机器不会自动重装。三种办法：

```sh
# 办法 A（推荐）：清掉脚本执行记录，让它下次 apply 时重跑
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply

# 办法 B：手动把新工具装上（macOS 例）
brew install lazygit jq yq dust duf procs btop gh tealdeer lazydocker glow httpie

# 办法 C（Ubuntu 手动）：直接从各项目 GitHub release 下二进制到 ~/.local/bin
#   （或按办法 A 让脚本重跑，Linux 分支会自动拉取）
```

> 因为脚本对每个包都有 `command -v` / `brew list` 判断，重跑是**幂等**的——
> 已装的跳过，只补新的，安全。

---

## 卸载 / 回滚

```sh
# 恢复之前备份的旧配置
mv ~/dotfiles-backup/.zshrc ~/.zshrc   # 等

# 让 chezmoi 停止管理（不删除已生成的文件）
chezmoi purge
```
