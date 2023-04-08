--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  luakit configuration file, more information at https://luakit.github.io/  --
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

require( 'lfs' )
require( 'unique_instance' )

--  Check for Lua config files that will never be loaded,
--  because they are shadowed by builtin modules.
table .insert( package .loaders,  2,  function( modname )
    if not package .searchpath then return end

    local f = package .searchpath( modname,  package.path )
    if not f
        or f :find( luakit .install_paths .install_dir ..'/', 0, true ) ~= 1 then
        return ; end
    local lf = luakit .config_dir ..'/' ..modname :gsub( '%.', '/' ) ..'.lua'
    if f == lf then
        msg .warn( "Loading local version of '" ..modname .."' module: " ..lf )
    elseif lfs .attributes( lf ) then
        msg .warn( "Found local version " ..lf
            .." for core module '" ..modname
            .."', but it won't be used, unless you update 'package.path' accordingly.")
    end
end)

luakit .process_limit = 4  --  Max web processes. 0 = 'no limit'. No effect since WebKit 2.26

soup .cookies_storage = luakit .data_dir ..'/cookies.db'  --  Cookie storage location

local lousy  = require( 'lousy' )  --  Library.Of.Useful.Stuff.You can use in luakit

-- ( "$XDG_CONFIG_HOME/luakit/theme.lua"  or  "/etc/xdg/luakit/theme.lua" )
-- ( "$XDG_CONFIG_HOME/luakit/window.lua"  or  "/etc/xdg/luakit/window.lua" )
-- ( "$XDG_CONFIG_HOME/luakit/webview.lua"  or  "/etc/xdg/luakit/webview.lua" )

lousy .theme .init( lousy .util .find_config( 'theme.lua' ) )  --  Load user or default theme
assert( lousy .theme .get(), 'failed to load theme' )

local window  = require( 'window' )  --  Load user or default window class
local webview  = require( 'webview' )  --  Load user or default webview class

local modes  = require( 'modes' )  --  emit signals: 'normal', 'init', 'insert', 'command'...
local binds  = require( 'binds' )  --  keybindings
local settings  = require( 'settings' )  --  ability to store & change variables within modules

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  Optional modules:
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local bookmarks  = require( 'bookmarks' )  --  Add bookmarks support
local quickmarks = require( 'quickmarks' )  --  Quickmarks support & manager

local downloads = require( 'downloads' )  --  Add download capability
local viewpdf   = require( 'viewpdf' )  --  Automatic PDF downloading & opening
local image_css = require( 'image_css' )  --  Add a stylesheet when showing images

local userscripts  = require( 'userscripts' )  --  Greasemonkey-like JavaScript / Userscript support '.user.js'
local styles  = require( 'styles' )  --  loader for user's local CSS styles
local noscript  = require( 'noscript' )  --  Toggle JS &/or plugins on a per-domain basis.

--  `,ts` to toggle scripts,  `,tp` to toggle plugins,  `,tr` to reset.
--  IF you use this module, careful using any site-specific
--  `enable_scripts` or `enable_plugins` settings, as these may conflict.

--local view_source  = require( 'view_source' )  --  Add :view-source command
local webinspector  = require( 'webinspector' )
local error_page  = require( 'error_page' )

local search  = require( 'search' )  --  Search mode  & binds
local formfiller  = require( 'formfiller' )  --  Add uzbl-like form filling
--local open_editor  = require( 'open_editor' --  Press Control-E while in insert mode
--  to edit contents of currently focused <textarea> or <input> element, using `xdg-open`

local session  = require( 'session' )  --  Session saving /loading support
local history  = require( 'history' )  --  Save web history
local cmdhist  = require( 'cmdhist' )  --  Command history  : then key Up
local completion  = require( 'completion' )  --  Command completion w/ Tab key

local taborder  = require( 'taborder' )  --  Add ordering of new tabs
local tab_favicons  = require( 'tab_favicons' )  --  Insert favicons into tabs
--local tabhistory  = require( 'tabhistory' )  --  Command to list tab history items
--local undoclose  = require( 'undoclose' )  --  List closed tabs  & bind to open closed tabs

--local follow  = require( 'follow' )  --  Vimperator-like link hinting  & following
--local follow_selected  = require( 'follow_selected' )
--local hide_scrollbars  = require( 'hide_scrollbars' )  --  Hide scrollbars on all pages

local go_input  = require( 'go_input' )
local go_next_prev  = require( 'go_next_prev' )
local go_up  = require( 'go_up' )

--  Filter Referer HTTP header if page domain does not match Referer domain
require_web_module( 'referer_control_wm' )  --  cannot be local?
--local proxy  = require( 'proxy' )  --  Socks proxy support & manager

--  gist.github.com/mason-larobina/726550  //  gist.github.com/alexdantas/7987616
require( 'autoscroll' )

require( 'userconf' )

require( 'allowed' )  --  dedicated script to allow JS & images on trusted websites

require_web_module("block_referers_wm")
require("block_referers")
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  End various required & optional module imports.
--  Generate pages to facilitate human-interaction:
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local log_chrome  = require( 'log_chrome' )  --  Add  luakit://log/  page
local help_chrome  = require( 'help_chrome' )  --  Add  luakit://help/  page
local binds_chrome  = require( 'binds_chrome' )  --  Add  luakit://binds/  page
local newtab_chrome  = require( 'newtab_chrome' )  --  Add  luakit://newtab/  page
local history_chrome  = require( 'history_chrome' )   --  Add  luakit://history/  page
local settings_chrome  = require( 'settings_chrome' )  --  Add  luakit://settings/  page
local bookmarks_chrome  = require( 'bookmarks_chrome' ) --  Add  luakit://bookmarks/  page
local downloads_chrome  = require( 'downloads_chrome' )  --  Add  luakit://downloads/  page

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  Build statusbar from aforementioned modules:
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

window .add_signal( 'build',  function( w )
    local widgets  = require( 'lousy.widget' )

    local la  = w .sbar .l  --  Left-aligned status bar widgets:
    la .layout :pack( widgets .uri() )  --  https://this.that/and/the/other/
    --  la .layout :pack( widgets .hist() )  --  [-] fore  [+] back
    la .layout :pack( widgets .progress() )  --  80%

    local ra  = w .sbar .r  --  Right-aligned status bar widgets:
    ra .layout :pack( widgets .buf() )  --  S
    ra .layout :pack( log_chrome .widget() )  --  E: 32
    ra .layout :pack( widgets .ssl() )  --  (trust)
    ra .layout :pack( widgets .tabi() )  --  tab index [1/5]  [current/total]
    --  ra .layout :pack( widgets .scroll() )  --  scroll down page %
    ra .layout :pack( widgets .zoom() )  --  shows zoom level of current page
end)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  Restore last saved session:
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local w = ( not luakit .nounique ) and ( session and session .restore() )

if w then
    for i, uri in ipairs( uris ) do
        w :new_tab( uri, { switch = i == 1 } )
    end
else
    window .new( uris )  --  Or open new window
end

-- vim: et:sw=4:ts=8:sts=4:tw=80
