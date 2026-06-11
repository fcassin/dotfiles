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
step_theme
step_background
