-- Port of nvim's `core/format.lua`: format on save
-- nvim formats through efm-langserver; vis-lspc only talks to one server per
-- filetype, so the efm formatters (after/lsp/*.lua) run directly instead

local util = require('core.util')
local sh = util.shellescape

local M = {}

---@type table<string, boolean>
local executable_cache = {}

---@param bin string
---@return boolean
local function executable(bin)
  if executable_cache[bin] == nil then
    executable_cache[bin] = util.run('command -v ' .. sh(bin)) ~= nil
  end
  return executable_cache[bin]
end

---@param win table
---@return string
local function path(win)
  return win.file.path or (util.file_dir(win) .. '/stdin')
end

---@param win table
---@return string?
local function prettier(win)
  for _, bin in ipairs({ 'prettier_d', 'prettierd', 'prettier' }) do
    if executable(bin) then
      local opts = bin == 'prettier'
          and string.format(
            ' --tab-width=%d --use-tabs=%s',
            win.options.tabwidth,
            tostring(not win.options.expandtab)
          )
        or ''
      return bin .. ' --stdin-filepath ' .. sh(path(win)) .. opts
    end
  end
end

---@param win table
---@return string?
local function clang_format(win)
  if executable('clang-format') then
    return 'clang-format --assume-filename=' .. sh(path(win))
  end
end

---Formatter commands by vis syntax, reading stdin and writing stdout
---@type table<string, fun(win: table): string?>
M.formatters = {
  lua = function(win)
    if executable('stylua') then
      return 'stylua --stdin-filepath ' .. sh(path(win)) .. ' --color Never -'
    end
  end,
  bash = function(win)
    if executable('shfmt') then
      local indent = win.options.expandtab and win.options.tabwidth or 0
      return string.format(
        'shfmt --keep-padding --filename %s --indent=%d -',
        sh(path(win)),
        indent
      )
    end
  end,
  python = function(win)
    if executable('ruff') then
      return 'ruff format --stdin-filename ' .. sh(path(win)) .. ' -'
    end
  end,
  typst = function()
    if executable('typstyle') then
      return 'typstyle'
    end
  end,
  latex = function()
    if executable('tex-fmt') then
      return 'tex-fmt -n -t -p -s'
    end
  end,
  bibtex = function()
    if executable('bibtex-tidy') then
      return 'bibtex-tidy --v2 --curly --numeric --align=13 --blank-lines'
        .. ' --duplicates=key,doi,citation,abstract --merge --sort-fields'
        .. ' --remove-empty-fields --wrap=106'
    end
  end,
  javascript = prettier,
  typescript = prettier,
  json = prettier,
  html = prettier,
  css = prettier,
  ansi_c = clang_format,
  c = clang_format,
  cpp = clang_format,
  cuda = clang_format,
}

---Format the file shown in `win`
---@param win table
---@return boolean formatted
function M.format(win)
  local formatter = M.formatters[win.syntax or '']
  local cmd = formatter and formatter(win)
  if not cmd then
    return false
  end

  local file = win.file
  local status, out, err =
    vis:pipe(file, { start = 0, finish = file.size }, cmd)
  if status ~= 0 or not out then
    local msg = err and err:match('[^\n]+') or ('exit status ' .. status)
    vis:info('Format failed: ' .. msg)
    return false
  end
  if out == file:content(0, file.size) then
    return true
  end

  local line, col = win.selection.line, win.selection.col
  file:delete(0, file.size)
  file:insert(0, out)
  win.selection:to(math.min(line, #file.lines), col)
  return true
end

---@param file table
---@return table?
local function win_for_file(file)
  if vis.win and vis.win.file == file then
    return vis.win
  end
  for win in vis:windows() do
    if win.file == file then
      return win
    end
  end
end

-- Format on save
vis.events.subscribe(vis.events.FILE_SAVE_PRE, function(file)
  local win = win_for_file(file)
  if win and not win.bigfile and not win.no_format then
    M.format(win)
  end
end)

vis:map(vis.modes.NORMAL, 'gq;', function()
  if not M.format(vis.win) then
    vis:info('No formatter for ' .. (vis.win.syntax or 'this file'))
  end
end, 'Format buffer')

vis:command_register('format-toggle', function(_, _, win)
  win.no_format = not win.no_format or nil
  vis:info('Format on save ' .. (win.no_format and 'disabled' or 'enabled'))
  return true
end, 'Toggle format on save for the current window')

return M
