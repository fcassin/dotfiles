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

| File | Purpose |
|------|---------|
| `~/pgp-personal.asc` | Personal key |
| `~/pgp-gopass.asc` | gopass store encryption |
| `~/pgp-work.asc` | Work git commit signing |

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
- Sets the Catppuccin theme via `omarchy-theme-set`
- Sets the desktop background
- Stows all packages (`bash`, `hypr`, `nvim`, `waybar`) into `$HOME`

## Post-bootstrap steps

### SSH agent

The `.bashrc` starts `ssh-agent` automatically on first terminal open and adds `~/.ssh/id_ed25519`. This is required for Docker Compose SSH forwarding and gopass team stores.

### gopass team store

```bash
gopass clone git@github.com:PlakarKorp/team-secrets.git team-secrets
```

## Stow packages

| Package | What it manages |
|---------|----------------|
| `bash` | `~/.bashrc` — nvm, pnpm, ssh-agent |
| `hypr` | Hyprland WM config |
| `nvim` | Neovim / LazyVim config |
| `waybar` | Status bar config |
