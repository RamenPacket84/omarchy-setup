#!/usr/bin/env bash
# Omarchy 4 personal bootstrap. Safe to re-run. No secrets.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
DRY_RUN=0
WITH_EXTRAS=0

# shellcheck source=lib/log.sh
source "$ROOT/lib/log.sh"
# shellcheck source=lib/omarchy.sh
source "$ROOT/lib/omarchy.sh"
# shellcheck source=lib/files.sh
source "$ROOT/lib/files.sh"
# shellcheck source=modules/discord-native.sh
source "$ROOT/modules/discord-native.sh"
# shellcheck source=modules/ollama.sh
source "$ROOT/modules/ollama.sh"
# shellcheck source=modules/extra-themes.sh
source "$ROOT/modules/extra-themes.sh"

usage() {
  cat <<'EOF'
Usage: ./setup.sh [--dry-run] [--with extras]

Replay a personal Omarchy 4 setup after a fresh install.

  --dry-run       Print actions without changing the system
  --with extras   Also install native Discord, Ollama, and Retro 82

Environment:
  GIT_USER_NAME   Git user.name if git identity is unset
  GIT_USER_EMAIL  Git user.email if git identity is unset
EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --with)
      shift
      [[ ${1:-} == extras ]] || die "unknown --with target: ${1:-}"
      WITH_EXTRAS=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
    esac
    shift
  done
}

phase_preflight() {
  log "== preflight"
  (( EUID != 0 )) || die "run as your desktop user, not root"
  require_omarchy
  mkdir -p "$HOME/.local/state/omarchy-setup"
  SETUP_LOG="$HOME/.local/state/omarchy-setup/setup.log"
  log "log file: $SETUP_LOG"
  log "omarchy $(omarchy version)  dry-run=$DRY_RUN  extras=$WITH_EXTRAS"
}

phase_defaults() {
  log "== defaults"

  if pkg_present brave-origin-bin; then
    log "Brave Origin already installed"
  else
    log "installing Brave Origin (only AUR package this setup uses)"
    run omarchy install browser brave-origin
  fi
  if [[ $(omarchy default browser 2>/dev/null || true) == brave-origin ]]; then
    log "default browser already brave-origin"
  else
    run omarchy default browser brave-origin
  fi

  if pkg_present ghostty; then
    log "ghostty already installed"
    if [[ $(omarchy default terminal 2>/dev/null || true) != ghostty ]]; then
      run omarchy default terminal ghostty
    fi
  else
    run omarchy install terminal ghostty
  fi

  pkg_add neovim
  if [[ $(omarchy default editor 2>/dev/null || true) != nvim ]]; then
    run omarchy default editor nvim
  else
    log "default editor already nvim"
  fi

  local font
  font="$(omarchy font current 2>/dev/null || true)"
  if [[ $font == *"JetBrainsMono Nerd Font"* ]]; then
    log "font already JetBrainsMono Nerd Font"
  else
    run omarchy font set "JetBrainsMono Nerd Font"
  fi

  if pkg_present 1password; then
    log "1Password already installed"
  else
    run omarchy install service 1password
  fi
}

