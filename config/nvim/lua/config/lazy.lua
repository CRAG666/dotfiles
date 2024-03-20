---@class lazyvim.util.plugin
local M = {}

M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

---@type table<string, string>
function M.lazy_file()
  M.use_lazy_file = M.use_lazy_file and vim.fn.argc(-1) > 0

  -- Add support for the LazyFile event
  local Event = require "lazy.core.handler.event"

  if M.use_lazy_file then
    -- We'll handle delayed execution of events ourselves
    Event.mappings.LazyFile = { id = "LazyFile", event = "User", pattern = "LazyFile" }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
  else
    -- Don't delay execution of LazyFile events, but let lazy know about the mapping
    Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
    return
  end

  local events = {} ---@type {event: string, buf: number, data?: any}[]

  local done = false
  local function load()
    if #events == 0 or done then
      return
    end
    done = true
    vim.api.nvim_del_augroup_by_name "lazy_file"

    ---@type table<string,string[]>
    local skips = {}
    for _, event in ipairs(events) do
      skips[event.event] = skips[event.event] or Event.get_augroups(event.event)
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
    for _, event in ipairs(events) do
      if vim.api.nvim_buf_is_valid(event.buf) then
        Event.trigger {
          event = event.event,
          exclude = skips[event.event],
          data = event.data,
          buf = event.buf,
        }
        if vim.bo[event.buf].filetype then
          Event.trigger {
            event = "FileType",
            buf = event.buf,
          }
        end
      end
    end
    vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
    events = {}
  end

  -- schedule wrap so that nested autocmds are executed
  -- and the UI can continue rendering without blocking
  load = vim.schedule_wrap(load)

  vim.api.nvim_create_autocmd(M.lazy_file_events, {
    group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
    callback = function(event)
      table.insert(events, event)
      load()
    end,
  })
end

function M.setup()
  local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  end
  vim.opt.rtp:prepend(lazypath)
  M.lazy_file()
  local icons = require "utils.static.icons"
  require("lazy").setup {
    spec = {
      { import = "plugins.ui" },
      { import = "plugins.dev" },
      { import = "plugins.dev.lang" },
      { import = "plugins.general" },
      { import = "plugins.modes" },
    },
    defaults = {
      lazy = true,
      version = false,
      autocmds = true,
      keymaps = false,
    },
    dev = {
      ---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
      path = "~/Git",
      ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
      patterns = {}, -- For example {"folke"}
      fallback = false, -- Fallback to git when local plugin doesn't exist
    },

    checker = { enabled = true },

    change_detection = {
      enable = true,
      notify = false,
    },

    install = {
      missing = true,
      colorscheme = { "catppuccin", "default" },
    },
    ui = {
      -- a number <1 is a percentage., >1 is a fixed size
      size = { width = 0.88, height = 0.8 },
      wrap = true, -- wrap the lines in the ui
      -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
      border = "rounded",
      icons = {
        cmd = icons.misc.Code,
        config = icons.ui.Gear,
        event = icons.kinds.Event,
        ft = icons.kinds.File,
        init = icons.misc.ManUp,
        import = icons.documents.Import,
        keys = icons.kinds.Keyboard,
        loaded = icons.ui.Check,
        not_loaded = icons.misc.Ghost,
        plugin = icons.ui.Package,
        runtime = icons.ft.Vim,
        source = icons.kinds.StaticMethod,
        start = icons.ui.Play,
        list = {
          icons.ui.BigCircle,
          icons.ui.BigUnfilledCircle,
          icons.ui.Square,
          icons.ui.ChevronRight,
        },
      },
    },
    performance = {
      cache = {
        enabled = true,
        disable_events = { "UIEnter", "BufReadPre" },
      },
      rtp = {
        disabled_plugins = {
          "2html_plugin",
          "bugreport",
          "compiler",
          "ftplugin",
          "getscript",
          "getscriptPlugin",
          "gzip",
          "logipat",
          "matchit",
          "netrw",
          "netrwFileHandlers",
          "netrwPlugin",
          "netrwSettings",
          "optwin",
          "rplugin",
          "rrhelper",
          "spellfile_plugin",
          "synmenu",
          "syntax",
          "tar",
          "tarPlugin",
          "tohtml",
          "tutor",
          "vimball",
          "vimballPlugin",
          "zip",
          "zipPlugin",
        },
      },
    },
  }
end

return M
