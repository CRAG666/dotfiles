-- Port of nvim's `filetype.lua`, `after/ftplugin/*` and vim-sleuth
-- Settings are keyed by vis syntax (lexer) name and stored on the window as
-- `win.ft`, so other modules (comments, formatting) can read them

local M = {}

---@class FtSettings
---@field tabwidth? integer
---@field expandtab? boolean
---@field textwidth? integer `colorcolumn` follows it as in nvim (`+1`)
---@field commentstring? string
---@field sleuth? boolean detect indentation from file content, default true

---@type FtSettings
local defaults = { commentstring = '# %s' }

-- stylua: ignore start
local c_like = { tabwidth = 2, expandtab = true, commentstring = '// %s' }

---@type table<string, FtSettings>
M.settings = {
  ansi_c      = c_like,
  c           = c_like,
  cpp         = c_like,
  cuda        = c_like,
  objective_c = c_like,
  csharp      = { tabwidth = 4, expandtab = true, commentstring = '// %s' },
  css         = { commentstring = '/* %s */' },
  html        = { commentstring = '<!-- %s -->' },
  javascript  = { commentstring = '// %s' },
  typescript  = { commentstring = '// %s' },
  json        = { tabwidth = 2, expandtab = true, textwidth = 106, commentstring = '// %s' },
  lua         = { tabwidth = 2, expandtab = true, textwidth = 106, commentstring = '-- %s' },
  python      = { tabwidth = 4, expandtab = true, textwidth = 88 },
  makefile    = { tabwidth = 4, expandtab = false, sleuth = false },
  markdown    = { tabwidth = 4, expandtab = true, commentstring = '<!-- %s -->' },
  latex       = { textwidth = 88, commentstring = '% %s' },
  bibtex      = { textwidth = 106, commentstring = '% %s' },
  typst       = { tabwidth = 2, expandtab = true, commentstring = '// %s' },
  yaml        = { tabwidth = 2, expandtab = true },
  lisp        = { commentstring = ';; %s' },
  vb          = { commentstring = "' %s" },
  sql         = { commentstring = '-- %s' },
  ini         = { commentstring = '# %s' },
  nim         = { commentstring = '# %s' },
  ['git-commit'] = { textwidth = 72 },
}
-- stylua: ignore end

-- Filetype detection {{{
-- `vis.lexers.detect_extensions` only exists when lpeg is available
if vis.lexers.detect_extensions then
  local ext = vis.lexers.detect_extensions
  -- Weixin Mini Program
  ext.wxss = 'css'
  ext.wxml = 'html'
  ext.rasi = 'css'
  ext.typ = 'typst'
  ext.jsonc = 'json'
  ext.zathurarc = 'ini'
end

vis.ftdetect.filetypes.hyprlang = {
  lexer = 'ini',
  detect = function(file)
    return file.path ~= nil and file.path:find('/hypr/.*%.conf$') ~= nil
  end,
}
-- }}}

---Guess indentation from the first lines of a file, like vim-sleuth
---@param file table
---@return { expandtab: boolean, tabwidth?: integer }?
local function sleuth(file)
  local tabs, spaces = 0, 0
  local widths = {} ---@type table<integer, integer>
  local n = 0
  for line in file:lines_iterator() do
    n = n + 1
    if n > 512 then
      break
    end
    if line:find('^\t') then
      tabs = tabs + 1
    else
      local indent = line:match('^( +)%S')
      -- Skip block comment continuation lines (` * foo`)
      if indent and not line:find('^ +%*') then
        spaces = spaces + 1
        widths[#indent] = (widths[#indent] or 0) + 1
      end
    end
  end

  if tabs == 0 and spaces == 0 then
    return nil
  end
  if tabs > spaces then
    return { expandtab = false }
  end
  -- Smallest indent seen at least twice, ignoring odd alignment noise
  for _, w in ipairs({ 2, 4, 8, 3 }) do
    if (widths[w] or 0) >= 2 then
      return { expandtab = true, tabwidth = w }
    end
  end
  return { expandtab = true }
end

---Apply filetype settings to a window
---@param win table
function M.apply(win)
  local ft = M.settings[win.syntax] or {}
  win.ft = setmetatable(ft, { __index = defaults })

  if ft.tabwidth then
    win.options.tabwidth = ft.tabwidth
  end
  if ft.expandtab ~= nil then
    win.options.expandtab = ft.expandtab
  end
  -- `colorcolumn` follows `textwidth`, see nvim's `dynamic_cc` autocmd
  if ft.textwidth then
    win.options.colorcolumn = ft.textwidth + 1
  end

  if ft.sleuth ~= false then
    local guess = sleuth(win.file)
    if guess then
      win.options.expandtab = guess.expandtab
      if guess.tabwidth then
        win.options.tabwidth = guess.tabwidth
      end
    end
  end
end

-- Registered after the builtin filetype plugin, so `win.syntax` is set
vis.events.subscribe(vis.events.WIN_OPEN, M.apply)

return M

-- vim:ts=2:sw=2:sts=2:fdm=marker
