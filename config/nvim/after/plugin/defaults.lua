local set = vim.opt

--  Basic config
set.autowrite = true -- enable auto write
set.scrolloff = 8 -- Lines of context
set.scrollback = 100000
set.sidescrolloff = 8
set.tags = "/tmp/tags"

set.mouse = "a"
-- clipboard
set.clipboard:append "unnamedplus"
set.splitright = true
set.splitbelow = true
set.icm = "nosplit"
set.virtualedit = "block"
-- set.virtualedit = "onemore"
set.backspace = { "indent", "eol", "start", "nostop" } -- Better backspace.
-- sow preview command
set.inccommand = "nosplit"
set.matchtime = 2
-- set.updatetime = 40
set.updatetime = 200
set.timeoutlen = 300
set.joinspaces = false -- No double spaces with join after a dot

-- speed up
set.lazyredraw = false

-- Tricks
set.hidden = true

set.diffopt = "filler,vertical,hiddenoff,linematch:60,foldcolumn:0,algorithm:minimal"

-- Format options
set.encoding = "utf-8"
set.fileformat = "unix"
set.formatoptions = "jqlnt" -- tcqj
set.errorformat:append "%f|%l col %c|%m"
set.wildignore:append {
  ".git/**",
  "*.pyc",
  "*.pyc",
  "*.pyo",
  "*/__pycache__/*",
  "*.beam",
  "*.swp,~*",
  "*.zip",
  "*.tar",
  "*.DS_Store,**/",
  "node_modules/**",
  "**/bower_modules/**",
  "**/node_modules/**",
}

-- Better search
set.path:remove "/usr/include"
set.path:append "**"

-- Spaces & Tabsset

set.autoindent = true
set.breakindent = true
set.expandtab = true
set.tabstop = 2
set.shiftround = true
set.shiftwidth = 2
set.softtabstop = -1
set.smarttab = true

-- Text line
set.wrap = true
set.whichwrap:append "<>[]hl"
set.linebreak = true
set.textwidth = 80

-- UI Config
set.syntax = "ON" -- str:  Allow syntax highlighting
set.termguicolors = true
set.conceallevel = 0 -- Hide * markup for bold and italic
set.showtabline = 0
set.pumblend = 10 -- Popup blend
set.pumheight = 12 -- Maximum number of entries in a popup
set.showmode = false
set.title = true
set.number = true
set.relativenumber = true
set.showcmd = false
set.cursorline = true
set.cursorcolumn = true
set.wildmenu = true
set.wildmode = "longest:full,full" -- Command-line completion mode
set.showmatch = true
set.errorbells = true
-- set.signcolumn = "yes:1"
set.signcolumn = "auto:1"
set.listchars = {
  eol = "↲",
  space = "␣",
  tab = "▸ ",
  trail = "▒",
  precedes = "←",
  extends = "→",
  nbsp = "␣",
}
set.list = false
set.laststatus = 3
set.cmdheight = 0

-- Search
set.hlsearch = false
set.incsearch = true
set.ignorecase = true
set.smartcase = true
set.smartindent = true
set.grepformat = "%f:%l:%c:%m"
set.grepprg = "rg --vimgrep --no-heading --smart-case"

-- Folding

-- set.foldnestmax = 0
vim.o.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldcolumn = "auto:1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
-- vim.o.fillchars = {
--   eob = "",
--   fold = "",
--   foldopen = "",
--   foldsep = "",
--   foldclose = "",
-- }

-- Backup
set.fsync = false
set.swapfile = false
set.backup = false
set.undodir = os.getenv "HOME" .. "/.vim/undodir"
set.undofile = true
set.undolevels = 1000
set.writebackup = false
set.backupcopy = "yes"

-- vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
-- vim.opt.spelllang = { "en" }

set.splitkeep = "screen"
set.shortmess:append { W = true, I = true, c = true, C = true }
-- set.numberwidth = 3
-- set.statuscolumn =
vim.cmd "filetype plugin indent on"
vim.cmd.colorscheme "catppuccin"
