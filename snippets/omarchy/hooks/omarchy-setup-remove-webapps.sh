#!/usr/bin/env bash
# Re-remove stock web apps after omarchy update recopies them.
set -euo pipefail
list="${OMARCHY_SETUP_WEBAPPS_REMOVE:-$HOME/.local/state/omarchy-setup/webapps-remove.txt}"
[[ -f $list ]] || exit 0
while IFS= read -r name || [[ -n $name ]]; do
  [[ -z $name || $name == \#* ]] && continue
  desktop="$HOME/.local/share/applications/${name}.desktop"
  [[ -f $desktop ]] || continue
  OMARCHY_REMOVE_NOTIFY=false omarchy webapp remove "$name" 2>/dev/null || rm -f "$desktop"
done <"$list"
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
