```bash
git clone https://github.com/RamenPacket84/omarchy-setup.git ~/Development/omarchy-setup && ~/Development/omarchy-setup/setup.sh
```

```bash
~/Development/omarchy-setup/setup.sh --with extras
~/Development/omarchy-setup/setup.sh --dry-run
```

After a fresh Omarchy 4 install, `setup.sh` is safe to re-run. Logs: `~/.local/state/omarchy-setup/setup.log`.

**Core run**

| Area | What it does |
|---|---|
| Browser | Installs Brave Origin (the only AUR package) and makes it default |
| Terminal | Installs Ghostty, makes it default, keeps the Omarchy theme include, sets opacity `0.60` |
| Editor | Installs Neovim and makes it the default editor |
| Agent | Installs Grok with mise and sets it as the default agent without launching a session |
| Font | Sets JetBrainsMono Nerd Font |
| 1Password | Installs the app only; sign-in is manual |
| Theme | Installs and applies [Last Call](https://github.com/OldJobobo/omarchy-last-call-theme) |
| Gaps | `gaps_in = 3`, `gaps_out = 6` |
| Pointer | Laptop sensitivity `0`, external display `-0.8` |
| Web apps | Removes HEY, WhatsApp, and Zoom; names the Discord web app **Discord (Web)** |
| Plugins | Installs [Canon](https://github.com/RamenPacket84/canon), [DayNight](https://github.com/RamenPacket84/DayNight), and [EscaLock](https://github.com/RamenPacket84/omarchy-escalock) on the right of the bar. EscaLock may open a guided sudo/Polkit setup on first install |
| Idle | Lock and screensaver after 90 minutes |
| Clock | 12-hour clock on the right of the bar |
| Git | Sets aliases `co`/`br`/`ci`/`st`, `pull.rebase`, and `init.defaultBranch=main`. Prompts for name/email, or uses `GIT_USER_NAME` / `GIT_USER_EMAIL` |
| Extra CLI | `htop`, `neovim`, `github-cli`, `wget`, `rsync`, `jq` |

**`--with extras`** also installs the native Discord client, Ollama, and [Retro 82](https://github.com/OldJobobo/omarchy-retro-82-theme).
