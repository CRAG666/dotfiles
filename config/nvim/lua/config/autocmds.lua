--   __,
--  /  |       _|_  _   _           _|
-- |   |  |  |  |  / \_/   /|/|/|  / |
--  \_/\_/ \/|_/|_/\_/ \__/ | | |_/\/|_/
--

---@param group string
---@vararg { [1]: string|string[], [2]: vim.api.keyset.create_autocmd }
---@return nil
local function augroup(group, ...)
  local id = vim.api.nvim_create_augroup(group, {})
  for _, a in ipairs({ ... }) do
    a[2].group = id
    vim.api.nvim_create_autocmd(unpack(a))
  end
end

-- This can only handle cases where the big file exists on disk before opening
-- it but not big buffers without corresponding files
-- TODO: Handle big buffers without corresponding files
do
  vim.g.bigfile_max_size = vim.g.bigfile_max_size or 1048576
  vim.g.bigfile_max_lines = vim.g.bigfile_max_lines or 32768

  augroup('BigFile', {
    'BufReadPre',
    {
      desc = 'Detect big files.',
      callback = function(args)
        local stat = vim.uv.fs_stat(args.match)
        if stat and stat.size > vim.g.bigfile_max_size then
          vim.b[args.buf].bigfile = true
        end
      end,
    },
  }, {
    { 'BufEnter', 'TextChanged', 'CmdWinEnter' },
    {
      desc = 'Detect big files.',
      callback = function(args)
        local buf = args.buf
        if vim.b[buf].bigfile then
          return
        end

        if vim.api.nvim_buf_line_count(buf) > vim.g.bigfile_max_lines then
          vim.b[buf].bigfile = true
        end
      end,
    },
  }, {
    'FileType',
    {
      once = true,
      desc = 'Prevent treesitter and LSP from attaching to big files.',
      callback = function(args)
        vim.api.nvim_del_autocmd(args.id)

        local ts_get_parser = vim.treesitter.get_parser
        local ts_foldexpr = vim.treesitter.foldexpr
        local lsp_start = vim.lsp.start

        ---@diagnostic disable-next-line: duplicate-set-field
        function vim.treesitter.get_parser(buf, ...)
          if buf == nil or buf == 0 then
            buf = vim.api.nvim_get_current_buf()
          end
          -- HACK: Getting parser for a big buffer can freeze nvim, so return a
          -- fake parser on an empty buffer if current buffer is big
          if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].bigfile then
            return vim.treesitter._create_parser(
              vim.api.nvim_create_buf(false, true),
              vim.treesitter.language.get_lang(vim.bo.ft) or vim.bo.ft
            )
          end
          return ts_get_parser(buf, ...)
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        function vim.treesitter.foldexpr(...)
          if vim.b.bigfile then
            return
          end
          return ts_foldexpr(...)
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        function vim.lsp.start(...)
          if vim.b.bigfile then
            return
          end
          return lsp_start(...)
        end
      end,
    },
  }, {
    'BufReadPre',
    {
      desc = 'Disable options in big files.',
      callback = function(args)
        local buf = args.buf
        if not vim.b[buf].bigfile then
          return
        end
        vim.api.nvim_buf_call(buf, function()
          vim.opt_local.spell = false
          vim.opt_local.swapfile = false
          vim.opt_local.undofile = false
          vim.opt_local.breakindent = false
          vim.opt_local.foldmethod = 'manual'
        end)
      end,
    },
  }, {
    { 'BufEnter', 'TextChanged', 'FileType' },
    {
      desc = 'Stop treesitter in big files.',
      callback = function(args)
        local buf = args.buf
        if vim.b[buf].bigfile and require('utils.ts').is_active(buf) then
          vim.treesitter.stop(buf)
          vim.bo[buf].syntax = vim.filetype.match({ buf = buf })
            or vim.bo[buf].bt
        end
      end,
    },
  })
end

augroup('YankHighlight', {
  'TextYankPost',
  {
    desc = 'Highlight the selection on yank.',
    callback = function()
      pcall(vim.highlight.on_yank, {
        higroup = 'Visual',
        timeout = 200,
      })
    end,
  },
})