phase_webapps() {
  log "== web apps"
  local name desktop
  while IFS= read -r name; do
    [[ -z $name || $name == \#* ]] && continue
    desktop="$HOME/.local/share/applications/${name}.desktop"
    if [[ -f $desktop ]]; then
      OMARCHY_REMOVE_NOTIFY=false run omarchy-webapp-remove "$name"
    else
      log "web app already absent: $name"
    fi
  done <"$ROOT/manifests/webapps-remove.txt"

  local file display
  while IFS='|' read -r file display; do
    [[ -z $file || $file == \#* ]] && continue
    desktop="$HOME/.local/share/applications/${file}.desktop"
    if [[ ! -f $desktop ]]; then
      log "launcher missing, skip rename: $file"
      continue
    fi
    if grep -q "^Name=${display}$" "$desktop"; then
      log "already named ${display}: $file"
      continue
    fi
    backup_file "$desktop"
    if (( DRY_RUN )); then
      log "DRY: Name=$display in $desktop"
      continue
    fi
    sed -i "s/^Name=.*/Name=${display}/" "$desktop"
    if ! grep -q '^Comment=' "$desktop"; then
      sed -i "/^Name=/a Comment=Discord in the browser" "$desktop"
    fi
    log "renamed $file -> $display"
  done <"$ROOT/manifests/webapps-rename.txt"
  if (( ! DRY_RUN )); then
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
    omarchy menu refresh >/dev/null 2>&1 || true
  fi
}

phase_packages() {
  log "== packages"
  local pkgs=()
  local line
  while IFS= read -r line; do
    [[ -z $line || $line == \#* ]] && continue
    pkgs+=("$line")
  done <"$ROOT/manifests/packages.txt"
  pkg_add "${pkgs[@]}"
}

phase_mise() {
  log "== mise"
  command -v mise >/dev/null 2>&1 || {
    warn "mise not found; skipping tool installs"
    return 0
  }
  install_if_missing "$ROOT/snippets/mise/config.toml" "$HOME/.config/mise/config.toml"
  if (( DRY_RUN )); then
    log "DRY: mise install"
    return 0
  fi
  # Do not overwrite an existing user mise config; still ensure tools.
  local tool
  for tool in python gh opencode codex "npm:@xai-official/grok"; do
    if mise where "$tool" >/dev/null 2>&1; then
      log "mise tool present: $tool"
    else
      run mise use -g "${tool}@latest"
    fi
  done

  mkdir -p "$HOME/.config/omarchy/defaults"
  if [[ $(cat "$HOME/.config/omarchy/defaults/agent" 2>/dev/null || true) == grok ]]; then
    log "default agent already grok"
  else
    if (( DRY_RUN )); then
      log "DRY: write default agent grok"
    else
      printf 'grok\n' >"$HOME/.config/omarchy/defaults/agent"
      log "set default agent to grok (without launching it)"
    fi
  fi
}

phase_hyprland() {
  log "== hyprland"
  install_file "$ROOT/snippets/hypr/looknfeel.lua" "$HOME/.config/hypr/looknfeel.lua"
  install_file "$ROOT/snippets/hypr/input.lua" "$HOME/.config/hypr/input.lua"
  install_file "$ROOT/snippets/hypr/bindings.lua" "$HOME/.config/hypr/bindings.lua"
  install_file "$ROOT/snippets/hypr/autostart.lua" "$HOME/.config/hypr/autostart.lua"
  install_file "$ROOT/snippets/hypr/scripts/pointer-sensitivity-by-monitor.sh" \
    "$HOME/.config/hypr/scripts/pointer-sensitivity-by-monitor.sh" 0755
  if (( DRY_RUN )); then
    log "DRY: hyprctl reload"
    return 0
  fi
  hyprctl reload
  local errors
  errors="$(hyprctl configerrors || true)"
  if [[ -n $errors && $errors != ok ]]; then
    warn "hyprctl configerrors: $errors"
  else
    log "hyprland configerrors: ok"
  fi
}

phase_ghostty() {
  log "== ghostty"
  local dest="$HOME/.config/ghostty/config"
  local stock="$OMARCHY_PATH/config/ghostty/config"
  if [[ ! -f $dest && -f $stock ]]; then
    install_file "$stock" "$dest"
  elif [[ -f $dest && -f $stock ]] && ! grep -Fq 'config-file = ?"~/.local/state/omarchy/current/theme/ghostty.conf"' "$dest"; then
    warn "Ghostty config is missing Omarchy theme include; restoring stock defaults then applying overrides"
    install_file "$stock" "$dest"
  fi
  ensure_managed_block "$dest" "# managed-by: omarchy-setup" "$(cat "$ROOT/snippets/ghostty/overrides.conf" | grep -v '^# managed-by')"
}

phase_theme() {
  log "== theme"
  local url dest
  url="$(grep -v '^#' "$ROOT/manifests/themes.txt" | grep -v '^$' | head -1)"
  dest="$HOME/.config/omarchy/themes/last-call"
  if [[ -d $dest ]]; then
    log "theme already installed: last-call"
  else
    run omarchy theme install "$url"
  fi
  if [[ $(omarchy theme current 2>/dev/null || true) == "Last Call" ]]; then
    log "theme already Last Call"
  else
    run omarchy theme set last-call
  fi
}

phase_plugins() {
  log "== plugins"
  local url id dest
  while IFS='|' read -r url id; do
    [[ -z $url || $url == \#* ]] && continue
    dest="$HOME/.config/omarchy/plugins/$id"
    if [[ -d $dest ]]; then
      log "plugin already installed: $id"
    else
      run omarchy plugin add "$url" --enable --yes
    fi
    run omarchy bar move "$id" --section right
  done <"$ROOT/manifests/plugins.txt"

  run omarchy bar move omarchy.clock --section right
  run omarchy bar set omarchy.clock format "dddd h:mm AP"
  run omarchy bar set andrewbacon.daynight darkTheme Gruvbox
  run omarchy bar set andrewbacon.daynight lightTheme White
  run omarchy bar set andrewbacon.daynight darkWallpaper /usr/share/omarchy/themes/gruvbox/backgrounds/3-village-square.jpg
  run omarchy bar set andrewbacon.daynight lightWallpaper /usr/share/omarchy/themes/white/backgrounds/omarchy.png
  merge_shell_json "$ROOT/snippets/omarchy/shell-merge.json"
}

phase_git() {
  log "== git"
  if (( DRY_RUN )); then
    log "DRY: git config aliases and identity"
    return 0
  fi
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.st status
  git config --global pull.rebase true
  git config --global init.defaultBranch main
  log "git aliases and pull.rebase applied"

  local name email
  name="$(git config --global user.name || true)"
  email="$(git config --global user.email || true)"
  if [[ -n $name && -n $email ]]; then
    log "git identity already set"
    return 0
  fi
  if [[ -n ${GIT_USER_NAME:-} && -n ${GIT_USER_EMAIL:-} ]]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    log "git identity set from environment"
    return 0
  fi
  if [[ -t 0 ]]; then
    [[ -n $name ]] || read -r -p "Git user.name: " name
    [[ -n $email ]] || read -r -p "Git user.email: " email
    [[ -n $name ]] && git config --global user.name "$name"
    [[ -n $email ]] && git config --global user.email "$email"
    log "git identity set interactively"
  else
    warn "git identity unset; export GIT_USER_NAME and GIT_USER_EMAIL or run from a terminal"
  fi
}

phase_extras() {
  (( WITH_EXTRAS )) || return 0
  log "== extras"
  install_discord_native
  install_ollama
  install_extra_themes
}

phase_verify() {
  log "== verify"
  local fail=0
  check() {
    local label="$1"
    local got="$2"
    local want="$3"
    if [[ $got == *"$want"* ]]; then
      log "ok  $label ($got)"
    else
      warn "fail $label: got '$got' want '$want'"
      fail=1
    fi
  }

  if (( DRY_RUN )); then
    log "skip live verify in --dry-run"
    return 0
  fi

  check browser "$(omarchy default browser 2>/dev/null || true)" brave-origin
  check terminal "$(omarchy default terminal 2>/dev/null || true)" ghostty
  check editor "$(omarchy default editor 2>/dev/null || true)" nvim
  check agent "$(cat "$HOME/.config/omarchy/defaults/agent" 2>/dev/null || true)" grok
  check theme "$(omarchy theme current 2>/dev/null || true)" "Last Call"
  check gaps_in "$(hyprctl getoption general:gaps_in 2>/dev/null | head -1 || true)" "3 3 3 3"
  check gaps_out "$(hyprctl getoption general:gaps_out 2>/dev/null | head -1 || true)" "6 6 6 6"
  [[ ! -f $HOME/.local/share/applications/HEY.desktop ]] || {
    warn "fail HEY.desktop still present"
    fail=1
  }
  [[ ! -f $HOME/.local/share/applications/WhatsApp.desktop ]] || {
    warn "fail WhatsApp.desktop still present"
    fail=1
  }
  [[ ! -f $HOME/.local/share/applications/Zoom.desktop ]] || {
    warn "fail Zoom.desktop still present"
    fail=1
  }
  if [[ -f $HOME/.local/share/applications/Discord.desktop ]]; then
    check discord-web-name "$(grep '^Name=' "$HOME/.local/share/applications/Discord.desktop")" "Discord (Web)"
  fi
  [[ -d $HOME/.config/omarchy/plugins/andrewbacon.canon ]] || {
    warn "fail plugin canon missing"
    fail=1
  }
  [[ -d $HOME/.config/omarchy/plugins/andrewbacon.daynight ]] || {
    warn "fail plugin daynight missing"
    fail=1
  }
  [[ -d $HOME/.config/omarchy/plugins/andrewbacon.escalock ]] || {
    warn "fail plugin escalock missing"
    fail=1
  }

  if (( fail )); then
    warn "setup finished with verification warnings"
    return 1
  fi
  log "verification passed"
}

main() {
  parse_args "$@"
  phase_preflight
  phase_defaults
  phase_webapps
  phase_packages
  phase_mise
  phase_hyprland
  phase_ghostty
  phase_theme
  phase_plugins
  phase_git
  phase_extras
  if ! phase_verify; then
    warn "verification reported issues (see log)"
  fi
  log "done"
}

main "$@"
