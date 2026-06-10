#!/usr/bin/env bash
# bd — BetterDiscord manager (betterdiscordctl backend)
# Usage: bd install | bd repair | bd uninstall

set -euo pipefail

# ── colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[bd]${RESET} $*"; }
success() { echo -e "${GREEN}[bd]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[bd]${RESET} $*"; }
die()     { echo -e "${RED}[bd] ERROR:${RESET} $*" >&2; exit 1; }

# ── usage ─────────────────────────────────────────────────────────────────────
usage() {
    echo -e "
${BOLD}bd${RESET} — BetterDiscord manager

${BOLD}Usage:${RESET}
  bd install    Fresh install of BetterDiscord
  bd repair     Reinstall BetterDiscord (fixes broken installs after Discord updates)
  bd uninstall  Remove BetterDiscord from Discord

"
    exit 0
}

# ── argument parsing ──────────────────────────────────────────────────────────
CMD="${1:-}"
case "$CMD" in
    install|repair|uninstall) ;;
    -h|--help) usage ;;
    "")  echo -e "${RED}[bd] No command specified.${RESET}"; usage ;;
    *)   echo -e "${RED}[bd] Unknown command: '${CMD}'${RESET}"; usage ;;
esac

# ── dependency check ──────────────────────────────────────────────────────────
for cmd in curl find; do
    command -v "$cmd" &>/dev/null || die \
        "'$cmd' is not installed. Install it with: sudo apt-get install $cmd"
done

# ── locate Discord modules directory ─────────────────────────────────────────
info "Locating Discord installation…"

MODULES_DIR=$(find "${XDG_CONFIG_HOME:-$HOME/.config}/discord" \
    -maxdepth 2 -type d -name "modules" 2>/dev/null | sort -V | tail -n1)

if [[ -z "$MODULES_DIR" ]]; then
    die "Could not find a Discord modules directory under ~/.config/discord.\n" \
        "       Make sure Discord has been launched at least once."
fi

APP_VER=$(basename "$(dirname "$MODULES_DIR")")
info "Found Discord install : ${BOLD}${APP_VER}${RESET}"
info "Modules directory     : ${BOLD}${MODULES_DIR}${RESET}"
echo

# ── download latest betterdiscordctl ─────────────────────────────────────────
BDCTL_URL="https://github.com/bb010g/betterdiscordctl/raw/master/betterdiscordctl"
TMPDIR_BD=$(mktemp -d /tmp/bd.XXXXXX)
BDCTL="${TMPDIR_BD}/betterdiscordctl"

cleanup() { rm -rf "$TMPDIR_BD"; }
trap cleanup EXIT

info "Downloading betterdiscordctl…"
curl -fsSL --progress-bar -o "$BDCTL" "$BDCTL_URL" || \
    die "Failed to download betterdiscordctl. Check your internet connection."
chmod +x "$BDCTL"
success "betterdiscordctl ready."
echo

# ── dispatch ──────────────────────────────────────────────────────────────────
case "$CMD" in
    install)
        info "Installing BetterDiscord…"
        echo
        "$BDCTL" --d-modules "$MODULES_DIR" install
        echo
        success "BetterDiscord installed."
        info "Fully quit Discord (system tray → Quit) and relaunch to apply."
        ;;
    repair)
        info "Reinstalling BetterDiscord…"
        echo
        "$BDCTL" --d-modules "$MODULES_DIR" reinstall
        echo
        success "BetterDiscord reinstalled."
        info "Fully quit Discord (system tray → Quit) and relaunch to apply."
        ;;
    uninstall)
        info "Uninstalling BetterDiscord…"
        echo
        "$BDCTL" --d-modules "$MODULES_DIR" uninstall
        echo
        success "BetterDiscord uninstalled."
        info "Fully quit Discord (system tray → Quit) and relaunch to apply."
        ;;
esac

echo

# ── done ──────────────────────────────────────────────────────────────────────
read -rsp $'Press any key to close this terminal…\n' -n1
