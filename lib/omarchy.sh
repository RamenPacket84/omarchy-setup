# wrappers around Omarchy commands

require_omarchy() {
  command -v omarchy >/dev/null 2>&1 || die "omarchy is not on PATH"
  local version
  version="$(omarchy version 2>/dev/null || true)"
  [[ $version == 4.* ]] || die "Omarchy 4.x required (found: ${version:-unknown})"
}

pkg_present() {
  omarchy-pkg-present "$@" >/dev/null 2>&1
}

in_hyprland() {
  [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && command -v hyprctl >/dev/null 2>&1
}

# Display name or slug -> slug (Everforest / everforest / "Tokyo Night").
theme_slug() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-'
}

run() {
  local rc
  if (( DRY_RUN )); then
    log "DRY: $*"
    return 0
  fi
  log "+ $*"
  if [[ -n ${SETUP_LOG:-} ]]; then
    "$@" 2>&1 | tee -a "$SETUP_LOG"
    rc=${PIPESTATUS[0]}
    return "$rc"
  fi
  "$@"
}

pkg_add() {
  local missing=()
  local pkg
  (($#)) || return 0
  for pkg in "$@"; do
    if pkg_present "$pkg"; then
      log "package already installed: $pkg"
    else
      missing+=("$pkg")
    fi
  done
  ((${#missing[@]})) || return 0
  run omarchy pkg add "${missing[@]}"
}
