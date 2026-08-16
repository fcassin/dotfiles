-- Change the default Omarchy look'n'feel.
-- Ported from the pre-Quattro looknfeel.conf (kept in legacy/hypr/).

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    col = {
      -- Catppuccin text white for the focused window border instead of the
      -- default blue/green gradient.
      active_border = "rgb(cdd6f4)",
    },
  },

  -- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
  decoration = {
    dim_inactive = true,
    dim_strength = 0.25,
  },
})

-- Disable all window transparency. Omarchy tags every window with
-- "default-opacity" and applies `opacity 0.985 0.96` to that tag; this file is
-- required after those defaults, so the last matching rule wins.
o.window(".*", { opacity = "1.0 1.0" })