augroup('WinCloseJmp', {
  'WinClosed',
  {
    nested = true,
    desc = 'Jump to last accessed window on closing the current one.',
    command = "if expand('<amatch>') == win_getid() | wincmd p | endif",
  },
})

augroup('LastPosJmp', {
  'BufReadPost',
  {
    desc = 'Last position jump.',
    callback = function(args)
      vim.api.nvim_create_autocmd('FileType', {
        once = true,
        buffer = args.buf,
        callback = function(i)
          local ft = vim.bo[i.buf].ft
          if ft ~= 'gitcommit' and ft ~= 'gitrebase' then
            vim.cmd.normal({
              'g`"zvzz',
              bang = true,
              mods = { emsg_silent = true },
            })
          end
        end,
      })
    end,
  },
})

do
  ---Set cwd to `root_dir` for all windows for given buffer `buf`
  ---@param buf integer
  ---@param root_dir string
  local function buf_lcd(buf, root_dir)
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    if vim.b[buf]._root_dir ~= root_dir then
      vim.b[buf]._root_dir = root_dir
    end

    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.api.nvim_win_call(win, function()
        -- Prevent unnecessary directory change, which triggers
        -- DirChanged autocmds that may update winbar unexpectedly
        if root_dir == vim.fn.getcwd(0) then
          return
        end
        pcall(vim.cmd.lcd, {
          root_dir,
          mods = {
            silent = true,
            emsg_silent = true,
          },
        })
      end)
    end
  end

  augroup('AutoCwd', {
    'BufEnter',
    {
      desc = 'Automatically change local current directory.',
      nested = true,
      callback = function(args)
        local file = args.file
        local buf = args.buf

        local root_dir_cached = vim.b[buf]._root_dir
        if root_dir_cached and vim.fn.isdirectory(root_dir_cached) == 1 then
          buf_lcd(buf, root_dir_cached)
          return
        end

        -- Don't automatically change cwd in special buffers, e.g. help buffers
        -- or oil preview buffers
        if file == '' or vim.bo[buf].bt ~= '' then
          return
        end

        local fs_utils = require('utils.fs')
        local root_dir = fs_utils.root(file, fs_utils.root_markers)

        if
          not root_dir
          or fs_utils.is_home_dir(root_dir)
          or fs_utils.is_root_dir(root_dir)
        then
          root_dir = vim.fs.dirname(file)
        end

        if not root_dir then
          return
        end

        buf_lcd(buf, root_dir)
      end,
    },
  })
end

augroup('QuickFixAutoOpen', {
  'QuickFixCmdPost',
  {
    desc = 'Open quickfix window if there are results.',
    callback = function(args)
      if #vim.fn.getqflist() > 1 then
        vim.schedule(vim.cmd[args.match:find('^l') and 'lwindow' or 'cwindow'])
      end
    end,
  },
})

do
  local win_ratio = {}
  augroup('KeepWinRatio', {
    { 'VimResized', 'TabEnter' },
    {
      desc = 'Keep window ratio after resizing nvim.',
      callback = function()
        vim.g._vim_resized = true
        vim.api.nvim_create_autocmd('WinResized', {
          once = true,
          callback = function()
            vim.g._vim_resized = nil
          end,
        })
        require('utils.win').restore_ratio(win_ratio)
      end,
    },
  }, {
    'WinResized',
    {
      desc = 'Record window ratio.',
      callback = function()
        -- Don't record ratio if window resizing is caused by vim resizing
        if vim.g._vim_resized then
          return
        end
        require('utils.win').save_ratio(win_ratio, vim.v.event.windows)
      end,
    },
  }, {
    { 'TermOpen', 'WinNew' },
    {
      desc = 'Record window ratio.',
      callback = function()
        require('utils.win').save_ratio(win_ratio, vim.api.nvim_list_wins())
      end,
    },
  })
end

