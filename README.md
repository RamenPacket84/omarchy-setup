After a fresh [Omarchy](https://omarchy.org/) 4 install, clone this bootstrap into `~/Projects` (Omarchy's default projects directory) and run it:

```bash
git clone https://github.com/RamenPacket84/omarchy-setup.git ~/Projects/omarchy-setup && bash ~/Projects/omarchy-setup/setup.sh
```

`setup.sh` is safe to re-run:

```bash
~/Projects/omarchy-setup/setup.sh --with extras
~/Projects/omarchy-setup/setup.sh --dry-run
```

Logs: `~/.local/state/omarchy-setup/setup.log`. Replaced files are copied to `~/.local/state/omarchy-setup/backups/` (not next to the live file). Re-running setup overwrites the Hyprland snippets under `~/.config/hypr/` when they differ from this repo.

**Core run**

| Area | What it does |
|---|---|
| Browser | Installs Brave Origin (the only AUR package) and makes it default |
| Terminal | Installs Ghostty, makes it default, keeps the Omarchy theme include, sets opacity `0.60` |
| Editor | Installs Neovim as the default editor, and installs Cursor |
| Agent | Installs Grok with mise and sets it as the default agent without launching a session |
| Font | Sets JetBrainsMono Nerd Font |
| 1Password | Installs the app only; sign-in is manual |
| Theme | Sets the stock Everforest theme. Also clones [Terminal Outpost Labs](https://github.com/RamenPacket84/terminal-outpost-labs) without applying it |
| Fastfetch | Applies the Terminal Outpost Labs logo and layout |
| Gaps | `gaps_in = 3`, `gaps_out = 6` |
| Keys | Super+F file manager, Super+B default browser, Super+X X, Super+Y YouTube; Super+Enter is already the default terminal |
| Pointer | Laptop sensitivity `0`, external display `-0.8` (needs `socat`) |
| Web apps | Removes HEY, WhatsApp, Zoom, and Basecamp; names the Discord web app **Discord (Web)**. A `post-update` hook re-removes them after `omarchy update` recopies stock launchers |
| Plugins | Installs [Canon](https://github.com/RamenPacket84/canon), [DayNight](https://github.com/RamenPacket84/DayNight), and [EscaLock](https://github.com/RamenPacket84/omarchy-escalock) on the right of the bar. EscaLock may open a guided sudo/Polkit setup on first install |
| Idle | Lock and screensaver after 90 minutes |
| Clock | 12-hour clock on the right of the bar |
| Git | Includes `~/.config/git/omarchy-setup.gitconfig` (`co`/`br`/`ci`/`st`, `pull.rebase`, `init.defaultBranch=main`). Prompts for name/email, or uses `GIT_USER_NAME` / `GIT_USER_EMAIL` |
| Extra CLI | `htop`, `cursor-bin`, `github-cli`, `wget`, `rsync`, `jq`, `socat` |

**`--with extras`** also installs the native Discord client, Ollama, and [Retro 82](https://github.com/OldJobobo/omarchy-retro-82-theme).
