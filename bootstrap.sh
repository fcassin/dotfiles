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

# Logging and script structure inspired by https://blog.thibaut-rousseau.com/blog/shell-scripts-matter/
readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

backup() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        warning "Backing up: $target → $target.old"
        mv "$target" "$target.old"
    fi
}

readonly DOTFILES_REPO="https://github.com/fcassin/dotfiles.git"
readonly DOTFILES_DIR="$HOME/dotfiles"
readonly DESIRED_THEME="catppuccin"
readonly PERSONAL_REPO="git@github.com:fcassin/personal.git"
readonly PERSONAL_DIR="$HOME/personal"

# Stow packages to symlink into $HOME. Each name must match a directory in $DOTFILES_DIR.
readonly STOW_PACKAGES=(
    bash
    claude
    hypr
    nvim
    waybar
)

cleanup() {
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        info "Reloading hyprland..."
        hyprctl reload >/dev/null
        info "Restarting hypridle..."
        pkill hypridle 2>/dev/null || true
        hypridle >/dev/null 2>&1 &
        info "Restarting waybar..."
        pkill -9 -x waybar 2>/dev/null || true
        setsid uwsm-app -- waybar >/dev/null 2>&1 &
    fi
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
}

# ── prerequisites ─────────────────────────────────────────────────────────────
check_prerequisites() {
    if ! find ~/.ssh -maxdepth 1 -type f ! -name '*.pub' ! -name 'known_hosts' \
            ! -name 'config' ! -name 'authorized_keys' 2>/dev/null | grep -q .; then
        error "No SSH private key found in ~/.ssh/"
        error "  See README: Manual prerequisites → SSH keys"
        fatal "Prerequisites missing — fix the above and re-run. See README for instructions."
    fi
}

# ── pgp keys ──────────────────────────────────────────────────────────────────
# For each key: already in keyring → skip; .asc file in $HOME → import; neither → fail.
import_pgp_key() {
    local label="$1"
    local fingerprint="$2"
    local asc_path="$HOME/$3"

    if gpg --list-secret-keys "$fingerprint" &>/dev/null; then
        info "PGP key already present: $label"
        return 0
    fi
    if [[ -f "$asc_path" ]]; then
        info "Importing PGP key: $label"
        gpg --import "$asc_path"
        shred -u "$asc_path"
        return 0
    fi
    error "PGP key missing: $label"
    error "  Fingerprint : $fingerprint"
    error "  Expected at : $asc_path"
    error "  See README: Manual prerequisites → PGP keys"
    return 1
}

step_pgp_keys() {
    local missing=0
    import_pgp_key "personal" "F51B3A7E1E79875F1864571241A814B96CFD3884" "pgp-personal.asc" || missing=1
    import_pgp_key "gopass"   "E4812F1C637B277FA36763CB054A047E308D74B8" "pgp-gopass.asc"   || missing=1
    import_pgp_key "work"     "EBB96BF5073E54C97ED790B1427108BFAC790563" "pgp-work.asc"     || missing=1
    [[ $missing -eq 0 ]] || fatal "One or more PGP keys could not be resolved — see above."
}

# ── packages ─────────────────────────────────────────────────────────────────
step_packages() {
    local pkg
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if pacman -Q "$pkg" &>/dev/null; then
            info "Package already installed: $pkg"
        else
            info "Installing package: $pkg"
            sudo pacman -S --needed --noconfirm "$pkg"
        fi
    done < "$DOTFILES_DIR/packages.txt"
}

# ── stow ──────────────────────────────────────────────────────────────────────
step_stow() {
    local pkg src rel target
    for pkg in "${STOW_PACKAGES[@]}"; do
        info "Stowing: $pkg"
        # Before stowing, move any conflicting regular files to .old so nothing is lost.
        while IFS= read -r src; do
            rel="${src#"$DOTFILES_DIR/$pkg/"}"
            target="$HOME/$rel"
            backup "$target"
        done < <(find "$DOTFILES_DIR/$pkg" -type f)
        stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg"
    done
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
}

# ── discord ───────────────────────────────────────────────────────────────────
step_discord() {
    if [[ -x "/opt/Discord/discord" ]]; then
        info "Discord already installed"
        return
    fi
    "$DOTFILES_DIR/discord-update.sh"
}

# ── personal repo ─────────────────────────────────────────────────────────────
step_personal() {
    if [[ ! -d "$PERSONAL_DIR/.git" ]]; then
        info "Cloning personal repo to $PERSONAL_DIR..."
        git clone "$PERSONAL_REPO" "$PERSONAL_DIR"
    else
        info "Personal repo already cloned"
    fi

    local projects_dir="$HOME/.claude/projects"
    local projects_target="$PERSONAL_DIR/claude-memory"
    if [[ -L "$projects_dir" && "$(readlink "$projects_dir")" == "$projects_target" ]]; then
        info "Claude projects symlink already set"
    else
        info "Linking Claude projects..."
        backup "$projects_dir"
        mkdir -p "$(dirname "$projects_dir")"
        ln -sfn "$projects_target" "$projects_dir"
    fi
}

# ── neovim plugins ────────────────────────────────────────────────────────────
step_nvim_plugins() {
    info "Syncing Neovim plugins..."
    nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT
    bootstrap_repo
    step_packages
    step_pgp_keys
    check_prerequisites
    step_theme
    step_background
    step_stow
    step_personal
    step_discord
    step_nvim_plugins
fi
