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

These are needed for gopass (password store encryption/decryption).

**Export from source machine:**
```bash
gpg --list-secret-keys --keyid-format LONG  # note your KEY_ID
gpg --export-secret-keys --armor KEY_ID > pgp-private.asc
# Transfer pgp-private.asc securely to the target machine
```

**Install on target machine:**
```bash
gpg --import pgp-private.asc
gpg --edit-key KEY_ID
# At the gpg> prompt: trust → 5 (ultimate) → y → quit
rm pgp-private.asc  # don't leave the private key lying around
```

## What the bootstrap does

- Checks SSH and PGP keys are present (fails with instructions if not)
- Sets the Catppuccin theme via `omarchy-theme-set`
- Sets the desktop background
