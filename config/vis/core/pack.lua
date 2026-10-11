-- Port of nvim's `core/pack.lua`, plugins are managed by vis-plug
-- vis-plug and the plugins live in `$XDG_CACHE_HOME/vis-plug`, outside the
-- dotfiles repo; use `:plug-install`, `:plug-update`, `:plug-list`, ...

local util = require('core.util')

local cache = (os.getenv('XDG_CACHE_HOME') or os.getenv('HOME') .. '/.cache')
  .. '/vis-plug'
local plug_dir = cache .. '/vis-plug'

if not util.exists(plug_dir .. '/init.lua') then
  os.execute(
    'git clone --quiet --depth 1 https://github.com/erf/vis-plug '
      .. util.shellescape(plug_dir)
  )
end
package.path = cache .. '/?/init.lua;' .. package.path

local ok, plug = pcall(require, 'vis-plug')
if not ok then
  vis:info('vis-plug not available, plugins disabled')
  return { plugins = {} }
end

local specs = {
  -- LSP client (nvim's builtin vim.lsp)
  { 'https://codeberg.org/muhq/vis-lspc', alias = 'lspc' },
  -- Restore last cursor position (`last_pos_jmp` autocmd)
  { 'erf/vis-cursors' },
  -- `cs`/`ds` (nvim-surround)
  { 'lutobler/vis-surround' },
  -- Spell checking (`spell`, `spelllang`)
  { 'https://codeberg.org/muhq/vis-spellcheck', alias = 'spellcheck' },
}
plug.init(specs, true)

local spellcheck = plug.plugins.spellcheck
if spellcheck then
  spellcheck.cmd = 'hunspell -a -d %s'
  spellcheck.list_cmd = 'hunspell -l -d %s'
  -- `spelllang = 'en,es'`, hunspell checks against both dictionaries
  spellcheck.default_lang = 'en_US,es_MX'
  -- `spell` is on in every window, as nvim sets it on `UIEnter`; runs after
  -- core/autocmds.lua marked big files
  vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    if not win.bigfile then
      win.file.spelling_language = win.file.spelling_language
        or spellcheck.default_lang
      win.spell = win.file.spelling_language
      vis:command('spell+')
    end
  end)
  -- vis-spellcheck still calls `win:style_define`, styles are global since
  -- vis moved them to `vis.ui`; its default id (42) may belong to a lexer tag
  vis.types.window.style_define = function(_, id, style)
    return vis.ui:style_define(id, style)
  end
  -- `SpellBad`, the theme is set by core/opts.lua on INIT
  vis.events.subscribe(vis.events.INIT, function()
    spellcheck.typo_style_id = vis.ui:style_push()
    local c = vis.lexers.eyes
    if c then
      spellcheck.typo_style = 'fore:' .. c.red .. ',underlined'
    end
  end)
end

-- stylua: ignore start
vis:map(vis.modes.NORMAL, ' Pu', ':plug-update<Enter>', 'Update plugins')
vis:map(vis.modes.NORMAL, ' Pi', ':plug-install<Enter>', 'Install plugins')
vis:map(vis.modes.NORMAL, ' Pl', ':plug-list<Enter>', 'List plugins')
-- stylua: ignore end
vis:map(vis.modes.NORMAL, ' Pd', function()
  local names = {}
  for _, spec in ipairs(specs) do
    table.insert(names, spec.name)
  end
  local name = require('core.pick').select(names, 'Plugin to delete')
  if name then
    vis:command('plug-remove ' .. name)
  end
end, 'Delete plugin')

return plug
