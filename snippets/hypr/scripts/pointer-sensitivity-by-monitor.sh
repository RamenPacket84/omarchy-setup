#!/usr/bin/env bash
# Adjust Hyprland pointer sensitivity based on whether an external monitor
# is active. Global input:sensitivity cannot differ per display, so we
# switch it when monitors are plugged/unplugged.
#
# Tune these if needed (range: -1.0 slow … 1.0 fast; default 0):
LAPTOP_SENSITIVITY="${LAPTOP_SENSITIVITY:-0}"
EXTERNAL_SENSITIVITY="${EXTERNAL_SENSITIVITY:--0.8}"

SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/hypr-pointer-sensitivity.lock"

apply() {
  local target
  if omarchy-hyprland-monitor-external-active; then
    target="$EXTERNAL_SENSITIVITY"
  else
    target="$LAPTOP_SENSITIVITY"
  fi
  # Lua config path: keyword is unavailable; use eval + hl.config.
  hyprctl -q eval "hl.config({ input = { sensitivity = ${target} } })"
}

# Single instance
exec 9>"$LOCK"
flock -n 9 || exit 0

apply

[[ -S $SOCKET ]] || exit 0

while read -r event; do
  case "$event" in
    monitoradded\>\>*|monitoraddedv2\>\>*|monitorremoved\>\>*|monitorremovedv2\>\>*|configreloaded\>\>*)
      apply
      ;;
  esac
done < <(socat -U - "UNIX-CONNECT:$SOCKET")
