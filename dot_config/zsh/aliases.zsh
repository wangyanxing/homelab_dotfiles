# ============================================================================
#  aliases.zsh - general shell aliases (bash & zsh compatible).
#  Ported from YADR, with all Ruby/Rails/Zeus/spring cruft removed.
# ============================================================================

# --- OS detection -----------------------------------------------------------
platform='unknown'
case "$(uname)" in
  Linux)  platform='linux' ;;
  Darwin) platform='darwin' ;;
esac

# --- ps ---------------------------------------------------------------------
alias psa="ps aux"
# psg: search processes. Uses procs (colored, keeps header, highlights match:
# `psg nginx`) when available; falls back to classic `ps aux | grep`.
if command -v procs >/dev/null 2>&1; then
  alias psg='procs'          # YADR muscle memory, now powered by procs
else
  alias psg="ps aux | grep " # YADR muscle memory
fi
# psx <pattern>: list matching processes (keeps header, excludes the search itself).
# `command grep` so it works even though `grep` is aliased to rg below.
psx() {
  ps auxww | { IFS= read -r header; printf '%s\n' "$header"; command grep -i -- "$*" | command grep -v "command grep -i"; }
}
# pk <pattern>: interactively pick matching process(es) via fzf and kill them.
pk() {
  local pid
  pid=$(ps auxww | sed 1d | fzf -m --header='[kill] select process(es)' --query="$*" | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -"${KILL_SIGNAL:-15}"
}

# --- Moving around ----------------------------------------------------------
alias cdb='cd -'
alias cls='clear;ls'

# --- Human friendly sizes ---------------------------------------------------
alias df='df -h'
alias du='du -h -d 2'

# --- ls / ll  (eza if available, else native colored ls) --------------------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -alh --group-directories-first --git'    # YADR muscle memory
  alias lt='eza --tree --level=2'
  alias lh='eza -alh --sort=modified | head'
else
  if [[ $platform == 'linux' ]]; then
    alias ls='ls --color=auto'
    alias ll='ls -alh --color=auto'
  else
    alias ls='ls -Gh'
    alias ll='ls -alGh'
  fi
  alias lh='ls -alt | head'   # last modified files
fi
alias lsg='ll | grep'

# --- cat / find / grep -> modern equivalents (fallback safe) ----------------
# --style=plain -> syntax highlight only, no line numbers / grid / header
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never --style=plain'
command -v rg  >/dev/null 2>&1 && alias grep='rg'

# --- editor: point vim -> nvim (LazyVim) when nvim is available -------------
# Keeps `vim` muscle memory while actually launching Neovim/LazyVim.
if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
fi

# --- modern extras (each guarded; falls back gracefully if not installed) ---
command -v dust    >/dev/null 2>&1 && alias du='dust'          # disk usage tree
command -v duf     >/dev/null 2>&1 && alias df='duf'           # disk free, pretty
command -v btop    >/dev/null 2>&1 && alias top='btop'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'
command -v lazydocker >/dev/null 2>&1 && alias lzd='lazydocker'

# zellij preset layouts
if command -v zellij >/dev/null 2>&1; then
  alias zq='zellij --layout quad'   # 4-pane grid
  alias zd='zellij --layout dual'   # left | right columns
fi

# --- Alias editing (YADR: ae / ar) ------------------------------------------
# ae = alias edit (via chezmoi, so changes land in the repo, not just the
#      deployed copy that `chezmoi apply` would later overwrite).
# ar = alias reload (re-source into THIS shell only).
alias ae="chezmoi edit --apply ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh"
alias ar="source ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh"

# --- Editor shortcuts -------------------------------------------------------
alias :q='exit'
alias ze="\${EDITOR:-nvim} ${XDG_CONFIG_HOME:-$HOME/.config}/zsh"   # edit zsh config
alias ve="\${EDITOR:-nvim} ${XDG_CONFIG_HOME:-$HOME/.config}/nvim"  # edit nvim config

# --- Common shell shortcuts -------------------------------------------------
alias less='less -r'
alias tf='tail -f'
alias l='less'
alias cl='clear'
alias gz='tar -zcvf'
alias ka9='killall -9'
alias k9='kill -9'

# --- Homebrew ---------------------------------------------------------------
alias brewu='brew update && brew upgrade && brew cleanup && brew doctor'

# --- macOS Finder toggles ---------------------------------------------------
if [[ $platform == 'darwin' ]]; then
  alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
fi

# --- Global aliases (zsh) : pipe helpers (YADR) -----------------------------
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g C='| wc -l'
alias -g H='| head'
alias -g L='| less'
alias -g N='| /dev/null'
alias -g S='| sort'
alias -g G='| grep'          # ls foo G something
