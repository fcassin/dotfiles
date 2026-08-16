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
- **`omarchy.agents`** — new in Quattro with no pre-Quattro counterpart. Kept at
  its default position; confirmed wanted.
- **Clock** — the stock `dddd HH:mm` / `d MMMM 'W'ww yyyy` formats are an exact
  match for the old `{:L%A %H:%M}` / `{:L%d %B W%V %Y}`. No override needed.
- **Look'n'feel** — active border colour, `dim_inactive` / `dim_strength`, and
  the "no window transparency" rule are in `hypr/looknfeel.lua`.
- **Workspaces styling** — nothing to do. The stock `omarchy.workspaces` widget
  already reproduces the old Waybar config exactly, hardcoded in
  `$OMARCHY_PATH/shell/plugins/bar/widgets/Workspaces.qml`:

  | Old Waybar setting | Stock widget |
  | --- | --- |
  | `persistent-workspaces` 1–5 | `var ids = [1, 2, 3, 4, 5]` |
  | numeric `format-icons`, `"10": "0"` | `modelData === 10 ? "0" : String(modelData)` |
  | `"active": "󱓻"` | same glyph (U+F14FB), verified |
  | `.empty { opacity: 0.5 }` | `occupied \|\| focused ? 1 : 0.5` |
  | `padding: 0 6px` | `horizontalMargin: 6` |

  Only edge-case difference: the widget ignores workspaces above 10, where
  Waybar would have shown them. No `omarchy plugin clone` needed — avoid one,
  since a clone would freeze this at the current version and drift on updates.

## Bar styling (`style.css`)

Nothing here needs porting — the Omarchy shell is styled by the active theme
rather than by user CSS:

- **Font family** — the CSS set the bar to `CaskaydiaMono Nerd Font`; the system
  resolves `monospace` to `JetBrainsMono Nerd Font`. Staying on JetBrains by
  choice. To revisit, `omarchy font set "CaskaydiaMono Nerd Font"` — but note
  the shell resolves its font through the `monospace` fontconfig alias, so that
  is a **system-wide** change that moves the terminal too, not a bar-only one.
- **Font size** — the CSS said 12px; `Style.fontBaseSize` already defaults to 12.
- **Bar height / per-module margins** — the old fixed 26px height and the
  hand-tuned per-module margins are now derived tokens (`barToken`,
  `spacingToken`) that scale with font size. Themes override them via
  `shell.toml`; there is no user-CSS layer to port them into.
- **`#a55555` active-indicator colour** — now supplied by the theme's
  `colors.toml`.
- **`.hidden { opacity: 0 }`** — this was the GTK3 workaround for Waybar
  crashing on `display: none`. Moot; the shell is Quickshell, not GTK.

## Input and monitors — recovered after the upgrade dropped them

The Quattro upgrade wrote fresh comment-only `input.lua` and `bindings.lua`
stubs and **did not migrate the values** from the old `.conf` files. Those
settings were unversioned local edits, so the repo had nothing to replay them
from either. Verified against `hyprctl getoption` and re-ported into stowed
`hypr/input.lua` and `hypr/monitors.lua`:

| Setting | After upgrade | Restored |
| --- | --- | --- |
| `input.sensitivity` | `0` | `-0.35` |
| `input.accel_profile` | unset | `adaptive` |
| `input.follow_mouse` | `1` | `2` |
| `input.repeat_delay` | `250` | `600` |
| `cursor.no_warps` | `false` | `true` |
| `monitor DP-3` | generic `preferred/auto` | `3840x2160@144`, scale `1.666667` |

Deliberately *not* carried over:

- `GDK_SCALE=2` — per-machine value, and this repo is shared across machines.
- `scroll_touchpad` rules for terminals — Quattro ships these in
  `$OMARCHY_PATH/default/hypr/input.lua`, so repeating them is redundant.
- `kb_options`, `repeat_rate`, `numlock_by_default`, `touchpad.scroll_factor` —
  the new defaults already match the old values.
- `bindings.conf` — all 58 bindings were Omarchy defaults that Quattro still
  ships (confirmed via `hyprctl binds`), so `bindings.lua` stays empty.

`monitor eDP-1` was also restored explicitly, though the generic catch-all
happened to resolve identically on this machine.

## Still outstanding

Nothing. Stale `~/.config/hypr` leftovers were deleted once the above was
ported and verified; `input.conf` and `monitors.conf` are preserved here since
they were never previously under version control.
