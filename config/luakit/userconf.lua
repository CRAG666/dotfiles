--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  User config.  Be sure to require() any modules you desire access to.

print( os.clock(),  'loading userconf.lua' )

local window = require( 'window' )
local webview = require( 'webview' )

local downloads = require( 'downloads' )
local settings = require( 'settings' )

local modes = require( 'modes' )
local binds = require( 'binds' )

local noscript = require( 'noscript' )  --  Toggle JS &/or plugins on a per-domain basis.
local lousy = require( 'lousy' )  --  Library.Of.Useful.Stuff.You can use in luakit
local widgets = require( 'lousy.widget' )
local styles = require( 'styles' )

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

settings.application.prefer_dark_mode = true
settings.window.home_page = 'https://randsearch.daniel.priv.no/'
-- settings.window.new_window_size  = '1000x600'
settings.webview.default_charset = "utf-8"
settings.webview.default_font_family = "Lucida MAC"
settings.webview.cursive_font_family = "Lucida MAC"


--  deprecated in favour of tablist.visibility
--  settings .tablist .always_visible  = false

--  Whether JavaScript will be able to create & run modal dialogs
settings.webview.enable_offline_web_application_cache = false
settings.webview.allow_modal_dialogs = false
settings.webview.auto_load_images = false
settings.webview.load_icons_ignoring_image_load_setting = true  --  favicons

settings.webview.enable_media_stream = false
settings.webview.media_playback_requires_gesture = true

settings.webview.minimum_font_size = 9
settings.webview.enable_fullscreen = false
settings.webview.enable_developer_extras = false
settings.webview.enable_xss_auditor = true  --  cross-scripting

settings.webview.enable_java = false
settings.webview.enable_javascript = false
settings.webview.javascript_can_access_clipboard = false
settings.webview.javascript_can_open_windows_automatically = false

settings.webview.enable_webgl = false
settings.webview.hardware_acceleration_policy = 'always'
settings.webview.enable_accelerated_2d_canvas = false

--  user-agents.net
local UA  = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'

local alt_UA  = 'Mozilla/5.0 (X11; Linux x86_32) Gecko/20100101 Firefox/69.0 r/theyknew'

local twitter_UA  = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.37'

local android_UA  = 'Mozilla/5.0 (Linux; Android 10; SM-N960U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36'

local alt_tor  = 'Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0'

settings.webview.user_agent = UA
settings.webview.zoom_level = 100

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

noscript.enable_scripts = true
noscript.enable_plugins = true

--  allow access to audio & video devices for capture.
-- settings.on['discord.com'].webview.enable_media_stream = true

--  twitter is a bitch & cries about your browser type
settings.on['twitter.com'].webview.user_agent = twitter_UA
settings.on['mobile.twitter.com'].webview.user_agent = twitter_UA

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  :lua settings .on['love2d.org'] .webview .auto_load_images = true

--  Add image-loading ability to a site while actively browsing, then reload.
--  Include website within  allowed.lua  to make changes permanent.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--  Example using xdg-open for opening downloads /showing download folders
downloads.add_signal( 'open-file',  function( file )
    local str = 'xdg-open %q'
    luakit.spawn( str:format( file ) )
    return true
end)

downloads.default_dir = os.getenv( 'HOME' ) ..'/Descargas'

