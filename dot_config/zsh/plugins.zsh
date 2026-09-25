# ============================================================================
#  plugins.zsh - zsh plugins via antidote (fast, minimal, transparent).
#  Only the plugins you actually depend on. No prezto megaframework.
# ============================================================================

# Locate antidote: git clone under ~/.antidote (all platforms), or Homebrew
# (macOS). Linux installs it to ~/.antidote via the bootstrap script.
# If antidote can't be found OR bootstrapped, we DON'T abort: the shell must
# still come up usable (just without plugins), so every branch here is guarded.
antidote_zsh=""
if [[ -r "$HOME/.antidote/antidote.zsh" ]]; then
  antidote_zsh="$HOME/.antidote/antidote.zsh"
elif command -v brew >/dev/null 2>&1 && [[ -r "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh" ]]; then
  antidote_zsh="$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
elif command -v git >/dev/null 2>&1 && \
     git clone --depth 1 https://github.com/mattmc3/antidote.git "$HOME/.antidote" 2>/dev/null && \
     [[ -r "$HOME/.antidote/antidote.zsh" ]]; then
  antidote_zsh="$HOME/.antidote/antidote.zsh"
fi

if [[ -z "$antidote_zsh" ]]; then
  # No antidote available (offline first run, no git, clone failed). Skip
  # plugins entirely rather than sourcing a missing file / erroring out.
  echo "plugins.zsh: antidote unavailable; starting shell without plugins" >&2
  unset antidote_zsh
else
  source "$antidote_zsh"
  unset antidote_zsh

  # Plugin bundle: statically compiled from ~/.zsh_plugins.txt and cached to
  # ~/.zsh_plugins.zsh for fast startup. Regenerated automatically when the
  # .txt file changes. Edit the plugin list in ~/.zsh_plugins.txt.
  zsh_plugins_txt="$HOME/.zsh_plugins.txt"
  zsh_plugins_zsh="$HOME/.zsh_plugins.zsh"
  if [[ -r "$zsh_plugins_txt" && ( ! -f "$zsh_plugins_zsh" || "$zsh_plugins_txt" -nt "$zsh_plugins_zsh" ) ]]; then
    # Write to a temp file first; only replace the real cache on success. A
    # failed/empty bundle (antidote missing, network error) must NOT clobber a
    # working cache, and must NOT leave a stale-but-newer empty file that would
    # make the next startup skip regeneration.
    zsh_plugins_tmp="$(mktemp "${zsh_plugins_zsh}.XXXXXX")"
    if antidote bundle <"$zsh_plugins_txt" >"$zsh_plugins_tmp" && [[ -s "$zsh_plugins_tmp" ]]; then
      mv -f "$zsh_plugins_tmp" "$zsh_plugins_zsh"
    else
      echo "plugins.zsh: antidote bundle failed; keeping previous cache" >&2
      rm -f "$zsh_plugins_tmp"
    fi
    unset zsh_plugins_tmp
  fi
  [[ -r "$zsh_plugins_zsh" ]] && source "$zsh_plugins_zsh"
  unset zsh_plugins_txt zsh_plugins_zsh
fi

# --- key bindings for history-substring-search ------------------------------
# Up/Down arrows: search history for entries matching what you've typed.
# e.g. type "cu" + Up  ->  finds your last `curl http://192.168.0.27:8098`
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# Also bind for terminals sending different codes (tmux/zellij/ghostty)
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# autosuggestions: accept with Right-arrow / End (default), tune color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# --- history-substring-search behavior --------------------------------------
# highlight style for the matched command when found
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=cyan,fg=black,bold'
# highlight style when nothing matches
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
# 'i' = case-insensitive (typing "CU" also matches "curl")
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'
