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
- [各组件说明](#各组件说明)
- [常见操作速查](#常见操作速查)
- [自定义与扩展](#自定义与扩展)
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
| 编辑器 | **Neovim + LazyVim** | 轻量起步，禁用冗余内置插件 |
| 终端复用 | **zellij**（含 tmux 风格 Ctrl-b 前缀）+ tmux 兜底 | 降低从 tmux 迁移的不适应 |
| 运行时版本管理 | **mise** | 替代 rbenv/nvm，且**不污染 prompt** |
| zsh 插件管理 | **antidote** | 静态编译缓存，启动快 |

---

## 快速开始

### 全新机器一键安装

只需机器上有 `git` 和 `curl`：

```sh
# 1. 安装 chezmoi 并从你的 GitHub 仓库初始化 + 应用
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <你的GitHub用户名>/homelab_dotfiles
```

`chezmoi init --apply` 会自动：
1. 拉取本仓库到 `~/.local/share/chezmoi`
2. 运行 `run_once_before_10-install-packages.sh`（自动装 starship/zoxide/eza/... 全套工具）
3. 把所有配置软链/写入到 `$HOME`

首次启动 zsh 时，antidote 会自动 clone 并编译 zsh 插件（约十几秒，仅一次）。

### 在已有机器上应用

已经在用别的 dotfiles（如 YADR）时，**建议先看差异、备份，再应用**：

```sh
# 安装 chezmoi（macOS）
brew install chezmoi

# 用本仓库作为 source 初始化（不会修改任何文件）
chezmoi init --source /path/to/homelab_dotfiles

# 只读预览：将会对 $HOME 做哪些改动
chezmoi diff

# 确认无误后再真正写入
chezmoi apply
```

> ⚠️ 如果你现有的 `~/.zshrc` `~/.gitconfig` 等是指向旧 dotfiles 的**软链**，
> apply 前请先把它们移走备份：
> ```sh
> mkdir -p ~/dotfiles-backup
> mv ~/.zshrc ~/.zshenv ~/.gitconfig ~/.tmux.conf ~/dotfiles-backup/ 2>/dev/null
> ```

---

## 仓库结构

chezmoi 约定：`dot_xxx` → `~/.xxx`，`.tmpl` 结尾为模板，`run_once_before_*` 为首次安装脚本。

```
homelab_dotfiles/                              # chezmoi source 目录
├── .chezmoi.toml.tmpl                         # chezmoi 配置模板（editor 等变量）
├── .chezmoiignore                             # 不纳入管理的文件（README/LICENSE/.git）
├── run_once_before_10-install-packages.sh.tmpl# 新机器自动安装依赖（brew/apt，跨平台）
│
├── dot_zshenv.tmpl                            # ~/.zshenv  环境变量、PATH、Homebrew
├── dot_zshrc                                  # ~/.zshrc   加载链入口
├── dot_zsh_plugins.txt                        # ~/.zsh_plugins.txt  antidote 插件清单
│
├── dot_config/
│   ├── starship.toml                          # ~/.config/starship.toml  提示符
│   ├── zsh/                                    # ~/.config/zsh/  拆分的 zsh 模块
│   │   ├── options.zsh                         #   AUTO_CD / 补全 / history 等 setopt
│   │   ├── plugins.zsh                         #   antidote 加载 + 键位绑定
│   │   ├── aliases.zsh                         #   系统 alias（psg/ll/ar/ae/全局 alias）
│   │   ├── git.zsh                             #   git alias（gpl/gcm/gl/gs/gco...）
│   │   ├── functions.zsh                       #   函数（fn/mcd/extract）+ Ctrl-x Ctrl-l
│   │   └── tools.zsh                           #   zoxide/fzf/atuin/mise/bat/starship 初始化
│   ├── nvim/                                   # ~/.config/nvim/  LazyVim
│   │   ├── init.lua
│   │   └── lua/config/lazy.lua                 #   lazy.nvim 引导（禁用冗余内置插件）
│   │   └── lua/plugins/init.lua                #   你的自定义插件 / 覆盖
│   └── zellij/config.kdl                       # ~/.config/zellij/config.kdl（tmux 风格前缀）
│
├── dot_gitconfig.tmpl                         # ~/.gitconfig  git 子命令别名 + delta
├── dot_gitignore_global                       # ~/.gitignore_global
├── dot_tmux.conf                              # ~/.tmux.conf  tmux 兜底配置
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
| `ar` / `ae` 改 alias | 同名函数 | ✅ 保留 |
| git alias（gpl/gcm/gl/gs...） | `git.zsh` | ✅ 全保留 |
| 系统 alias（psg/ll...） | `aliases.zsh` | ✅ 保留 |
| 全局 alias（`...` `G` `L`） | `aliases.zsh` | ✅ 保留 |
| Ctrl-x Ctrl-l 插入上条命令输出 | `functions.zsh` | ✅ 保留 |
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
psg <x>   # ps aux | grep x
lt        # eza --tree（目录树）

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
ae   # 用编辑器打开 aliases.zsh
ar   # 重新加载 aliases.zsh（当前 shell 立即生效）
gar  # 让所有已打开的 zsh 会话都重新加载 alias
```

---

## 各组件说明

- **chezmoi** — dotfiles 管理器。source 是本仓库，target 是 `$HOME`。改配置后用 `chezmoi apply` 同步。
- **starship** — 提示符。`~/.config/starship.toml`。
- **antidote** — zsh 插件管理器。插件清单在 `~/.zsh_plugins.txt`，改动后下次启动自动重编译缓存。
- **zoxide / fzf / eza / bat / fd / ripgrep / delta / atuin** — 现代 CLI，均在 `tools.zsh` 里做了「存在才启用」的安全初始化，缺任何一个都不会让 shell 报错。
- **mise** — 运行时（node/python/...）版本管理，`eval "$(mise activate zsh)"`，**刻意不在 prompt 显示版本号**。
- **LazyVim** — Neovim 发行版；首次打开 `nvim` 会自动安装插件。自定义放 `~/.config/nvim/lua/plugins/`。
- **zellij** — 终端复用器，配置里加了 **Ctrl-b 前缀的 tmux 兼容模式**（`Ctrl-b` 后 `%` 竖分屏、`"` 横分屏、`c` 新标签、`hjkl` 切换面板），降低 tmux 用户的迁移成本。
- **tmux** — 保留 `~/.tmux.conf` 作为兜底。

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
- **加安装的软件**：编辑 `run_once_before_10-install-packages.sh.tmpl` 的 `brew_pkgs` / apt 列表。
- **改 prompt**：编辑 `dot_config/starship.toml`。
- **加 nvim 插件**：在 `dot_config/nvim/lua/plugins/` 下加 `.lua` 文件。

---

## 卸载 / 回滚

```sh
# 恢复之前备份的旧配置
mv ~/dotfiles-backup/.zshrc ~/.zshrc   # 等

# 让 chezmoi 停止管理（不删除已生成的文件）
chezmoi purge
```