--  default D/L location w/o asking?  luakit.github.io/docs/pages/02-faq.html
downloads.add_signal( 'download-location',  function( uri, file )
    if not file or file == '' then
        file = ( uri:match( '/([^/]+)$' )
            or uri:match( '^%w+://(.+)' )
            or uri:gsub( '/',  '_' )
            or 'untitled' )
    end
    return downloads .default_dir ..'/' ..file
end)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local matches = { 'about:blank',  'luakit://newtab/',  'https://www1.watch-series.la/' }
local begins  = { 'adblock-blocked:' }
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
webview.add_signal( 'init',  function( view )  --  during initialization of a new tab
    --  open certain schemes w/ other apps?  luakit.github.io/docs/pages/02-faq.html
    view:add_signal('navigation-request', function( v, uri, reason)

    --  return  false  to prevent requested navigation from taking place
        local low = uri:lower()

        if low:match( 'youtube%.com/watch%?v=' ) then
            local video_cmd_fmt = "mpv --ytdl '%s'"
            local str = string.gsub(uri or "", " ", "%%20")
            print("Entre")
            luakit.spawn(string.format(video_cmd_fmt, str))
            return false

        -- elseif low:match( 'youtube%.com/%?app=desktop' ) then
            -- return false  --  no redirects from mobile

        elseif low:match( 'www%.reddit%.com/chat/minimize' ) then
            return false  --  skip reddit's slow-@ss chat

        elseif low:match( '%.webv' )
            or low:match( '%.gifv' )
            or low:match( '%.mp4' )
            or low:match( '%.avi' )
            or low:match( 'v%.redd%.it/' )
            or low:match( 'gfycat%.com/' )
            or low:match( '%.redgifs%.com/' )
            or low:match( '%.xvideos%.com/' )
            or low:match( 'clipwatching%.com/' ) then
            --  https://github.com/ytdl-org/youtube-dl/blob/master/docs/supportedsites.md
                local str  = "youtube-dl -o '~/Videos/%%(title)s_%%(id)s.%%(ext)s' %q"
                print( os.clock(),  str:format( uri ) )
                luakit.spawn( str:format( uri ) ) ; return false

        elseif low:match( '^magnet:' ) then
            local str  = 'deluge-gtk %q'
            print( os.clock(),  str:format( uri ) )
            luakit.spawn( str:format( uri ) ) ; return false
        end  --  if low ...

        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        --  destroy unused tabs that have been sitting blank for a good min
        --  reducing unwanted popups, on rampant sites such as swatchseries ( www1.watch-series.la )

        local cantidate = false  --  only keep track of blank tabs
        for i=1, #matches do  --  faster than substring, so we try these first
            if uri == matches[i] then
                cantidate = true ; break
        end;end

        if not cantidate then  --  full match not found, attempt "beginswith"
            for i=1, #begins do
                if uri :sub( 1, #begins[i] ) == begins[i] then
                    cantidate = true ; break
        end;end;end

        --  destroys unwanted blank tabs, but timers keep running?  so errors may accrue.

        if cantidate then  --  start a timer on this tab
            local second  = 1000  --  miliseconds
            local time  = timer{ interval = second *40 }
            --  moment to decide if you wish to do something with blank tab
            time:add_signal( 'timeout',  function()
                if view .is_alive then
                    local certain = false  --  make sure tab is still blank

                    for i=1, #matches do  --  test for full matches
                        if v .uri == matches[i] then
                            certain = true ; break
                    end;end

                    if not certain then  --  attempt "beginswith"
                        for i=1, #begins do
                            if v .uri :sub( 1, #begins[i] ) == begins[i] then
                                certain = true ; break
                    end;end;end

                    if certain then  --  ...and current # of open tabs > 1 ??
                        time :stop()
                        view :destroy()
                        print( os.clock(),  'destroyed',  v .uri )
                    end  --  certain the tab is worthy of deletion
                end  --  .is_alive

            end)  --  time :add_signal( 'timeout',  ... )
            time :start()
        end  --  cantidate

    end)  --  view :add_signal( 'navigation-request',  ... )
end)  --  window .add_signal( 'init',  ... )

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local video_cmd_fmt = "mpv --ytdl '%s'"
modes.add_binds("normal", {
  { "M", "Open the video on the current page externally with MPV.",
      function (w)
        local uri = string.gsub(w.view.uri or "", " ", "%%20")
        luakit.spawn(string.format(video_cmd_fmt, uri))
        w:notify("Launched MPV")
   end},
})
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

modes.add_binds( 'normal', {
    { '<Control-c>',  'Copy selected text.',  function()
        luakit.selection.clipboard = luakit.selection.primary
    end},
})

--  combination 'R' to reload Userstyles & current webpage
modes.add_binds( 'normal', {
    { '<Shift-r>',  'combination Reload',  function( window )
        window:notify( 'Reloading Userstyles...' )
        styles.detect_files()
        window:notify( 'Reloading Userstyles complete, loading webpage now...' )
        window:reload()
    end},
})

modes.add_binds('normal', {
  {"<Control-s>", "Toggle load images",
    function (w)
        noscript.enable_scripts = not noscript.enable_scripts
        noscript.enable_plugins = not noscript.enable_plugins
        -- w:notify( 'Reloading with script, loading webpage now...' )
        w:reload()
    end}})
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  print right-click menu

--[[
webview .add_signal( 'init', function( v )
    v :add_signal( 'populate-popup', function( _, menu )
        for key, val in pairs( menu ) do
            print( key, val )
        end
    end)
end)
]]--

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print( os.clock(),  'userconf loaded ' )

--  eof  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
