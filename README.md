# bd-install-script

A minimal Bash script for managing [BetterDiscord](https://betterdiscord.app) on Linux without the official GUI installer. 
Designed for distributions where Discord installs into `~/.config/discord/` rather than the system-wide paths the GUI installer expects (e.g. Devuan, Debian, and derivatives using the `.deb` package).

Uses [betterdiscordctl](https://github.com/bb010g/betterdiscordctl) as its backend; the latest version is fetched automatically at runtime so no manual dependency management is needed.

---

## Requirements

- A Debian-based Linux distribution (tested on Devuan 6 Excalibur)
- Discord installed via the official `.deb` package and launched at least once
- `curl` and `find` (present by default on most systems)

---

## Installation

**1. Place the script**

```bash
mkdir -p ~/.local/bin
cp bd.sh ~/.local/bin/bd.sh
chmod +x ~/.local/bin/bd.sh
```

**2. Create the symlink**

```bash
ln -s ~/.local/bin/bd.sh ~/.local/bin/bd
```

**3. Ensure `~/.local/bin` is on your PATH**

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Usage

```
bd install      Fresh install of BetterDiscord
bd repair       Reinstall BetterDiscord (use this after Discord updates break it)
bd uninstall    Remove BetterDiscord from Discord
bd --help       Show usage
```

After any operation, **fully quit Discord from the system tray** (right-click the tray icon → Quit) and relaunch it. A normal window close is not enough; the Electron process must restart for the injection to take effect.

---

## How it works

1. Scans `~/.config/discord/app-x.x.x/modules` at runtime to locate the active Discord installation; no hardcoded paths.
2. Downloads the latest `betterdiscordctl` into a temporary directory.
3. Passes the detected modules path directly to `betterdiscordctl` via `--d-modules`, bypassing GUI-based detection entirely.
4. Cleans up all temporary files on exit, whether the operation succeeded or not.

---

## Why not the official AppImage installer?

The official BetterDiscord GUI installer scans a fixed list of system-wide paths (`/opt/discord`, `/usr/share/discord`, etc.). When Discord is installed via `.deb` on Devuan/Debian, the actual application unpacks into the user's home directory at `~/.config/discord/app-x.x.x/`; the GUI never finds it, and the Browse workaround is unreliable across versions. This script sidesteps the GUI entirely.

---

## After a Discord update

Discord updates overwrite the injection. Run `bd repair` to restore BetterDiscord:

```bash
bd repair
```

---

## License

Do whatever you want with this. No warranty.
