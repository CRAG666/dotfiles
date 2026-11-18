vim.g.has_ui = #vim.api.nvim_list_uis() > 0
vim.g.has_nf = vim.env.TERM ~= 'linux' and vim.env.NVIM_NF ~= nil
vim.g.snacks_animate = false
-- vim.o.shell = "/bin/nu"
vim.opt.encoding = 'utf-8'
vim.opt.fileformat = 'unix'
vim.opt.syntax = 'ON'
vim.opt.exrc = true
vim.opt.confirm = true
vim.opt.timeout = false
vim.opt.colorcolumn = '80'
vim.opt.cursorlineopt = 'number'
vim.opt.cursorline = true
vim.opt.helpheight = 10
vim.opt.showmode = false
vim.opt.mousemoveevent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true
vim.opt.pumheight = 16
vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = 'yes:1'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.smoothscroll = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.completeopt = 'menuone'
vim.opt.tabclose = 'uselast'
vim.opt.winborder = 'rounded'
-- `CursorHold` delay, which refreshes diagnostic `virtual_lines.current_line`
vim.opt.updatetime = 300

-- Defer shada reading
do
  vim.opt.shada = ''

  ---Restore 'shada' option and read from shada once
  local function rshada()
    vim.opt.shada = vim.api.nvim_get_option_info2('shada', {}).default
    pcall(vim.cmd.rshada)
  end

  require('utils.load').on_events('BufReadPre', 'opt.shada', rshada)
  require('utils.load').on_events(
    'UIEnter',
    'opt.shada',
    vim.schedule_wrap(rshada)
  )
end

-- Folding
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ''
vim.opt.foldmethod = 'indent'
vim.opt.foldopen:remove('block') -- make `{`/`}` skip over folds

-- Recognize numbered lists when formatting text and
-- continue comments on new lines
--
-- Don't auto-wrap non-comment text by default
vim.opt.formatoptions:append('normc')
vim.opt.formatoptions:remove('t')

-- Treat number as signed/unsigned based on preceding whitespaces when
-- incrementing/decrementing numbers
vim.opt.nrformats:append('blank')

-- Spell check
do
  vim.opt.spellsuggest = 'best,9'
  vim.opt.spellcapcheck = ''
  vim.opt.spelllang = 'en,es,cjk'
  vim.opt.spelloptions = 'camel'

  require('utils.load').on_events(
    'UIEnter',
    'opt.spell',
    vim.schedule_wrap(function()
      ---Buffers where spellcheck is enabled
      ---@type table<integer, true>
      local bufs = {}

      -- Windows where an ftplugin already set 'spell' are skipped below
      vim.go.spell = true

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        -- Set by ftplugins that enable 'spell' during startup, see
        -- `utils.ftplugin`
        local deferred = vim.w[win].deferred_spell
        if
          not deferred
          and require('utils.opt').spell:was_locally_set({ win = win })
        then
          goto continue
        end
        vim.api.nvim_win_call(win, function()
          local opt = deferred and vim.opt_local or vim.opt
          opt.spell = true
        end)
        bufs[vim.fn.winbufnr(win)] = true
        ::continue::
      end

      -- Restart treesitter to correctly apply `@spell` nodes
      for buf, _ in pairs(bufs) do
        if require('utils.ts').is_active(buf) then
          pcall(vim.treesitter.start, buf)
        end
      end
    end)
  )
end

-- Use histogram algorithm for diffing, generates more readable diffs in
-- situations where two lines are swapped
vim.opt.diffopt:append({
  'algorithm:histogram',
  'indent-heuristic',
  'linematch:60',
})

-- Use system clipboard
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = vim.schedule_wrap(function()
    vim.opt.clipboard:append('unnamedplus')
  end),
})

-- Align columns in quickfix window
vim.opt.quickfixtextfunc = [[v:lua.require'utils.opts'.qftf]]

vim.opt.backup = true
vim.opt.backupdir:remove('.')

vim.opt.list = true
vim.opt.listchars = {
  tab = '  ',
  trail = '·',
}
vim.opt.fillchars = {
  fold = '·',
  foldsep = ' ',
  eob = ' ',
}

if vim.g.has_nf then
  vim.opt.fillchars:append({
    foldopen = '',
    foldclose = '',
  })
else
  vim.opt.fillchars:append({
    foldopen = 'v',
    foldclose = '>',
  })
end

vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    if vim.opt.termguicolors:get() then
      vim.opt.listchars:append({ nbsp = '␣' })
      vim.opt.fillchars:append({ diff = '╱' })
    end
  end,
})

-- Netrw settings
vim.g.netrw_banner = 0
vim.g.netrw_cursor = 5
vim.g.netrw_keepdir = 0
vim.g.netrw_keepj = ''
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_liststyle = 1
vim.g.netrw_localcopydircmd = 'cp -r'

-- Fzf settings
vim.g.fzf_layout = {
  window = {
    width = 0.8,
    height = 0.8,
    pos = 'center',
  },
}
vim.env.FZF_DEFAULT_OPTS = (vim.env.FZF_DEFAULT_OPTS or '')
  .. ' --border=sharp --margin=0 --padding=0'

-- Disable plugins shipped with nvim
vim.g.loaded_2html_plugin = 0
vim.g.loaded_matchit = 0
vim.g.loaded_spellfile_plugin = 0
vim.g.loaded_tutor_mode_plugin = 0

-- Lazy-load some runtime files
vim.g.loaded_remote_plugins = 0
vim.g.loaded_python3_provider = 0

---Load runtime files, including remote plugin and (Python3) providers
---@return nil
local function load_runtime()
  vim.g.loaded_remote_plugins = nil
  vim.cmd.runtime('plugin/rplugin.vim')

  -- Nvim looks for pynvim in every python in `$PATH` synchronously (~0.5s
  -- without one) on the first `has('python3')`, e.g. in the python ftplugin.
  -- Check the first python in background, after the first redraw, and keep
  -- the provider disabled without pynvim. Spawn by full path, the child's
  -- `$PATH` lookup blocks for ~20ms with mise's long `$PATH`
  vim.schedule(function()
    local python = vim.fn.exepath('python3')
    if python == '' then
      return
    end
    vim.system(
      { python, '-c', 'import neovim' },
      {},
      vim.schedule_wrap(function(out)
        if out.code == 0 then
          vim.g.python3_host_prog = python
          vim.g.loaded_python3_provider = nil
        end
      end)
    )
  end)
end

require('utils.load').on_events(
  { require('utils.load').ft_event, 'BufReadPre', 'BufWritePost' },
  'load_runtime',
  load_runtime
)

require('utils.load').on_cmds('UpdateRemotePlugins', 'load_runtime', function()
  -- The command needs the provider right away, don't wait for the async check
  vim.g.loaded_remote_plugins = nil
  vim.g.loaded_python3_provider = nil
  vim.cmd.runtime('plugin/rplugin.vim')
end)
