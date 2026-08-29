# optional: Ollama from extra, enable the system unit
# Does not pull models.

install_ollama() {
  pkg_add ollama
  if (( DRY_RUN )); then
    log "DRY: systemctl enable --now ollama"
    return 0
  fi
  if systemctl is-enabled ollama >/dev/null 2>&1; then
    log "ollama unit already enabled"
  else
    run sudo systemctl enable --now ollama
  fi
}
