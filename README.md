# Dotfiles

Personal configuration for [Omarchy](https://omarchy.org) on Arch Linux.

## Fresh install

```bash
bash <(curl -s https://raw.githubusercontent.com/fcassin/dotfiles/main/bootstrap.sh)
```

The script is re-entrant — safe to run multiple times. If the repo isn't cloned yet it will clone it to `~/dotfiles` and proceed from there.

## Manual prerequisites

The bootstrap requires SSH and PGP keys to be present before it runs. It will check and fail with clear messages if either is missing.

### SSH keys

Generate a fresh key on the new machine — don't copy keys between machines. Each machine should have its own identity so a compromised machine only requires revoking one key.

```bash
ssh-keygen -t ed25519 -C "your-machine-name"
cat ~/.ssh/id_ed25519.pub  # copy this output
```

Then register the public key with each service that needs it:
- GitHub → Settings → SSH and GPG keys → New SSH key
- Any other services (servers, etc.)

### PGP keys

The bootstrap will import PGP keys automatically if it finds the following files in `$HOME`:

| File                  | Purpose                |
|-----------------------|------------------------|
| `~/pgp-personal.asc`  | Personal key           |
| `~/pgp-gopass.asc`    | gopass store encryption|
| `~/pgp-work.asc`      | Work git commit signing|

If a key is already in the GPG keyring the file is not needed. If a key is absent from both the keyring and `$HOME`, the bootstrap fails with a clear message. The `.asc` files are securely deleted with `shred` immediately after import.

**Export from source machine:**
```bash
gpg --list-secret-keys --keyid-format LONG  # note each KEY_ID
gpg --export-secret-keys --armor KEY_ID > ~/pgp-personal.asc
gpg --export-secret-keys --armor KEY_ID > ~/pgp-gopass.asc
gpg --export-secret-keys --armor KEY_ID > ~/pgp-work.asc
# Transfer the .asc files securely to $HOME on the target machine
```

## What the bootstrap does

- Checks SSH and PGP keys are present (fails with instructions if not)
- Sets the Catppuccin theme via `omarchy theme set`
- Sets the desktop background
- Stows all packages into their respective target directories
- Clones `~/personal` and symlinks `~/.claude/projects/` into it

## Post-bootstrap steps

### SSH agent

The `.bashrc` starts `ssh-agent` automatically on first terminal open and adds `~/.ssh/id_ed25519`. This is required for Docker Compose SSH forwarding and gopass team stores.

### gopass team store

```bash
gopass clone git@github.com:PlakarKorp/team-secrets.git team-secrets
```

## Stow packages

Each package is stowed directly into its target — no nested `.config/` paths in the repo.

| Package      | Target                  | What it manages                        |
|--------------|-------------------------|----------------------------------------|
| `bash`       | `~/`                    | `.bashrc` — nvm, pnpm, ssh-agent       |
| `claude`     | `~/.claude/`            | `settings.json` — theme, hooks         |
| `git`        | `~/.config/git/`        | git config, GPG commit signing         |
| `hypr`       | `~/.config/hypr/`       | Hyprland WM config (Lua)               |
| `lazydocker` | `~/.config/lazydocker/` | lazydocker config                      |
| `nvim`       | `~/.config/nvim/`       | Neovim / LazyVim config                |
| `omarchy`    | `~/.config/omarchy/`    | `shell.json` — bar, idle/lock          |

## Omarchy Quattro migration

Omarchy 4 replaced Waybar and hypridle with the Quickshell-based Omarchy shell,
and moved Hyprland config from `.conf` to `.lua`. The pre-Quattro files are kept
unstowed under [`legacy/`](legacy/) alongside a
[migration checklist](legacy/MIGRATION.md) tracking what is ported and what is
still outstanding.
