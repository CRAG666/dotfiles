-- Port of nvim's `core/lsp.lua`, `core/diagnostic.lua` and `after/lsp/*`
-- vis-lspc supports one server per filetype; the primary server of each nvim
-- setup is used here, formatters (efm) run from core/format.lua

local util = require('core.util')

local lspc = require('core.pack').plugins.lspc
if not lspc then
  return
end

lspc.autoconfirm_edits = false
lspc.highlight_diagnostics = 'range'
lspc.universal_root_globs = { '.git', '.hg', '.svn' }
lspc.fallback_dirname_as_root = true

local clangd = {
  name = 'clangd',
  cmd = 'clangd',
  roots = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
  },
}
local tsserver = {
  name = 'typescript',
  cmd = 'typescript-language-server --stdio',
  roots = { 'package.json', 'tsconfig.json', 'jsconfig.json' },
}
local texlab = {
  name = 'texlab',
  cmd = 'texlab',
  roots = {
    '.latexmkrc',
    'latexmkrc',
    '.texlabroot',
    'texlabroot',
    'Tectonic.toml',
  },
  settings = {
    texlab = {
      build = {
        executable = 'tectonic',
        args = {
          '-X',
          'compile',
          '%f',
          '-Zsearch-path=/latex',
          '--synctex',
          '--keep-logs',
          '--keep-intermediates',
        },
        onSave = false,
        forwardSearchAfter = false,
      },
      auxDirectory = '.',
      chktex = { onOpenAndSave = false, onEdit = false },
      diagnosticsDelay = 300,
      latexFormatter = 'texlab',
      bibtexFormatter = 'texlab',
    },
  },
}

---Language servers by vis syntax, see nvim's `after/lsp/*.lua`
local servers = {
  ansi_c = clangd,
  c = clangd,
  cpp = clangd,
  cuda = clangd,
  objective_c = clangd,
  javascript = tsserver,
  typescript = tsserver,
  latex = texlab,
  bibtex = texlab,
  lua = {
    name = 'lua-language-server',
    cmd = 'lua-language-server',
    roots = {
      '.luarc.json',
      '.luarc.jsonc',
      '.luacheckrc',
      '.stylua.toml',
      'stylua.toml',
      'selene.toml',
      'selene.yml',
    },
    settings = {
      Lua = {
        hint = { enable = true },
        format = { enable = false }, -- use stylua for formatting
        diagnostics = { globals = { 'vis', 'lexer', 'lpeg' } },
        telemetry = { enable = false },
      },
    },
  },
  python = {
    name = 'basedpyright',
    cmd = 'basedpyright-langserver --stdio',
    roots = {
      'pyrightconfig.json',
      'pyproject.toml',
      'Pipfile',
      'requirements.txt',
      'setup.cfg',
      'setup.py',
      'tox.ini',
      '.python-version',
    },
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = 'standard',
          autoSearchPaths = true,
          useLibraryCodeForTypes = false,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  },
  bash = {
    name = 'bash-language-server',
    cmd = 'bash-language-server start',
    settings = {
      bashIde = {
        globPattern = os.getenv('GLOB_PATTERN')
          or '*@(.sh|.inc|.bash|.command)',
        shfmt = { keepPadding = true },
      },
    },
  },
  markdown = {
    name = 'marksman',
    cmd = 'marksman server',
    roots = { '.marksman.toml', 'build.sh' },
  },
  typst = {
    name = 'tinymist',
    cmd = 'tinymist',
    settings = { formatterMode = 'typstyle' },
  },
  css = {
    name = 'css-language-server',
    cmd = 'vscode-css-language-server --stdio',
  },
  csharp = { name = 'csharp-ls', cmd = 'csharp-ls' },
  nim = { name = 'nimlangserver', cmd = 'nimlangserver' },
  dockerfile = {
    name = 'docker-langserver',
    cmd = 'docker-langserver --stdio',
  },
}

