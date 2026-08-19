-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- Ported from the pre-Quattro monitors.conf (kept in legacy/hypr/). The old
-- file also exported GDK_SCALE=2; that is intentionally dropped, since it is a
-- per-machine value and this repo is shared across machines.
--
-- Rules are matched per output, so every machine's displays can live here
-- together: a rule whose output is absent is simply never applied. Panels that
-- move between ports are keyed by `desc:` (the description from
-- `hyprctl monitors all`) instead of a port name.

-- Framework 13 internal display.
hl.monitor({ output = "eDP-1", mode = "2256x1504@60", position = "auto", scale = 2 })

-- External 4K 144Hz, on the laptop's dock.
hl.monitor({ output = "DP-3", mode = "3840x2160@144", position = "auto", scale = 1.666667 })

-- Desktop: Dell G3223Q 32" 4K 144Hz.
hl.monitor({ output = "desc:Dell Inc. DELL G3223Q D3RQ1P3", mode = "3840x2160@144", position = "auto", scale = 1.6 })
