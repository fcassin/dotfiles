#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/ Usage: bootstrap.sh
#/ Description: Bootstrap Omarchy dotfiles on a fresh Arch Linux install.
#/              Re-entrant — safe to run multiple times.
#/ Examples:
#/   bash <(curl -s https://raw.githubusercontent.com/fcassin/dotfiles/main/bootstrap.sh)
#/   ./bootstrap.sh
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

readonly DOTFILES_REPO="https://github.com/fcassin/dotfiles.git"
readonly DOTFILES_DIR="$HOME/dotfiles"
readonly DESIRED_THEME="catppuccin"

cleanup() {
    :
}

# ── self-bootstrap ────────────────────────────────────────────────────────────
# When run via curl, clone the repo and re-exec from within it.
bootstrap_repo() {
    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        info "Cloning dotfiles to $DOTFILES_DIR..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        exec "$DOTFILES_DIR/bootstrap.sh"
    fi
    cd "$DOTFILES_DIR"
    info "Dotfiles repo ready at $DOTFILES_DIR"
}

# ── prerequisites ─────────────────────────────────────────────────────────────
check_prerequisites() {
    local missing=0

    if ! find ~/.ssh -maxdepth 1 -type f ! -name '*.pub' ! -name 'known_hosts' \
            ! -name 'config' ! -name 'authorized_keys' 2>/dev/null | grep -q .; then
        error "No SSH private key found in ~/.ssh/"
        error "  See README: Manual prerequisites → SSH keys"
        missing=1
    else
        info "SSH keys present"
    fi

    if ! gpg --list-secret-keys 2>/dev/null | grep -q 'sec'; then
        error "No PGP secret keys found in GPG keyring"
        error "  See README: Manual prerequisites → PGP keys"
        missing=1
    else
        info "PGP keys present"
    fi

    if [[ $missing -ne 0 ]]; then
        fatal "Prerequisites missing — fix the above and re-run. See README for instructions."
    fi
}

# ── theme ─────────────────────────────────────────────────────────────────────
step_theme() {
    local current
    current="$(cat ~/.config/omarchy/current/theme.name 2>/dev/null || echo "")"
    if [[ "$current" == "$DESIRED_THEME" ]]; then
        info "Theme already set to $DESIRED_THEME"
        return
    fi
    info "Setting theme: $DESIRED_THEME"
    omarchy-theme-set "$DESIRED_THEME"
    info "Theme set to $DESIRED_THEME"
}

# ── background ────────────────────────────────────────────────────────────────
step_background() {
    local desired_bg current_bg
    desired_bg="$(realpath "$DOTFILES_DIR/backgrounds/nice-blue-background.png")"
    current_bg="$(readlink -f ~/.config/omarchy/current/background 2>/dev/null || echo "")"
    if [[ "$current_bg" == "$desired_bg" ]]; then
        info "Background already set"
        return
    fi
    info "Setting background..."
    omarchy-theme-bg-set "$desired_bg"
    info "Background set to $desired_bg"
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT
    bootstrap_repo
    check_prerequisites
    step_theme
    step_background
fi
