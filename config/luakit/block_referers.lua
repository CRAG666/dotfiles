--- Global Referrer control, UI module
--
-- This module lets you toggle sending referrers globally using ,tf.
--
-- # Usage
--
--     require_module("block_referers")
--
-- @module block_referers
-- @copyright 2020 Demi

local _M = {}

local wm = require_web_module("block_referers_wm")
local modes = require("modes")
local add_binds = modes.add_binds

local referers_enabled = false;

function toggle_referrers(w)
    if referers_enabled then
        wm:emit_signal("disable-referers")
        referers_enabled = false
        w:notify("Referrers disabled")
    else
        wm:emit_signal("enable-referers")
        referers_enabled = true
        w:notify("Referrers enabled")
    end
end

wm:add_signal("referers-enabled", function(channel, enabled) 
    -- I'd like to w:notify here, but I have no idea how to get to w...
    if enabled then
        print("referers enabled")
    else
        print("referers disabled")
    end
end)

add_binds("normal", {
    { "^,tf$", "Enable/disable referrer sending", toggle_referrers},
})

return _M

-- vim: et:sw=4:ts=8:sts=4:tw=80