-- Fix bug where windows with fixed height are resized after opening/closing
-- windows with winbar attached, see https://github.com/neovim/neovim/issues/30955
--
-- This does not fix windows with fixed height being resized on `<C-w>=` if
-- multiple horizontal splits are opened/closed after the creation of the
-- fixed-height window
do
  local win_heights = {}

  ---Save heights for fixed-height widows
  local function win_save_fixed_heights()
    require('utils.win').save_heights(
      win_heights,
      vim
        .iter(vim.api.nvim_tabpage_list_wins(0))
        :filter(function(win)
          return vim.wo[win].winfixheight
        end)
        :totable()
    )
  end

  augroup('FixWinFixHeightWithWinBar', {
    { 'WinNew', 'WinClosed' },
    {
      desc = 'Save heights for windows with a fixed height.',
      callback = function()
        -- Set flag to indicate that a new window is created or an existing
        -- window is closed, so that we can distinguish between manual resizing
        -- and resizing due to window creation/deletion
        vim.g._win_list_changed = true
        vim.schedule(function()
          vim.g._win_list_changed = nil
        end)

        -- Schedule to wait for `winfixheight` to be set after opening a new
        -- window
        vim.schedule(win_save_fixed_heights)
      end,
    },
  }, {
    'OptionSet',
    {
      desc = 'Save heights for windows with a fixed height.',
      pattern = 'winfixheight',
      callback = win_save_fixed_heights,
    },
  }, {
    'WinResized',
    {
      desc = 'Restore heights for windows with a fixed height.',
      callback = function()
        -- Update window height instead of restoring it on manual resizing,
        -- else the fixed-height window will be restored to height before the
        -- manual resizing after win open/close
        if not vim.g._win_list_changed then
          win_save_fixed_heights()
          return
        end
        require('utils.win').restore_heights(win_heights)
      end,
    },
  }, {
    'FileType',
    {
      desc = 'Set quickfix window initial height.',
      pattern = 'qf',
      callback = function(args)
        -- Quickfix window height can be incorrectly set to a value larger
        -- than 10 (the default value) if there's vertical splits with winbar
        -- attached above the quickfix window
        vim.api.nvim_win_set_height(vim.fn.bufwinid(args.buf), 10)
      end,
    },
  })
end

augroup('FixCmdLineIskeyword', {
  'CmdLineEnter',
  {
    desc = 'Have consistent &iskeyword and &lisp in Ex command-line mode.',
    pattern = '[:>/?=@]',
    callback = function(args)
      -- Don't reset 'iskeyword' and 'lisp' in insert or append command-line
      -- mode ('-'): if we are inserting into a lisp file, we want to have the
      -- same behavior as in insert mode
      vim.g._isk_lisp_buf = args.buf
      vim.g._isk_save = vim.bo[args.buf].isk
      vim.g._lisp_save = vim.bo[args.buf].lisp
      vim.cmd.setlocal('isk&')
      vim.cmd.setlocal('lisp&')
    end,
  },
}, {
  'CmdLineLeave',
  {
    desc = 'Restore &iskeyword after leaving command-line mode.',
    pattern = '[:>/?=@]',
    callback = function()
      if
        vim.g._isk_lisp_buf
        and vim.api.nvim_buf_is_valid(vim.g._isk_lisp_buf)
        and vim.g._isk_save ~= vim.b[vim.g._isk_lisp_buf].isk
      then
        vim.bo[vim.g._isk_lisp_buf].isk = vim.g._isk_save
        vim.bo[vim.g._isk_lisp_buf].lisp = vim.g._lisp_save
        vim.g._isk_save = nil
        vim.g._lisp_save = nil
        vim.g._isk_lisp_buf = nil
      end
    end,
  },
})

do
  ---Set default value for `hl-NormalSpecial`
  local function set_default_hlgroups()
    local hl = require('utils.hl')
    local blended = hl.blend('Normal', 'CursorLine')
    hl.set_default(0, 'NormalSpecial', blended)
  end

  augroup('SpecialBufHl', {
    { 'BufEnter', 'BufNew', 'FileType', 'TermOpen' },
    {
      desc = 'Set background color for special buffers.',
      -- Schedule for window to open for the newly created special buffer
      callback = vim.schedule_wrap(function(args)
        local buf = args.buf
        if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].bt == '' then
          return
        end
        -- Current window isn't necessarily the window of the buffer that
        -- triggered the event, use `bufwinid()` to get the first window of
        -- the triggering buffer. We can also use `win_findbuf()` to get all
        -- windows that display the triggering buffer, but it is slower and using
        -- `bufwinid()` is enough for our purpose.
        local winid = vim.fn.bufwinid(buf)
        if winid == -1 then
          return
        end
        local wintype = vim.fn.win_gettype(winid)
        if wintype == 'popup' or wintype == 'autocmd' then
          return
        end
        vim.api.nvim_win_call(winid, function()
          vim.opt_local.winhighlight:append({
            Normal = 'NormalSpecial',
            EndOfBuffer = 'NormalSpecial',
          })
        end)
      end),
    },
  }, {
    'ColorScheme',
    {
      desc = 'Set special buffer normal hl.',
      callback = set_default_hlgroups,
    },
  }, {
    'OptionSet',
    {
      desc = 'Set special buffer normal hl.',
      pattern = 'background',
      callback = set_default_hlgroups,
    },
  })
