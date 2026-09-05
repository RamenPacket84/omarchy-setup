# Omarchy themes from git (not vendored). Clones into ~/.config/omarchy/themes
# without running `omarchy theme install`, which would also apply the theme.

theme_name_from_url() {
  local url="$1"
  local path="$url"
  [[ $path != *"://"* && $path == *:* && ${path%%:*} != */* ]] && path="${path#*:}"
  basename -- "$path" .git | sed -E 's/^omarchy-//; s/-theme$//' | tr '[:upper:]' '[:lower:]'
}

install_theme_from_url() {
  local url="$1"
  local name dest
  name="$(theme_name_from_url "$url")"
  dest="$HOME/.config/omarchy/themes/$name"
  if [[ -d $dest ]]; then
    log "theme already installed: $name"
    return 0
  fi
  if command -v omarchy-git-url-check >/dev/null 2>&1; then
    omarchy-git-url-check "$url" || die "refusing theme URL: $url"
  fi
  if (( DRY_RUN )); then
    log "DRY: git clone -- $url $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  run git clone -- "$url" "$dest"
}

install_themes_from_manifest() {
  local url
  while IFS= read -r url; do
    install_theme_from_url "$url"
  done < <(manifest_lines "$1")
}

install_extra_themes() {
  install_themes_from_manifest "$ROOT/manifests/themes-extra.txt"
}