-- Only register installed servers, like nvim's `lsp.start` check, so
-- autostart doesn't complain about missing ones
do
  local bins, seen = {}, {}
  for _, conf in pairs(servers) do
    local bin = conf.cmd:match('^%S+')
    if not seen[bin] then
      seen[bin] = true
      table.insert(bins, util.shellescape(bin))
    end
  end
  local found = {}
  local out = util.run(
    'for b in '
      .. table.concat(bins, ' ')
      .. '; do command -v "$b"; done; true'
  ) or ''
  for path in out:gmatch('[^\n]+') do
    found[path:match('[^/]+$')] = true
  end

  lspc.ls_map = {}
  for syntax, conf in pairs(servers) do
    if found[conf.cmd:match('^%S+')] then
      lspc.ls_map[syntax] = conf
    end
  end
end

-- Diagnostic styles from the eyes palette, see `Diagnostic*` in
-- colors/eyes.lua; the theme is set by core/opts.lua on INIT
vis.events.subscribe(vis.events.INIT, function()
  local c = vis.lexers.eyes
  if not c then
    return
  end
  lspc.diagnostic_styles = {
    error = 'fore:' .. c.red .. ',back:' .. c.winterRed,
    warning = 'fore:' .. c.yellow .. ',back:' .. c.winterYellow,
    information = 'fore:' .. c.blue1 .. ',back:' .. c.winterBlue,
    hint = 'fore:' .. c.aqua .. ',back:' .. c.winterGreen,
  }
end)

-- Keymaps {{{
-- vis-lspc's defaults use <Space>e/n/N/D, which collide with the leader maps,
-- and `gr`, which would shadow nvim's `grr`/`grn`/...
local N, I = vis.modes.NORMAL, vis.modes.INSERT
for _, lhs in ipairs({ ' e', ' n', ' N', ' D', 'gr' }) do
  vis:unmap(N, lhs)
end

---@param cmd string
---@return string
local function lsp(cmd)
  return ':lspc-' .. cmd .. '<Enter>'
end

-- stylua: ignore start
-- nvim defaults (`gr*`, `K`, `[d`/`]d`) plus the custom maps from core/lsp.lua
vis:map(N, 'gd',  lsp('definition'),     'Go to definition')
vis:map(N, 'gD',  lsp('declaration'),    'Go to declaration')
vis:map(N, 'g/',  lsp('references'),     'Go to references')
vis:map(N, 'grr', lsp('references'),     'Go to references')
vis:map(N, 'g.',  lsp('implementation'), 'Go to implementation')
vis:map(N, 'gri', lsp('implementation'), 'Go to implementation')
vis:map(N, 'grt', lsp('typeDefinition'), 'Go to type definition')
vis:map(N, 'grn', ':lspc-rename ',       'Rename symbol')
vis:map(N, 'K',   lsp('hover'),          'Hover')
vis:map(N, ']d',  lsp('next-diagnostic'), 'Next diagnostic')
vis:map(N, '[d',  lsp('prev-diagnostic'), 'Previous diagnostic')
vis:map(N, ' sd', lsp('show-diagnostics'), 'Diagnostics')
vis:map(N, ' ls', lsp('start-server'),   'Start language server')
vis:map(N, ' lS', lsp('shutdown-server'), 'Stop language server')
vis:map(N, ' ;',  lsp('navigate-symbols'), 'Pick symbols')
vis:map(N, ' i',  lsp('show-diagnostics'), 'Show line diagnostics')
vis:map(N, '<M-d>', lsp('show-diagnostics'), 'Show line diagnostics')
vis:map(I, '<C-x><C-o>', function()
  vis:command('lspc-completion')
  vis.mode = vis.modes.INSERT
end, 'LSP completion')
vis:map(I, '<C-s>', function()
  vis:command('lspc-signature-help')
end, 'Signature help')
-- stylua: ignore end
-- }}}

