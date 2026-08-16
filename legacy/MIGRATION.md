# Omarchy Quattro (4.x) migration

Omarchy 4 replaced two things this repo used to configure:

| Pre-Quattro | Quattro | Status |
| --- | --- | --- |
| Waybar (`waybar/config.jsonc`, `waybar/style.css`) | Omarchy shell, a Quickshell process configured by `~/.config/omarchy/shell.json` | ported → `omarchy/shell.json` |
| hypridle (`hypr/hypridle.conf`) | `idle` block in `shell.json` | ported → `omarchy/shell.json` |
| Hyprland `.conf` files | Hyprland `.lua` files | ported → `hypr/looknfeel.lua` |

Both `waybar` and `hypridle` are no longer installed as packages. `~/.config/hypr/hyprland.lua`
loads only `.lua` modules, so the old `.conf` files were inert even while stowed.

The files in this directory are kept **only** as a reference for the items still
outstanding below. Nothing here is stowed.

## Ported

- **Idle / lock** — `lock: 300` carried over unchanged. The old
  "display off after 600s" listener has no equivalent key; Quattro's idle
  service only exposes `screensaver` and `lock`. `screensaver` is set to `300`
  (not the stock `150`) so nothing happens during the first five idle minutes,
  matching the old behaviour.
- **Indicators** — the four custom Waybar modules (`custom/voxtype`,
  `custom/screenrecording-indicator`, `custom/idle-indicator`,
  `custom/notification-silencing-indicator`) are all covered by the single
  `omarchy.indicators` widget (Dictation / ScreenRecording / StayAwake / Dnd).
- **Tray** — stays disabled. `omarchy.tray` is omitted from the bar layout,
  matching the commented-out `tray` / `group/tray-expander` in the old config.
- **Omarchy menu button** — omitted from the bar's left section, matching the
  commented-out `custom/omarchy`.
- **Weather** — omitted. It was defined in `config.jsonc` but never placed in a
  `modules-*` list, so it was never displayed.
- **Clock** — the stock `dddd HH:mm` / `d MMMM 'W'ww yyyy` formats are an exact
  match for the old `{:L%A %H:%M}` / `{:L%d %B W%V %Y}`. No override needed.
- **Look'n'feel** — active border colour, `dim_inactive` / `dim_strength`, and
  the "no window transparency" rule are in `hypr/looknfeel.lua`.

## Not yet migrated

- [ ] **Workspaces styling.** The old config pinned workspaces 1–5 as always
      present, used numeric labels, and rendered the active workspace as `󱓻`.
      The stock `omarchy.workspaces` widget exposes no settings for any of this.
      Requires:
      ```
      omarchy plugin clone omarchy.workspaces
      # then edit ~/.config/omarchy/plugins/francois.workspaces/Workspaces.qml
      ```
      A clone drifts from upstream on updates, so this is deliberately deferred
      until the stock widget has been lived with for a while.

- [ ] **Bar styling.** All of `waybar/style.css` is gone — font
      (`CaskaydiaMono Nerd Font` at 12px), per-module margins, the 26px bar
      height, and the `#a55555` active-indicator colour. The Omarchy shell is
      themed by the active Omarchy theme rather than by user CSS. Revisit only
      if the stock theming looks wrong.

- [ ] **`omarchy.agents` widget.** New in Quattro with no pre-Quattro
      counterpart, so it was kept at its default position rather than being
      opted out of. Remove it from `omarchy/shell.json` if it is unwanted.

## Stale files on the live system

`~/.config/hypr/` still holds pre-Quattro leftovers that Omarchy's upgrade left
behind (`*.conf`, `*.conf.old`, `*.conf.bak.*`,
`*.omarchy-upgrade-to-quattro.*.bak`). They are unused. Delete them once this
migration is confirmed good.
