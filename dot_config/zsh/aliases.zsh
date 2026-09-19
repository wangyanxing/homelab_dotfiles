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
alias psg="ps aux | grep "     # YADR muscle memory

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
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v rg  >/dev/null 2>&1 && alias grep='rg'

# --- Alias editing (YADR: ae / ar) ------------------------------------------
# ae = alias edit, ar = alias reload. See functions.zsh for the reload trap.
alias ae="\${EDITOR:-nvim} ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh"
alias ar="source ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh"
alias gar="killall -HUP -u \"\$USER\" zsh"   # global alias reload (all shells)

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
