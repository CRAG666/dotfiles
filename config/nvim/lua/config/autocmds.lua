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
  for _, a in ipairs { ... } do
    a[2].group = id
    autocmd(unpack(a))
  end
end

augroup("BigFileSettings", {
  "BufReadPre",
  {
    desc = "Set settings for large files.",
    callback = function(info)
      vim.b.bigfile = false
      local stat = vim.uv.fs_stat(info.match)
      if stat and stat.size > 1048576 then
        vim.b.bigfile = true
        vim.opt_local.spell = false
        vim.opt_local.swapfile = false
        vim.opt_local.undofile = false
        vim.opt_local.breakindent = false
        vim.opt_local.colorcolumn = ""
        vim.opt_local.statuscolumn = ""
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.winbar = ""
        vim.opt_local.syntax = ""
        autocmd("BufReadPost", {
          once = true,
          buffer = info.buf,
          callback = function()
            vim.opt_local.syntax = ""
            return true
          end,
        })
      end
    end,
  },
})

augroup("YankHighlight", {
  "TextYankPost",
  {
    desc = "Highlight the selection on yank.",
    callback = function()
      pcall(vim.highlight.on_yank, {
        higroup = "Visual",
        timeout = 200,
      })
    end,
  },
})

augroup("CursorLine", {
  { "InsertLeave", "WinEnter" },
  { pattern = "*", command = "set cursorline" },
})

augroup("CursorLine", {
  { "InsertLeave", "WinEnter" },
  {
    pattern = "*",
    command = "set cursorline",
  },
})

-- Use vertical splits for help windows
augroup("HelpConfig", {
  "FileType",
  {
    pattern = "help",
    callback = function()
      vim.bo.bufhidden = "unload"
      vim.cmd.wincmd "L"
      vim.cmd.wincmd "="
    end,
  },
})

-- go to last loc when opening a buffer
augroup("LastLoc", {
  "BufReadPost",
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

vim.api.nvim_set_hl(0, "TerminalCursorShape", { underline = true })
augroup("TerminalCursorShape", {
  "TermEnter",
  {
    callback = function()
      vim.cmd [[setlocal winhighlight=TermCursor:TerminalCursorShape]]
    end,
  },
})

augroup("BufferConfig", {
  "BufWritePre",
  {
    command = [[%s/\s\+$//e]],
  },
}, {
  "BufEnter",
  {
    command = [[let @/=""]],
  },
}, {
  "BufEnter",
  {
    command = "silent! lcd %:p:h",
  },
}, {
  "BufEnter",
  {
    command = [[set formatoptions-=cro]],
  },
}, {
  { "BufRead", "BufEnter" },
  {
    pattern = "*.tex",
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

augroup("ManConfig", {
  "FileType",
  {
    pattern = "man",
    command = [[nnoremap <buffer><silent> q :quit<CR>]],
  },
})
