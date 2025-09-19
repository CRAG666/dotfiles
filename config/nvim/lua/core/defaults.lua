-- =============================
-- General Configuration
-- =============================
local set = vim.opt

set.encoding = 'utf-8'
set.fileformat = 'unix'
set.syntax = 'ON'
set.hidden = true
set.swapfile = false
set.backup = false
set.writebackup = false
set.undofile = true
set.undodir = os.getenv('HOME') .. '/.vim/undodir'
set.undolevels = 1000
set.backupcopy = 'yes'
set.fsync = false
set.lazyredraw = false
set.splitkeep = 'screen'

-- =============================
-- User Interface
-- =============================
vim.g.has_ui = #vim.api.nvim_list_uis() > 0
vim.g.has_gui = vim.fn.has('gui_running') == 1
vim.g.has_display = vim.g.has_ui and vim.env.DISPLAY ~= nil
vim.g.has_nf = vim.env.TERM ~= 'linux' and true or false
set.signcolumn = 'yes' -- Always show the signcolumn, otherwise it would shift the text each time
set.title = true
set.termguicolors = true
set.number = true
set.relativenumber = true
set.cursorline = true
set.cursorcolumn = true
set.scrolloff = 10
set.sidescrolloff = 10
set.splitright = true
set.splitbelow = true
set.laststatus = 3
set.showtabline = 0
set.wildmenu = true
set.wildmode = 'longest:full,full'
set.winminwidth = 5 -- Minimum window width
set.cmdheight = 0
set.list = false
set.listchars = {
  eol = '↲',
  space = '␣',
  tab = '▸ ',
  trail = '▒',
  precedes = '←',
  extends = '→',
  nbsp = '␣',
}
set.smoothscroll = true
set.quickfixtextfunc = [[v:lua.require'utils.opts'.qftf]]

-- =============================
-- Text and Formatting
-- =============================
set.expandtab = true
set.shiftwidth = 4
set.softtabstop = 4
set.ts = 4
set.autoindent = true
set.copyindent = true
set.smartindent = true
set.linebreak = true
set.breakindent = true
set.textwidth = 106
set.formatoptions = 'jcroqlnt'

-- =============================
-- Search Configuration
-- =============================
set.ignorecase = true
set.smartcase = true
set.hlsearch = true
set.incsearch = true

-- =============================
-- Performance
-- =============================
set.timeoutlen = 300
set.updatetime = 500

-- =============================
-- Key Mappings
-- =============================
vim.keymap.set('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\' -- Backslash for neorg leader

-- =============================
-- Folds
-- =============================
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
set.foldexpr = "v:lua.require'utils'.ui.foldexpr()"
set.foldmethod = 'expr'
set.foldtext = ''

-- =============================
-- Clipboard and Mouse
-- =============================
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = vim.schedule_wrap(function()
    set.clipboard:append('unnamedplus')
  end),
})
set.mouse = 'a'

-- =============================
-- Diff and Git
-- =============================
set.diffopt:append({
  'algorithm:histogram',
  'indent-heuristic',
  'linematch:60',
})

-- =============================
-- Wildcards and Paths
-- =============================
set.path:remove('/usr/include')
set.path:append('**')
set.wildignore:append({
  '.git/**',
  '*.pyc',
  '*.pyo',
  '*/__pycache__/*',
  '*.beam',
  '*.swp,~*',
  '*.zip',
  '*.tar',
  '*.DS_Store',
  'node_modules/**',
  '**/bower_modules/**',
  '**/node_modules/**',
})

-- =============================
-- Colors and Highlighting
-- =============================
set.colorcolumn = '+1'
set.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}
set.hlsearch = true

-- =============================
-- Plugins and External Tools
-- =============================
set.grepprg = 'rg --vimgrep --no-heading --smart-case'
set.grepformat = '%f:%l:%c:%m'

-- =============================
-- Special Behaviors
-- =============================
set.ruler = false -- Disable the default ruler
set.inccommand = 'split' -- preview incremental substitute
set.jumpoptions = 'view'
set.joinspaces = false
set.virtualedit = 'block'
set.shiftround = true
set.smarttab = true
set.whichwrap:append('<>[]hl')
set.wrap = true
set.errorbells = true
set.shortmess:append({ W = true, I = true, c = true, C = true })
set.showmode = false

set.completeopt = { 'menuone', 'noselect', 'popup' }

-- Defer shada reading
local shada_augroup = vim.api.nvim_create_augroup('OptShada', {})

---Restore 'shada' option and read from shada once
local function rshada()
  pcall(vim.api.nvim_del_augroup_by_id, shada_augroup)

  vim.opt.shada = vim.api.nvim_get_option_info2('shada', {}).default
  pcall(vim.cmd.rshada)
end

vim.opt.shada = ''
vim.api.nvim_create_autocmd('BufReadPre', {
  group = shada_augroup,
  once = true,
  callback = rshada,
})
vim.api.nvim_create_autocmd('UIEnter', {
  group = shada_augroup,
  once = true,
  callback = vim.schedule_wrap(rshada),
})
