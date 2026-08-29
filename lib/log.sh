# logging helpers for omarchy-setup

log() {
  local msg
  msg="$(date '+%Y-%m-%d %H:%M:%S') $*"
  printf '%s\n' "$msg"
  if [[ -n ${SETUP_LOG:-} ]]; then
    printf '%s\n' "$msg" >>"$SETUP_LOG"
  fi
}

die() {
  log "ERROR: $*"
  exit 1
}

warn() {
  log "WARN: $*"
}
