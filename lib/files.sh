# idempotent file helpers

INSTALL_FILE_CHANGED=0
SETUP_STATE="${SETUP_STATE:-$HOME/.local/state/omarchy-setup}"
BACKUP_ROOT="${BACKUP_ROOT:-$SETUP_STATE/backups}"

# Print non-empty, non-comment lines from a manifest.
manifest_lines() {
  local file="$1"
  local line
  [[ -f $file ]] || die "missing manifest: $file"
  while IFS= read -r line || [[ -n $line ]]; do
    [[ -z $line || $line == \#* ]] && continue
    printf '%s\n' "$line"
  done <"$file"
}

backup_file() {
  local path="$1"
  [[ -f $path ]] || return 0
  local bak="$BACKUP_ROOT/${path#/}.bak.$(date +%s)"
  if (( DRY_RUN )); then
    log "DRY: cp $path $bak"
    return 0
  fi
  mkdir -p "$(dirname "$bak")"
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
# Sets INSTALL_FILE_CHANGED=1 when it writes (or would write in --dry-run).
# The caller zeros INSTALL_FILE_CHANGED before a batch that cares.
install_file() {
  local src="$1"
  local dest="$2"
  local mode="${3:-}"
  if [[ -f $dest ]] && cmp -s "$src" "$dest"; then
    if [[ -n $mode ]] && (( ! DRY_RUN )); then
      chmod "$mode" "$dest"
    fi
    log "unchanged: $dest"
    return 0
  fi
  INSTALL_FILE_CHANGED=1
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

# Keep a replaceable region in dest bounded by marker and "${marker} end".
# Legacy files that have the begin marker and no end marker (block was
# appended at EOF) are rewritten with an end marker.
ensure_managed_block() {
  local dest="$1"
  local marker="$2"
  local block="$3"
  local end_marker="${marker} end"
  local block_file out
  block_file="$(mktemp)"
  out="$(mktemp)"
  printf '%s\n' "$block" >"$block_file"

  if [[ -f $dest ]]; then
    awk -v begin="$marker" -v end="$end_marker" -v blockfile="$block_file" '
      function print_block() {
        print begin
        while ((getline line < blockfile) > 0) print line
        close(blockfile)
        print end
      }
      $0 == begin {
        print_block()
        done = 1
        in_block = 1
        next
      }
      in_block {
        if ($0 == end) in_block = 0
        next
      }
      { print }
      END {
        if (!done) {
          if (NR > 0) print ""
          print_block()
        }
      }
    ' "$dest" >"$out"
  else
    {
      printf '%s\n' "$marker"
      printf '%s\n' "$block"
      printf '%s\n' "$end_marker"
    } >"$out"
  fi

  if [[ -f $dest ]] && cmp -s "$dest" "$out"; then
    rm -f "$block_file" "$out"
    log "managed block unchanged: $dest"
    return 0
  fi
  backup_file "$dest"
  if (( DRY_RUN )); then
    rm -f "$block_file" "$out"
    log "DRY: update managed block in $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  mv "$out" "$dest"
  rm -f "$block_file"
  log "updated managed block in $dest"
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
  local tmp
  tmp="$(mktemp)"
  jq -s '.[0] * .[1]' "$dest" "$patch" >"$tmp"
  if cmp -s "$tmp" "$dest"; then
    rm -f "$tmp"
    log "shell.json already up to date"
    return 0
  fi
  backup_file "$dest"
  mv "$tmp" "$dest"
  log "merged idle/bar settings into $dest"
}
