local set = vim.opt

set.completeopt = "menu,menuone,noselect"
set.autowrite = true
set.scrolloff = 99
set.sidescrolloff = 99
set.scrollback = 100000
set.tags = "/tmp/tags"
set.mouse = "a"
set.clipboard:append "unnamedplus"
set.splitright = true
set.splitbelow = true
set.icm = "nosplit"
set.virtualedit = "block"
set.backspace = { "indent", "eol", "start", "nostop" }
set.inccommand = "nosplit"
set.matchtime = 2
-- set.updatetime = 200
set.timeoutlen = 300
set.joinspaces = false
set.lazyredraw = false
set.hidden = true
set.diffopt = "filler,vertical,hiddenoff,linematch:60,foldcolumn:0,algorithm:minimal"
set.encoding = "utf-8"
set.fileformat = "unix"
set.formatoptions = "jcroqlnt" -- tcqj
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
set.path:remove "/usr/include"
set.path:append "**"
set.breakindent = true
set.ts = 4
set.softtabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.autoindent = true
set.ignorecase = true
set.smartcase = true
set.shiftround = true
set.smarttab = true
set.wrap = true
set.whichwrap:append "<>[]hl"
set.linebreak = true
set.textwidth = 80
set.winminwidth = 5
set.syntax = "ON"
set.termguicolors = true
set.conceallevel = 0
set.showtabline = 0
set.pumblend = 10
set.pumheight = 15
set.showmode = false
set.title = true
set.number = true
set.relativenumber = true
set.showcmd = false
set.cursorline = true
set.cursorcolumn = true
set.wildmenu = true
set.wildmode = "longest:full,full"
set.showmatch = true
set.errorbells = true
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
set.hlsearch = true
set.incsearch = true
set.smartindent = true
set.grepformat = "%f:%l:%c:%m"
set.grepprg = "rg --vimgrep --no-heading --smart-case"
set.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = "",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
set.colorcolumn = "+1"
set.foldtext = ""
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
set.fsync = false
set.swapfile = false
set.backup = false
set.undodir = os.getenv "HOME" .. "/.vim/undodir"
set.undofile = true
set.undolevels = 1000
set.writebackup = false
set.backupcopy = "yes"
set.splitkeep = "screen"
set.shortmess:append { W = true, I = true, c = true, C = true }
if vim.fn.has "nvim-0.10" == 1 then
  set.smoothscroll = true
end
