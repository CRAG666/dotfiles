-- Autoscroll script for luakit (luakit.org).
-- Originally by @mason-larobina
-- (https://gist.github.com/mason-larobina/726550)
--
-- Install instructions:
--  * Add to rc.lua before window spawning code
--  Or
--  * Save to $XDG_CONFIG_HOME/luakit/autoscroll.lua and
--    add `require "autoscroll"` to your rc.lua
----------------------------------------------------------------

local lousy = require( 'lousy' )
local widgets  = require( 'lousy.widget' )
local modes  = require( 'modes' )
local binds  = require( 'binds' )

local buf, key = widgets.buf, binds.key
local scroll_step = 1 -- globals.scroll_step -- (too fast)

modes .new_mode( "autoscroll", {
			-- Start autoscroll timer
			enter = function( w )
			   w :set_prompt( "-- AUTOSCROLL MODE --" )
			   local t = timer{ interval = 50 }
			   t :add_signal("timeout", function ()
							   w :scroll { yrel = scroll_step }
			   end)
			   w .autoscroll_timer = t
			   t :start()
			end,

			-- Stop autoscroll timer
			leave = function( w )
			   if w .autoscroll_timer then
				  w .autoscroll_timer :stop()
				  w .autoscroll_timer = nil
			   end
			end,
})

modes .add_binds( "normal", {
    -- Start autoscroll with ,a
    { '^,a$', 'autoscroll', function( w )
       w :set_mode( "autoscroll" )
    end },
})

modes .add_binds( "autoscroll", {
    { '+',  'Increase scrolling speed.',  function( w )
        w .autoscroll_timer:stop()
        w .autoscroll_timer.interval = math.max(5, w .autoscroll_timer.interval - 5)
        w .autoscroll_timer:start()
    end },

    { '-',  'Decrease scrolling speed.',  function( w )
				w .autoscroll_timer:stop()
				w .autoscroll_timer.interval = w .autoscroll_timer.interval + 5
				w .autoscroll_timer:start()
		 end },

    { 'Page_Down',  'Scroll page down.',  function( w )
        w :scroll{ ypagerel =  1.0 } end },

    { 'Page_Up',  'Scroll page up.',  function( w )
        w :scroll{ ypagerel = -1.0 } end },
})

