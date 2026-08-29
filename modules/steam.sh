# optional: Steam via Omarchy's gaming installer (multilib, not AUR)

install_steam() {
  if pkg_present steam; then
    log "steam already installed"
    return 0
  fi
  run omarchy install gaming steam
}
