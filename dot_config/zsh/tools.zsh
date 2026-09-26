# ============================================================================
#  tools.zsh - initialize modern CLI tools. Each guarded so a missing tool
#  never breaks your shell (important for partial installs / new machines).
# ============================================================================

# --- zoxide : smart directory jumping (replaces YADR's fasd `z`) ------------
# `z down` -> jumps to ~/Downloads,  `z proj` -> most-used matching dir, etc.
# `zi` for interactive fzf pick.  Behavior matches your old `z` muscle memory.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# --- fzf : fuzzy finder (Ctrl-t files, Ctrl-r history, Alt-c cd) ------------
if command -v fzf >/dev/null 2>&1; then
  # fzf >= 0.48 ships shell integration via `fzf --zsh`
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  fi
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
  command -v fd >/dev/null 2>&1 && \
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
fi

# --- atuin : magical shell history (optional; complements Up-arrow search) --
# Bound to Ctrl-r only, so it does NOT hijack the Up-arrow substring search
# you rely on (that stays with zsh-history-substring-search).
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# --- mise : runtime version manager (replaces rbenv/nvm) --------------------
# Note: intentionally NOT shown in the prompt (no more "[ruby-4.0.6]").
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# --- yazi : terminal file manager -------------------------------------------
# `y` opens yazi and, on quit, cd's your shell to the last directory you were
# browsing (yazi's official cwd-on-exit wrapper). Plain `yazi` still works and
# leaves your $PWD untouched.
if command -v yazi >/dev/null 2>&1; then
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp" 2>/dev/null)" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd" || return
    fi
    rm -f -- "$tmp"
  }
fi

# --- bat : theme for `cat` / man pages --------------------------------------
if command -v bat >/dev/null 2>&1; then
  export BAT_THEME="ansi"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# --- starship : the prompt (replicates the old skwp look) -------------------
# Loaded LAST so nothing overrides PROMPT/RPROMPT.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
