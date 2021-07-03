-- Global Referrer control, web module
--
-- The Referer HTTP header is sent automatically to websites to inform them of
-- the referring website; i.e. the website that you were just on. This allows
-- website owners to see where web traffic is coming from, but can also be a
-- privacy concern.
--
-- To help mitigate this concern, this module prevents this information
-- from being sent whenever you navigate between two different domains.
-- For example, if you navigate from `https://example.com/test/` to
-- `https://google.com`, no Referer hreader will be sent. If you navigate
-- from `https://example.com/test/` to `https://example.com/`, however, the
-- Referer header will be sent. This is because some websites depend on
-- this functionality.
--
-- *Note: the word 'referer' is intentionally misspelled for historic reasons.*
--
-- # Usage
--
-- As this is a web module, it will not function if loaded on the main UI Lua
-- process through `require()`. Instead, it should be loaded with
-- `require_web_module()`:
--
--     require_web_module("block_referers_wm")
--
-- @module block_refererers_wm
-- @copyright 2016 Aidan Holm <aidanholm@gmail.com>

local _M = {}
_M.enable_referers = false

local ui = ipc_channel("block_referers_wm")

luakit.add_signal("page-created", 
function(page)
    page:add_signal("send-request", function(p, _, headers)
        if not _M.enable_referers then
        	if not headers.Referer then return end
        	headers.Referer = nil
    	end
    end)
end)

_M.enable_referers = false

ui:add_signal("enable-referers", function (_) 
    _M.enable_referers = true
    ui:emit_signal("referers-enabled", true)
end);

ui:add_signal("disable-referers", function (_) 
    _M.enable_referers = false
    ui:emit_signal("referers-enabled", false)
end);


return _M

-- vim: et:sw=4:ts=8:sts=4:tw=80
