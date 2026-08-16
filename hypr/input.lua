-- Control your input devices.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
--
-- Ported from the pre-Quattro input.conf (kept in legacy/hypr/). Only the
-- settings that differ from Omarchy's Quattro defaults are repeated here;
-- kb_options, repeat_rate, numlock_by_default and touchpad.scroll_factor all
-- already match the new defaults, and the scroll_touchpad window rules for
-- terminals now ship in $OMARCHY_PATH/default/hypr/input.lua.

hl.config({
  input = {
    -- Faster key repeat onset than the 250ms default.
    repeat_delay = 600,

    -- Increase pointer sensitivity (default: 0).
    sensitivity = -0.35,
    accel_profile = "adaptive",

    -- Focus follows the mouse, including across windows of the same app.
    follow_mouse = 2,
  },

  cursor = {
    -- Don't teleport the pointer to a newly focused window.
    no_warps = true,
  },
})
