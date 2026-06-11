#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()  { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
error() { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal() { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

readonly INSTALL_DIR="/opt/Discord"
readonly VERSION_FILE="$INSTALL_DIR/.installed-version"
readonly ARCHIVE="/tmp/discord-latest.tar.gz"
readonly DESKTOP_FILE="$HOME/.local/share/applications/Discord.desktop"
readonly CDN_URL="https://discord.com/api/download/stable?platform=linux&format=tar.gz"

info "Checking latest Discord version..."
latest="$(curl -sI --fail "$CDN_URL" | grep -i '^location:' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
[[ -n "$latest" ]] || fatal "Could not determine latest Discord version from CDN"

installed="$(cat "$VERSION_FILE" 2>/dev/null || echo "")"
if [[ "$installed" == "$latest" ]]; then
    info "Discord already up to date ($latest)"
    exit 0
fi

info "Installing Discord $latest..."
curl -sL --fail "$CDN_URL" -o "$ARCHIVE"
sudo rm -rf "$INSTALL_DIR"
sudo tar -xzf "$ARCHIVE" -C /opt
rm -f "$ARCHIVE"
echo "$latest" | sudo tee "$VERSION_FILE" > /dev/null

info "Updating desktop entry..."
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=Discord
Comment=Discord
Exec=$INSTALL_DIR/discord
Terminal=false
Type=Application
Icon=$INSTALL_DIR/discord.png
StartupNotify=true
EOF
