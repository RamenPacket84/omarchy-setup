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

run() {
  if (( DRY_RUN )); then
    log "DRY: $*"
    return 0
  fi
  log "+ $*"
  "$@"
}

pkg_add() {
  local missing=()
  local pkg
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
