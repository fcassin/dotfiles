# Dotfiles

Personal configuration for [Omarchy](https://omarchy.org) on Arch Linux.

## Fresh install

```bash
bash <(curl -s https://raw.githubusercontent.com/fcassin/dotfiles/main/bootstrap.sh)
```

The script is re-entrant — safe to run multiple times. If the repo isn't cloned yet it will clone it to `~/dotfiles` and proceed from there.

## Manual prerequisites

Copy your PGP keys onto the new machine before running the bootstrap. Everything else is automated.

## What it does

- Sets the Catppuccin theme via `omarchy-theme-set`
- Sets the desktop background
