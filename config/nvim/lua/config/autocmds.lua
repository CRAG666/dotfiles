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
      local active_clients = vim.lsp.get_clients()
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