end

do
  ---Check if a window is normal (has empty win type)
  ---@param win integer
  ---@return boolean
  local function win_is_normal(win)
    return vim.fn.win_gettype(win) == ''
  end

  ---Get list of normal windows in given tabpage
  ---@param tab integer tabpage id
  ---@return integer[]
  local function tabpage_list_normal_wins(tab)
    return vim
      .iter(vim.api.nvim_tabpage_list_wins(tab))
      :filter(win_is_normal)
      :totable()
  end

  augroup('SessionWipeEmptyBufs', {
    'SessionLoadPost',
    {
      desc = 'Wipe empty buffers after loading session.',
      nested = true,
      callback = function()
        local whitelist = {} ---@type table<integer, true>

        -- Don't wipe out buffers in tabpages that shows <= 1 valid buffers, else
        -- the tabpage will be closed or the layout will change
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          local buf = nil ---@type integer?

          for _, win in ipairs(tabpage_list_normal_wins(tab)) do
            local win_buf = vim.api.nvim_win_get_buf(win)
            buf = buf or win_buf
            if buf ~= win_buf then -- second buf in tabpage found
              goto continue
            end
          end

          if buf then
            whitelist[buf] = true
          end
          ::continue::
        end

        -- Wipe out invalid buffers
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if whitelist[buf] or not require('utils.buf').is_empty(buf) then
            goto continue
          end
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname:match('://') then
            goto continue
          end
          vim.uv.fs_stat(bufname, function(err, stat)
            if err or not stat then
              pcall(vim.api.nvim_buf_delete, buf, {})
            end
          end)
          ::continue::
        end
      end,
    },
  })
end

augroup('WritingAssistant', {
  'FileType',
  {
    desc = 'Writing Assistant',
    pattern = {
      'tex',
      'latex',
      'text',
      'txt',
      'markdown',
      'md',
      'org',
      'pandoc',
      'norg',
      'quarto',
    },
    callback = function()
      vim.keymap.set(
        'n',
        '<leader>fa',
        require('modules.writing_assistant').tags,
        { noremap = true, silent = true, buffer = true }
      )
    end,
  },
})

augroup('CursorLine', {
  { 'InsertLeave', 'WinEnter' },
  {
    pattern = '*',
    command = 'set cursorline',
  },
})

vim.api.nvim_set_hl(0, 'TerminalCursorShape', { underline = true })
augroup('TerminalCursorShape', {
  'TermEnter',
  {
    callback = function()
      vim.cmd([[setlocal winhighlight=TermCursor:TerminalCursorShape]])
    end,
  },
})

augroup('BufferConfig', {
  'BufWritePre',
  {
    command = [[%s/\s\+$//e]],
  },
}, {
  'BufEnter',
  {
    command = [[let @/=""]],
  },
}, {
  'BufEnter',
  {
    command = 'silent! lcd %:p:h',
  },
}, {
  { 'BufRead', 'BufEnter' },
  {
    pattern = '*.tex',
    command = [[set filetype=tex]],
  },
})

augroup('EasyQuit', {
  'FileType',
  {
    pattern = 'man',
    command = [[nnoremap <buffer><silent> q :quit<CR>]],
  },
}, {
  'FileType',
  {
    pattern = 'nvim-pack',
    command = [[nnoremap <buffer><silent> q :quit<CR>]],
  },
})

-- Use vertical splits for help windows
augroup('HelpConfig', {
  'FileType',
  {
    pattern = 'help',
    callback = function()
      vim.bo.bufhidden = 'unload'
      vim.cmd.wincmd('L')
      vim.cmd.wincmd('=')
    end,
  },
})
