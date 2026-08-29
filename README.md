# omarchy-setup

Personal [Omarchy](https://omarchy.org/) 4 (Quattro) bootstrap. Run it **after** a fresh Omarchy install. It does not install Omarchy itself and does not copy secrets.

Replace `GITHUB_USER` with your GitHub username after you publish this repo, then copy:

```bash
git clone https://github.com/GITHUB_USER/omarchy-setup.git ~/Development/omarchy-setup && ~/Development/omarchy-setup/setup.sh
```

With extras (Steam, native Discord, Ollama, extra themes):

```bash
git clone https://github.com/GITHUB_USER/omarchy-setup.git ~/Development/omarchy-setup && ~/Development/omarchy-setup/setup.sh --with extras
```

Preview without changing anything:

```bash
~/Development/omarchy-setup/setup.sh --dry-run
```

Safe to re-run. Logs go to `~/.local/state/omarchy-setup/setup.log`.

## What it sets up

| Area | Result |
|---|---|
| Browser | Brave Origin (default). This is the **only AUR** package. |
| Terminal | Ghostty (default), Omarchy theme include plus opacity `0.60` |
| Editor | VS Code (default) |
| Agent | Grok, via mise, without launching a session |
| Font | JetBrainsMono Nerd Font |
| Password manager | 1Password app only (sign-in is manual) |
| Theme | [Last Call](https://github.com/OldJobobo/omarchy-last-call-theme) |
| Gaps | `gaps_in = 3`, `gaps_out = 6` |
| Pointer | Laptop sensitivity `0`, external display `-0.8` |
| Web apps | Removes HEY, WhatsApp, Zoom; names the Discord web app **Discord (Web)** |
| Plugins | [Canon](https://github.com/RamenPacket84/canon), [DayNight](https://github.com/RamenPacket84/DayNight), [EscaLock](https://github.com/RamenPacket84/omarchy-escalock) |
| Idle | Lock and screensaver at 90 minutes |
| Clock | 12-hour on the right of the bar |
| Git | aliases `co`/`br`/`ci`/`st`, `pull.rebase`, `init.defaultBranch=main` |

`--with extras` also installs Steam, the native Discord client, Ollama (no models), and extra themes (Ash, Blackgold, Blackturq, Florida Man, Neo Sploosh, Retro 82).

## What it does not do

- No Thunderbird, Minecraft, Windows VM, fingerprint, or shader pack
- No AUR except Brave Origin (`omarchy install browser brave-origin`)
- No SSH keys, API tokens, browser profiles, 1Password account data, or git email in the repo
- Does not apply monitor scale (this laptop uses `1.25`; set that in `~/.config/hypr/monitors.lua` if you want it)
- Does not download Ollama models
- `omarchy refresh applications` recopies stock launchers and will reset the Discord web app name to **Discord**; re-run `./setup.sh` to restore **Discord (Web)**

Git identity is prompted at runtime, or set `GIT_USER_NAME` and `GIT_USER_EMAIL`. Those values are never committed.

## EscaLock

EscaLock changes sudo and Polkit. On a first install it opens a guided setup that asks you to type `install` and authenticate. Read [its README](https://github.com/RamenPacket84/omarchy-escalock) before enabling Secure Mode.

## Requirements

- Omarchy 4.x already installed
- Network
- Run as your desktop user (not root)
- Sudo for package installs

## Publish

This tree is a local git repo. Create an empty GitHub repository and push it yourself:

```bash
cd ~/Development/omarchy-setup
git remote add origin git@github.com:GITHUB_USER/omarchy-setup.git
git push -u origin main
```

Then replace `GITHUB_USER` in the copy-paste command at the top of this README.
