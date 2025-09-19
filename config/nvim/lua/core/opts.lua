vim.g.has_ui = #vim.api.nvim_list_uis() > 0
vim.g.has_gui = vim.fn.has('gui_running') == 1
vim.g.has_display = vim.g.has_ui and vim.env.DISPLAY ~= nil
vim.g.has_nf = vim.env.TERM ~= 'linux' and vim.env.NVIM_NF and true or false

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
vim.opt.selection = 'old'
vim.opt.tabclose = 'uselast'

-- Defer shada reading
do
  local group = vim.api.nvim_create_augroup('my.opt.shada', {})

  ---Restore 'shada' option and read from shada once
  local function rshada()
    pcall(vim.api.nvim_del_augroup_by_id, group)

    vim.opt.shada = vim.api.nvim_get_option_info2('shada', {}).default
    pcall(vim.cmd.rshada)
  end

  vim.opt.shada = ''
  vim.api.nvim_create_autocmd('BufReadPre', {
    group = group,
    once = true,
    callback = rshada,
  })
  vim.api.nvim_create_autocmd('UIEnter', {
    group = group,
    once = true,
    callback = vim.schedule_wrap(rshada),
  })
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
  vim.opt.spelllang = 'en,cjk'
  vim.opt.spelloptions = 'camel'

  local group = vim.api.nvim_create_augroup('my.opt.spell', {})

  ---Set spell check options
  ---@return nil
  local function spellcheck()
    pcall(vim.api.nvim_del_augroup_by_id, group)

    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if not require('utils.opt').spell:was_locally_set({ win = win }) then
        vim.api.nvim_win_call(win, function()
          vim.opt.spell = true
        end)
      end
    end
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    once = true,
    callback = function()
      vim.treesitter.start = (function(ts_start)
        return function(...)
          -- Ensure spell check settings are set before starting treesitter
          -- to avoid highlighting `@nospell` nodes
          spellcheck()
          vim.treesitter.start = ts_start
          return vim.treesitter.start(...)
        end
      end)(vim.treesitter.start)
    end,
  })

  vim.api.nvim_create_autocmd('UIEnter', {
    group = group,
    once = true,
    callback = vim.schedule_wrap(spellcheck),
  })
end

-- Cursor shape
vim.opt.gcr = {
  'i-c-ci-ve:blinkoff500-blinkon500-block-TermCursor',
  'n-v:block-Curosr/lCursor',
  'o:hor50-Curosr/lCursor',
  'r-cr:hor20-Curosr/lCursor',
}

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

