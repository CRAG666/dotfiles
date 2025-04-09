--   __,
--  /  |       _|_  _   _           _|
-- |   |  |  |  |  / \_/   /|/|/|  / |
--  \_/\_/ \/|_/|_/\_/ \__/ | | |_/\/|_/
--

local cmd = vim.cmd

local autocmd = vim.api.nvim_create_autocmd
local groupid = vim.api.nvim_create_augroup

---@param group string
---@vararg { [1]: string|string[], [2]: vim.api.keyset.create_autocmd }
---@return nil
local function augroup(group, ...)
  local id = groupid(group, {})
  for _, a in ipairs({ ... }) do
    a[2].group = id
    autocmd(unpack(a))
  end
end

-- This can only handle cases where the big file exists on disk before opening
-- it but not big buffers without corresponding files
-- TODO: Handle big buffers without corresponding files
augroup('BigFile', {
  'BufReadPre',
  {
    desc = 'Detect big files.',
    callback = function(info)
      vim.g.bigfile_max_size = vim.g.bigfile_max_size or 1048576

      local stat = vim.uv.fs_stat(info.match)
      if stat and stat.size > vim.g.bigfile_max_size then
        vim.b[info.buf].bigfile = true
      end
    end,
  },
}, {
  { 'BufEnter', 'TextChanged' },
  {
    desc = 'Detect big files.',
    callback = function(info)
      vim.g.bigfile_max_lines = vim.g.bigfile_max_lines or 32768

      local buf = info.buf
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
    callback = function(info)
      vim.api.nvim_del_autocmd(info.id)

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

      return true
    end,
  },
}, {
  'BufReadPre',
  {
    desc = 'Disable options in big files.',
    callback = function(info)
      local buf = info.buf
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
    callback = function(info)
      local buf = info.buf
      if vim.b[buf].bigfile and require('utils.ts').hl_is_active(buf) then
        vim.treesitter.stop(buf)
        vim.bo[buf].syntax = vim.filetype.match({ buf = buf })
          or vim.bo[buf].bt
      end
    end,
  },
})

augroup('YankHighlight', {
  'TextYankPost',
  {
    desc = 'Highlight the selection on yank.',
    callback = function()
      pcall(vim.hl.on_yank, {
        higroup = 'Visual',
        timeout = 200,
      })
    end,
  },
})

augroup('LspClearGroup', {
  'VimLeavePre',
  {
    desc = 'Detener todos los servidores LSP al cerrar Neovim',
    callback = function()
      local active_clients = vim.lsp.get_active_clients()
      for _, client in ipairs(active_clients) do
        vim.lsp.stop_client(client.id)
      end
      vim.diagnostic.reset()
      vim.notify(
        'Todos los servidores LSP han sido detenidos',
        vim.log.levels.INFO
      )
    end,
  },
})

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
  { pattern = '*', command = 'set cursorline' },
})

augroup('CursorLine', {
  { 'InsertLeave', 'WinEnter' },
  {
    pattern = '*',
    command = 'set cursorline',
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

-- go to last loc when opening a buffer
augroup('LastLoc', {
  'BufReadPost',
  {
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local lcount = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  },
})

-- Auto toggle hlsearch
-- local ns = vim.api.nvim_create_namespace "toggle_hlsearch"
-- local function toggle_hlsearch(char)
--   if vim.fn.mode() == "n" then
--     local keys = { "<CR>", "n", "N", "*", "#", "?", "/" , "nzzzv", "Nzzzv"}
--     local new_hlsearch = vim.tbl_contains(keys, vim.fn.keytrans(char))
--
--     if vim.opt.hlsearch:get() ~= new_hlsearch then
--       vim.opt.hlsearch = new_hlsearch
--     end
--   end
-- end
-- vim.on_key(toggle_hlsearch, ns)

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

-- don't auto comment new line

-- autocmd("CursorHold", {
--   buffer = bufnr,
--   callback = function()
--     local opts = {
--       focusable = false,
--       close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
--       border = "rounded",
--       source = "always",
--       prefix = " ",
--       scope = "cursor",
--     }
--     vim.diagnostic.open_float(nil, opts)
--   end,
-- })

augroup('ManConfig', {
  'FileType',
  {
    pattern = 'man',
    command = [[nnoremap <buffer><silent> q :quit<CR>]],
  },
})

augroup('QuickFixAutoOpen', {
  'QuickFixCmdPost',
  {
    desc = 'Open quickfix window if there are results.',
    callback = function(info)
      if #vim.fn.getqflist() > 1 then
        vim.schedule(vim.cmd[info.match:find('^l') and 'lwindow' or 'cwindow'])
      end
    end,
  },
})
