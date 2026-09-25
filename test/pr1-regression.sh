#!/usr/bin/env bash
# ============================================================================
#  PR1 regression tests — Shell safety, chezmoi edit entry, plugin cache.
#
#  Guards the four PR1 fixes so they can't silently regress:
#    1. Ctrl-x Ctrl-l history re-exec binding is gone.
#    2. `gar` process-wide SIGHUP broadcast (and TRAPHUP) is gone.
#    3. `ae` edits the chezmoi SOURCE file (chezmoi edit), not the deployed copy.
#    4. plugin cache: atomic write (temp + mv) and a guarded, degradable start.
#
#  Static checks only. Does NOT run the installer or touch the network.
#  Run from the repo root:  ./test/pr1-regression.sh
# ============================================================================
set -uo pipefail

# repo root = parent of this script's dir (works regardless of CWD)
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
zdir="$root/dot_config/zsh"

fails=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; fails=$((fails + 1)); }

# assert_absent <label> <regex> <file>
assert_absent() {
  if grep -Eq "$2" "$3"; then fail "$1"; else pass "$1"; fi
}
# assert_present <label> <regex> <file>
assert_present() {
  if grep -Eq "$2" "$3"; then pass "$1"; else fail "$1"; fi
}

echo ">>> PR1 regression checks"

# --- 1. Ctrl-x Ctrl-l history re-exec binding removed -----------------------
assert_absent "no ^X^L keybinding"            '\^X\^L'                  "$zdir/functions.zsh"
assert_absent "no insert-last-command widget" 'insert-last-command'     "$zdir/functions.zsh"
# the specific footgun: eval of a history entry
assert_absent "no eval of history entry"      'eval[^\n]*history'       "$zdir/functions.zsh"

# --- 2. gar SIGHUP broadcast + TRAPHUP removed ------------------------------
assert_absent "no gar alias"        '\bgar\b'                           "$zdir/aliases.zsh"
assert_absent "no killall -HUP zsh" 'killall[^\n]*-HUP'                 "$zdir/aliases.zsh"
assert_absent "no TRAPHUP handler"  'TRAPHUP'                           "$zdir/functions.zsh"

# --- 3. ae goes through chezmoi edit ----------------------------------------
assert_present "ae uses chezmoi edit"        'alias ae=.*chezmoi edit'  "$zdir/aliases.zsh"
# ar (current-shell reload) is still kept
assert_present "ar still re-sources aliases" 'alias ar=.*source'        "$zdir/aliases.zsh"

# --- 4. plugin cache: atomic write + guarded/degradable start ---------------
assert_present "plugin cache uses mktemp"     'mktemp'                  "$zdir/plugins.zsh"
assert_present "plugin cache swaps via mv -f" 'mv -f "\$zsh_plugins_tmp"' "$zdir/plugins.zsh"
# must NOT redirect antidote bundle straight onto the live cache file
assert_absent  "no direct bundle > live cache"    'bundle[^\n]*>[^\n]*zsh_plugins_zsh"$' "$zdir/plugins.zsh"
# degradable start: antidote missing must not hard-fail
assert_present "guarded start when antidote missing" 'antidote unavailable' "$zdir/plugins.zsh"

# --- zsh syntax parse for every module + entrypoint -------------------------
if command -v zsh >/dev/null 2>&1; then
  for f in "$zdir"/*.zsh "$root/dot_zshrc"; do
    if zsh -n "$f" 2>/dev/null; then pass "zsh -n $(basename "$f")"; else fail "zsh -n $(basename "$f")"; fi
  done
else
  echo "  skip zsh -n (zsh not installed)"
fi

echo ">>> ---"
if [[ $fails -gt 0 ]]; then
  echo ">>> PR1 regression: $fails check(s) FAILED" >&2
  exit 1
fi
echo ">>> PR1 regression: all checks passed"