---@param args table
---@return string[]
function _G._qftf(args)
  local qflist = args.quickfix == 1
      and vim.fn.getqflist({ id = args.id, items = 0 }).items
    or vim.fn.getloclist(args.winid, { id = args.id, items = 0 }).items

  if vim.tbl_isempty(qflist) then
    return {}
  end

  local fname_str_cache = {}
  local lnum_str_cache = {}
  local col_str_cache = {}
  local type_str_cache = {}
  local nr_str_cache = {}

  local fname_width_cache = {}
  local lnum_width_cache = {}
  local col_width_cache = {}
  local type_width_cache = {}
  local nr_width_cache = {}

  ---Traverse the qflist and get the maximum display width of the
  ---transformed string; cache the transformed string and its width
  ---in table `str_cache` and `width_cache` respectively
  ---@param trans fun(item: table): string|number
  ---@param max_width_allowed integer?
  ---@param str_cache table
  ---@param width_cache table
  ---@return integer
  local function _traverse(trans, max_width_allowed, str_cache, width_cache)
    max_width_allowed = max_width_allowed or math.huge
    local max_width_seen = 0
    for i, item in ipairs(qflist) do
      local str = tostring(trans(item))
      local width = vim.fn.strdisplaywidth(str)
      str_cache[i] = str
      width_cache[i] = width
      if width > max_width_seen then
        max_width_seen = width
      end
    end
    return math.min(max_width_allowed, max_width_seen)
  end

  ---@param item table
  ---@return string
  local function _fname_trans(item)
    local bufnr = item.bufnr
    local module = item.module
    local filename = item.filename
    return module and module ~= '' and module
      or filename and filename ~= '' and filename
      or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':~:.')
  end

  ---@param item table
  ---@return string|integer
  local function _lnum_trans(item)
    if item.lnum == item.end_lnum or item.end_lnum == 0 then
      return item.lnum
    end
    return string.format('%s-%s', item.lnum, item.end_lnum)
  end

  ---@param item table
  ---@return string|integer
  local function _col_trans(item)
    if item.col == item.end_col or item.end_col == 0 then
      return item.col
    end
    return string.format('%s-%s', item.col, item.end_col)
  end

  local type_sign_map = {
    E = 'ERROR',
    W = 'WARN',
    I = 'INFO',
    N = 'HINT',
  }

  ---@param item table
  ---@return string
  local function _type_trans(item)
    -- Sometimes `item.type` will contain unprintable characters,
    -- e.g. items in the qflist of `:helpg vim`
    local type = (type_sign_map[item.type] or item.type):gsub('[^%g]', '')
    return type == '' and '' or ' ' .. type
  end

  ---@param item table
  ---@return string
  local function _nr_trans(item)
    return item.nr <= 0 and '' or ' ' .. item.nr
  end

  -- stylua: ignore start
  local max_width = math.ceil(vim.go.columns / 2)
  local fname_width = _traverse(_fname_trans, max_width, fname_str_cache, fname_width_cache)
  local lnum_width = _traverse(_lnum_trans, max_width, lnum_str_cache, lnum_width_cache)
  local col_width = _traverse(_col_trans, max_width, col_str_cache, col_width_cache)
  local type_width = _traverse(_type_trans, max_width, type_str_cache, type_width_cache)
  local nr_width = _traverse(_nr_trans, max_width, nr_str_cache, nr_width_cache)
  -- stylua: ignore end

  local lines = {} ---@type string[]
  local format_str = vim.go.termguicolors and '%s %s:%s%s%s %s'
    or '%s│%s:%s%s%s│ %s'

  local function _fill_item(idx, item)
    local fname = fname_str_cache[idx]
    local fname_cur_width = fname_width_cache[idx]

    if item.lnum == 0 and item.col == 0 and item.text == '' then
      table.insert(lines, fname)
      return
    end

    local lnum = lnum_str_cache[idx]
    local col = col_str_cache[idx]
    local type = type_str_cache[idx]
    local nr = nr_str_cache[idx]

    local lnum_cur_width = lnum_width_cache[idx]
    local col_cur_width = col_width_cache[idx]
    local type_cur_width = type_width_cache[idx]
    local nr_cur_width = nr_width_cache[idx]

    table.insert(
      lines,
      string.format(
        format_str,
        -- Do not use `string.format()` here because it only allows
        -- at most 99 characters for alignment and alignment is
        -- based on byte length instead of display length
        fname .. string.rep(' ', fname_width - fname_cur_width),
        string.rep(' ', lnum_width - lnum_cur_width) .. lnum,
        col .. string.rep(' ', col_width - col_cur_width),
        type .. string.rep(' ', type_width - type_cur_width),
        nr .. string.rep(' ', nr_width - nr_cur_width),
        item.text
      )
    )
  end

  for i, item in ipairs(qflist) do
    _fill_item(i, item)
  end

  return lines
end

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
vim.g.loaded_gzip = 0
vim.g.loaded_matchit = 0
vim.g.loaded_spellfile_plugin = 0
vim.g.loaded_tar = 0
vim.g.loaded_tarPlugin = 0
vim.g.loaded_tutor_mode_plugin = 0
vim.g.loaded_zip = 0
vim.g.loaded_zipPlugin = 0

----Return function to lazy-load runtime files
----@param runtime string
----@param flag string
----@return function
local function load_runtime(runtime, flag)
  return function()
    if vim.g[flag] ~= nil and vim.g[flag] ~= 0 then
      return
    end
    vim.g[flag] = nil
    vim.cmd.runtime(runtime)
  end
end

require('utils.load').on_events(
  {
    'FileType',
    'BufNew',
    'BufWritePost',
    'BufReadPre',
    { event = 'CmdUndefined', pattern = 'UpdateRemotePlugins' },
  },
  'rplugin/rplugin.nvim',
  load_runtime('rplugin/rplugin.vim', 'loaded_remote_plugins')
)

require('utils.load').on_events(
  {
    { event = 'FileType', pattern = 'python' },
    { event = 'BufNew', pattern = { '*.py', '*.ipynb' } },
    { event = 'BufEnter', pattern = { '*.py', '*.ipynb' } },
    { event = 'BufWritePost', pattern = { '*.py', '*.ipynb' } },
    { event = 'BufReadPre', pattern = { '*.py', '*.ipynb' } },
    { event = 'CmdUndefined', pattern = 'UpdateRemotePlugins' },
  },
  'provider/python3.vim',
  load_runtime('provider/python3.vim', 'loaded_python3_provider')
)
