--   __,
--  /  |       _|_  _   _           _|
-- |   |  |  |  |  / \_/   /|/|/|  / |
--  \_/\_/ \/|_/|_/\_/ \__/ | | |_/\/|_/
--

local cmd = vim.cmd
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup("mnv_" .. name, { clear = true })
end

-- See `:help vim.highlight.on_yank()`
local highlight_group = augroup "YankHighlight"
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank { timeout = 100 }
  end,
  group = highlight_group,
  pattern = "*",
})

-- show cursor line only in active window
cursorGrp = augroup "CursorLine"
autocmd({ "InsertLeave", "WinEnter" }, { pattern = "*", command = "set cursorline", group = cursorGrp })

-- Use vertical splits for help windows
autocmd("FileType", {
  group = augroup "vertical_help",
  pattern = "help",
  callback = function()
    vim.bo.bufhidden = "unload"
    vim.cmd.wincmd "L"
    vim.cmd.wincmd "="
  end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
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
autocmd("TermEnter", {
  callback = function()
    vim.cmd [[setlocal winhighlight=TermCursor:TerminalCursorShape]]
  end,
})

-- Delete spaces
autocmd("BufWritePre", { command = [[%s/\s\+$//e]] })

autocmd("BufEnter", { command = [[let @/=""]] })

-- Pwd in currente buffer
autocmd("BufEnter", { command = "silent! lcd %:p:h" })

-- don't auto comment new line
autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

autocmd("FileType", { pattern = "man", command = [[nnoremap <buffer><silent> q :quit<CR>]] })

autocmd({ "BufRead", "BufEnter" }, { pattern = "*.tex", command = [[set filetype=tex]] })

autocmd("CursorHold", {
  buffer = bufnr,
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always",
      prefix = " ",
      scope = "cursor",
    }
    vim.diagnostic.open_float(nil, opts)
  end,
})
vim.filetype.add {
  pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
}

vim.filetype.add {
  pattern = { ["zathurarc"] = "zathurarc" },
}

vim.filetype.add {
  pattern = { [".*%.rasi"] = "rasi" },
}
