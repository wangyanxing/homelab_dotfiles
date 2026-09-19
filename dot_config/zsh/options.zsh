# ============================================================================
#  options.zsh - shell behavior. These are the YADR "feels" you rely on,
#  implemented with plain zsh (zero framework dependency).
# ============================================================================

# --- Directory navigation ---------------------------------------------------
setopt AUTO_CD              # type a dir name + Enter -> cd into it (no `cd`)
setopt AUTO_PUSHD           # cd pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# --- Globbing / correction --------------------------------------------------
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB         # case-insensitive globbing
setopt CORRECT              # offer to correct mistyped commands

# --- History ----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY       # timestamp each entry
setopt INC_APPEND_HISTORY     # write immediately, not on exit
setopt SHARE_HISTORY          # share across sessions
setopt HIST_IGNORE_ALL_DUPS   # dedupe
setopt HIST_IGNORE_SPACE      # cmd starting with space -> not saved
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # expand !! etc. before running

# --- Completion system ------------------------------------------------------
autoload -Uz compinit
# Cache compdump for faster startup; rebuild ~daily.
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select                       # arrow-key menu
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # colored matches
zstyle ':completion:*' group-name ''

# --- Fuzzy / typo-tolerant completion (YADR: "mistype a dir, tab fixes it") -
# case-insensitive -> partial-word -> substring matching, progressively looser.
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
