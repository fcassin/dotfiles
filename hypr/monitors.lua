-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- Ported from the pre-Quattro monitors.conf (kept in legacy/hypr/). The old
-- file also exported GDK_SCALE=2; that is intentionally dropped, since it is a
-- per-machine value and this repo is shared across machines.

-- Framework 13 internal display.
hl.monitor({ output = "eDP-1", mode = "2256x1504@60", position = "auto", scale = 2 })

-- External 4K 144Hz.
hl.monitor({ output = "DP-3", mode = "3840x2160@144", position = "auto", scale = 1.666667 })
