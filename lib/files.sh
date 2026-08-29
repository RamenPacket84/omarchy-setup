# idempotent file helpers

backup_file() {
  local path="$1"
  [[ -f $path ]] || return 0
  local bak="${path}.bak.$(date +%s)"
  if (( DRY_RUN )); then
    log "DRY: cp $path $bak"
    return 0
  fi
  cp "$path" "$bak"
  log "backed up $path -> $bak"
}

# Copy src to dest if dest is missing.
install_if_missing() {
  local src="$1"
  local dest="$2"
  local mode="${3:-}"
  if [[ -e $dest ]]; then
    log "exists, skipping copy: $dest"
    return 0
  fi
  if (( DRY_RUN )); then
    log "DRY: install $src -> $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  [[ -n $mode ]] && chmod "$mode" "$dest"
  log "installed $dest"
}

# Replace dest with src after backup if contents differ.
install_file() {
  local src="$1"
  local dest="$2"
  local mode="${3:-}"
  if [[ -f $dest ]] && cmp -s "$src" "$dest"; then
    log "unchanged: $dest"
    return 0
  fi
  backup_file "$dest"
  if (( DRY_RUN )); then
    log "DRY: install $src -> $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  [[ -n $mode ]] && chmod "$mode" "$dest"
  log "wrote $dest"
}

# Append a managed block once. Marker is a unique comment line.
ensure_managed_block() {
  local dest="$1"
  local marker="$2"
  local block="$3"
  if [[ -f $dest ]] && grep -Fq "$marker" "$dest"; then
    log "managed block already present: $dest"
    return 0
  fi
  backup_file "$dest"
  if (( DRY_RUN )); then
    log "DRY: append managed block to $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  {
    [[ -f $dest ]] && cat "$dest"
    printf '\n%s\n%s\n' "$marker" "$block"
  } >"${dest}.tmp"
  mv "${dest}.tmp" "$dest"
  log "appended managed block to $dest"
}

merge_shell_json() {
  local patch="$1"
  local dest="$HOME/.config/omarchy/shell.json"
  [[ -f $dest ]] || die "missing $dest"
  if (( DRY_RUN )); then
    log "DRY: merge $patch into $dest"
    return 0
  fi
  command -v jq >/dev/null 2>&1 || die "jq is required to merge shell.json"
  backup_file "$dest"
  local tmp
  tmp="$(mktemp)"
  jq -s '.[0] * .[1]' "$dest" "$patch" >"$tmp"
  mv "$tmp" "$dest"
  log "merged idle/bar settings into $dest"
}
