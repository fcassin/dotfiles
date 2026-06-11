#!/usr/bin/env bash
set -euo pipefail

# ── self-bootstrap ────────────────────────────────────────────────────────────
# When run via curl, clone the repo and re-exec from within it.
# When run from the cloned repo, proceed normally.
DOTFILES_REPO="https://github.com/fcassin/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
    echo "▶ Cloning dotfiles..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    exec "$DOTFILES_DIR/bootstrap.sh"
fi

cd "$DOTFILES_DIR"

# ── helpers ───────────────────────────────────────────────────────────────────
log()  { printf '\e[1;34m▶\e[0m %s\n' "$*"; }
ok()   { printf '\e[1;32m✓\e[0m %s\n' "$*"; }
skip() { printf '\e[2m  %s (already done)\e[0m\n' "$*"; }
fail() { printf '\e[1;31m✗\e[0m %s\n' "$*" >&2; }

# ── prerequisites ─────────────────────────────────────────────────────────────
check_prerequisites() {
    local missing=0

    # SSH: need at least one private key (no .pub extension)
    if ! find ~/.ssh -maxdepth 1 -type f ! -name '*.pub' ! -name 'known_hosts' ! -name 'config' ! -name 'authorized_keys' 2>/dev/null | grep -q .; then
        fail "No SSH private key found in ~/.ssh/"
        fail "  See README: Manual prerequisites → SSH keys"
        missing=1
    else
        ok "SSH keys present"
    fi

    # PGP: need at least one secret key in the keyring
    if ! gpg --list-secret-keys 2>/dev/null | grep -q 'sec'; then
        fail "No PGP secret keys found in GPG keyring"
        fail "  See README: Manual prerequisites → PGP keys"
        missing=1
    else
        ok "PGP keys present"
    fi

    if [[ $missing -ne 0 ]]; then
        echo ""
        echo "Fix the above and re-run bootstrap.sh. See README for instructions."
        exit 1
    fi
}

# ── theme ─────────────────────────────────────────────────────────────────────
DESIRED_THEME="catppuccin"

step_theme() {
    local current
    current="$(cat ~/.config/omarchy/current/theme.name 2>/dev/null || echo "")"
    if [[ "$current" == "$DESIRED_THEME" ]]; then
        skip "theme: $DESIRED_THEME"
        return
    fi
    log "Setting theme: $DESIRED_THEME"
    omarchy-theme-set "$DESIRED_THEME"
    ok "theme: $DESIRED_THEME"
}

# ── background ────────────────────────────────────────────────────────────────
DESIRED_BG="$(realpath "$DOTFILES_DIR/backgrounds/nice-blue-background.png")"

step_background() {
    local current
    current="$(readlink -f ~/.config/omarchy/current/background 2>/dev/null || echo "")"
    if [[ "$current" == "$DESIRED_BG" ]]; then
        skip "background"
        return
    fi
    log "Setting background..."
    omarchy-theme-bg-set "$DESIRED_BG"
    ok "background: $DESIRED_BG"
}

# ── run ───────────────────────────────────────────────────────────────────────
check_prerequisites
step_theme
step_background