-- Diagnostics {{{
local severity_names = { 'ERROR', 'WARN', 'INFO', 'HINT' }

---Diagnostics published for `path` by all servers, sorted by position
---@param path string?
---@return table[]
local function file_diagnostics(path)
  local handle = path and lspc.open_files[path]
  local list = {}
  for _, server_diagnostics in pairs(handle and handle.diagnostics or {}) do
    for _, diagnostic in ipairs(server_diagnostics) do
      table.insert(list, diagnostic)
    end
  end
  table.sort(list, function(a, b)
    return a.vis_range.start < b.vis_range.start
  end)
  return list
end

---Jump to the next diagnostic of `severity` in direction `dir`, wrapping
---@param severity integer
---@param dir -1|1
---@return function
local function jump(severity, dir)
  return function()
    local win = vis.win
    local targets = {}
    for _, diagnostic in ipairs(file_diagnostics(win.file.path)) do
      if diagnostic.severity == severity then
        table.insert(targets, diagnostic.vis_range.start)
      end
    end
    if #targets == 0 then
      vis:info('No ' .. severity_names[severity] .. ' diagnostics')
      return
    end
    local first, last = 1, #targets
    if dir < 0 then
      first, last = last, first
    end
    local pos = win.selection.pos
    for _ = 1, vis.count or 1 do
      local target = targets[first]
      for i = first, last, dir do
        if (targets[i] - pos) * dir > 0 then
          target = targets[i]
          break
        end
      end
      pos = target
    end
    win.selection.pos = pos
  end
end

-- stylua: ignore start
vis:map(N, '[e', jump(1, -1), 'Go to previous diagnostic error')
vis:map(N, ']e', jump(1, 1),  'Go to next diagnostic error')
vis:map(N, '[w', jump(2, -1), 'Go to previous diagnostic warning')
vis:map(N, ']w', jump(2, 1),  'Go to next diagnostic warning')
vis:map(N, '[i', jump(3, -1), 'Go to previous diagnostic info')
vis:map(N, ']i', jump(3, 1),  'Go to next diagnostic info')
vis:map(N, '[h', jump(4, -1), 'Go to previous diagnostic hint')
vis:map(N, ']h', jump(4, 1),  'Go to next diagnostic hint')
-- stylua: ignore end

vis:map(N, 'yd', function()
  local win = vis.win
  local lnum = win.selection.line
  local messages = {}
  for _, diagnostic in ipairs(file_diagnostics(win.file.path)) do
    if diagnostic.range.start.line + 1 == lnum then
      table.insert(messages, diagnostic.message)
    end
  end
  if #messages == 0 then
    vis:info('No diagnostics on line ' .. lnum)
    return
  end
  vis.registers['+'] = { table.concat(messages, '\n') }
  vis:info('Yanked ' .. #messages .. ' diagnostic message(s)')
end, 'Yank diagnostic message on current line')

---Pick a diagnostic of the given files with fzf and jump to it
---@param paths string[]
local function pick_diagnostics(paths)
  local items = {}
  for _, path in ipairs(paths) do
    local name = #paths > 1 and util.tilde(path) .. ':' or ''
    for _, d in ipairs(file_diagnostics(path)) do
      local pos = d.range.start
      table.insert(
        items,
        string.format(
          '%s%d:%d: %s %s',
          name,
          pos.line + 1,
          pos.character + 1,
          severity_names[d.severity] or '',
          (d.message:gsub('\n', ' '))
        )
      )
    end
  end
  if #items == 0 then
    vis:info('No diagnostics')
    return
  end
  local pick = require('core.pick')
  local choice = pick.select(items, 'Diagnostics')
  if not choice then
    return
  end
  local path, lnum, col
  if #paths == 1 then
    path = paths[1]
    lnum, col = choice:match('^(%d+):(%d+):')
  else
    path, lnum, col = choice:match('^(.-):(%d+):(%d+):')
    path = path:gsub('^~', os.getenv('HOME'))
  end
  pick.open(path, tonumber(lnum), tonumber(col))
end

vis:map(N, ' d', function()
  pick_diagnostics({ vis.win.file.path })
end, 'Show document diagnostics')
vis:map(N, ' D', function()
  local paths = {}
  for path in pairs(lspc.open_files) do
    table.insert(paths, path)
  end
  table.sort(paths)
  pick_diagnostics(paths)
end, 'Show workspace diagnostics')
-- }}}

-- vim:ts=2:sw=2:sts=2:fdm=marker
