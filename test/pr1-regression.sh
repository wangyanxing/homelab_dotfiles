#!/usr/bin/env bash
# ============================================================================
#  Reliability regression tests — PR1 (shell safety) + PR2 (trustworthy install)
#
#  PR1 — guards the four shell fixes so they can't silently regress:
#    1. Ctrl-x Ctrl-l history re-exec binding is gone.
#    2. `gar` process-wide SIGHUP broadcast (and TRAPHUP) is gone.
#    3. `ae` edits the chezmoi SOURCE file (chezmoi edit), not the deployed copy.
#    4. plugin cache: atomic write (temp + mv) and a guarded, degradable start.
#
#  PR2 — guards the installer trust improvements:
#    5. installer prints a required/optional inventory summary.
#    6. required-tool failure exits non-zero (chezmoi retries).
#    7. a standalone re-install command (dotfiles-install) exists.
#    8. experimental (unverified) install paths are labelled as such.
#
#  Features — guards the day-to-day feature additions:
#    9.  secrets: age encryption auto-enables (guarded) only with a key + tool.
#    10. dotfiles-update: pull --rebase -> diff preview -> apply.
#    11. doctor: config-drift + secrets/age status sections.
#    12. age is a declared dependency (Brewfile + Linux installer).
#    13. yazi optional install + cwd-on-exit `y`; atuin stays out of plugins.txt.
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

echo ">>> reliability regression checks"

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

# --- PR2: trustworthy installer ---------------------------------------------
installer="$root/run_once_before_10-install-packages.sh.tmpl"
install_cmd="$root/dot_local/bin/executable_dotfiles-install"

assert_present "installer prints a summary"        'install summary'        "$installer"
assert_present "installer tracks required failures" 'failed_required'        "$installer"
assert_present "required failure exits non-zero"    'exit 1'                 "$installer"
assert_present "experimental path is labelled"      'EXPERIMENTAL'           "$installer"
# standalone re-install command exists and avoids nuking chezmoi script state
if [[ -f "$install_cmd" ]]; then pass "dotfiles-install command present"; else fail "dotfiles-install command present"; fi
assert_present "re-install doesn't wipe scriptState" 'without touching'      "$install_cmd"
# doctor's hint points at the standalone command, not a state-bucket wipe
assert_absent  "doctor no longer suggests wiping state" 'delete-bucket'      "$root/dot_local/bin/executable_dotfiles-doctor"

# --- features: secrets closure, update command, drift detection, mise -------
toml="$root/.chezmoi.toml.tmpl"
doctor="$root/dot_local/bin/executable_dotfiles-doctor"
update_cmd="$root/dot_local/bin/executable_dotfiles-update"

# secrets: age auto-enabled ONLY when key present + tool on PATH (guarded)
assert_present "age auto-enable is guarded by lookPath" 'lookPath "age-keygen"' "$toml"
assert_present "age recipient derived from key"         'age-keygen" "-y"'       "$toml"
# dotfiles-update: pull --rebase, preview, apply
if [[ -f "$update_cmd" ]]; then pass "dotfiles-update command present"; else fail "dotfiles-update command present"; fi
assert_present "update pulls with rebase"  'git pull -- --rebase'  "$update_cmd"
assert_present "update previews via diff"  'chezmoi diff'          "$update_cmd"
# doctor: drift + secrets sections
assert_present "doctor checks config drift" 'chezmoi status'       "$doctor"
assert_present "doctor reports secrets/age" 'secrets \(age\)'      "$doctor"
# age is a declared dependency (macOS Brewfile + Linux installer)
assert_present "Brewfile declares age"      'brew "age"'           "$root/dot_config/homebrew/Brewfile"
assert_present "installer installs age"     'FiloSottile/age'      "$installer"

# yazi: optional file manager with a cwd-on-exit `y` wrapper
assert_present "Brewfile declares yazi"     'brew "yazi"'          "$root/dot_config/homebrew/Brewfile"
assert_present "installer installs yazi"    'sxyazi/yazi'          "$installer"
assert_present "y() wrapper cd's on exit"   'cwd-file'             "$zdir/tools.zsh"
# atuin stays out of the antidote plugin list (avoids Up-arrow clash)
assert_absent  "atuin not an antidote plugin" '^atuinsh/atuin'     "$root/dot_zsh_plugins.txt"
# atuin sync: config managed, enables sync, holds no credentials
assert_present "atuin config enables sync"    'auto_sync = true'   "$root/dot_config/atuin/config.toml"
assert_present "atuin config sets sync server" 'sync_address'      "$root/dot_config/atuin/config.toml"
assert_absent  "atuin config has no session token" 'session'       "$root/dot_config/atuin/config.toml"
assert_present "doctor checks atuin sync"     'atuin sync'         "$doctor"

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
  echo ">>> regression: $fails check(s) FAILED" >&2
  exit 1
fi
echo ">>> regression: all checks passed"
