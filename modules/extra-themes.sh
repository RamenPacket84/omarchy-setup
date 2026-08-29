# optional extra Omarchy themes from git (not vendored)

theme_name_from_url() {
  local url="$1"
  local path="$url"
  [[ $path != *"://"* && $path == *:*/* ]] && path="${path#*:}"
  basename -- "$path" .git | sed -E 's/^omarchy-//; s/-theme$//' | tr '[:upper:]' '[:lower:]'
}

install_extra_themes() {
  local url name dest
  while IFS= read -r url; do
    [[ -z $url || $url == \#* ]] && continue
    name="$(theme_name_from_url "$url")"
    dest="$HOME/.config/omarchy/themes/$name"
    if [[ -d $dest ]]; then
      log "theme already installed: $name"
      continue
    fi
    run omarchy theme install "$url"
  done <"$ROOT/manifests/themes-extra.txt"
}
