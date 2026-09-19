# ============================================================================
#  plugins.zsh - zsh plugins via antidote (fast, minimal, transparent).
#  Only the plugins you actually depend on. No prezto megaframework.
# ============================================================================

# Locate antidote (brew on mac/linux, or git clone fallback).
if [[ -r "$(brew --prefix 2>/dev/null)/opt/antidote/share/antidote/antidote.zsh" ]]; then
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
elif [[ -r "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
else
  git clone --depth 1 https://github.com/mattmc3/antidote.git "$HOME/.antidote" 2>/dev/null
  source "$HOME/.antidote/antidote.zsh"
fi

# Plugin bundle: statically compiled from ~/.zsh_plugins.txt and cached to
# ~/.zsh_plugins.zsh for fast startup. Regenerated automatically when the
# .txt file changes. Edit the plugin list in ~/.zsh_plugins.txt.
zsh_plugins_txt="$HOME/.zsh_plugins.txt"
zsh_plugins_zsh="$HOME/.zsh_plugins.zsh"
if [[ ! -f "$zsh_plugins_zsh" || "$zsh_plugins_txt" -nt "$zsh_plugins_zsh" ]]; then
  antidote bundle <"$zsh_plugins_txt" >"$zsh_plugins_zsh"
fi
source "$zsh_plugins_zsh"
unset zsh_plugins_txt zsh_plugins_zsh

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
