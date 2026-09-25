# ============================================================================
#  functions.zsh - shell functions & keybindings (ported from YADR).
# ============================================================================

# --- (f)ind by (n)ame -------------------------------------------------------
# usage: fn foo   -> all files with 'foo' in the name (recursive)
fn() {
  if command -v fd >/dev/null 2>&1; then
    fd "$1"
  else
    ls **/*$1*
  fi
}

# --- mkdir + cd -------------------------------------------------------------
mcd() { mkdir -p "$1" && cd "$1"; }

# --- extract almost any archive --------------------------------------------
extract() {
  local f="$1"
  [[ -f "$f" ]] || { echo "extract: '$f' is not a file"; return 1; }
  case "$f" in
    *.tar.bz2) tar xjf "$f" ;;
    *.tar.gz)  tar xzf "$f" ;;
    *.tar.xz)  tar xJf "$f" ;;
    *.tbz2)    tar xjf "$f" ;;
    *.tgz)     tar xzf "$f" ;;
    *.tar)     tar xf "$f" ;;
    *.bz2)     bunzip2 "$f" ;;
    *.gz)      gunzip "$f" ;;
    *.zip)     unzip "$f" ;;
    *.rar)     unrar x "$f" ;;
    *.7z)      7z x "$f" ;;
    *)         echo "extract: don't know how to handle '$f'" ;;
  esac
}

# --- keybindings ------------------------------------------------------------
# emacs-style line editing (default).
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^r' history-incremental-search-backward
