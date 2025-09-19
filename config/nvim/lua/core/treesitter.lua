local ts = require('utils.ts')

-- Async parsing causes tons of issues, including invalid tree in insert mode
-- (which affects snippet region check), invalid range after deletion, etc.
-- e.g. https://github.com/neovim/neovim/issues/35814
vim.g._ts_force_sync_parsing = true

-- Fix treesitter bug: when `vim.treesitter.start/stop` is called with a
-- different `buf` from current buffer, it can affect current buffer's
-- language tree
-- TODO: report to upstream
local function ts_buf_call_wrap(cb)
  return function(buf, ...)
    if buf and not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    local args = { ... }
    vim.api.nvim_buf_call(buf or 0, function()
      cb(buf, unpack(args))
    end)
  end
end

vim.treesitter.start = ts_buf_call_wrap(vim.treesitter.start)
vim.treesitter.stop = ts_buf_call_wrap(vim.treesitter.stop)

---Enable treesitter highlighting for given buffer
---@param buf integer
local function enable_ts_hl(buf)
  if
    -- Don't re-enable in the same buffer, else buffers loaded from session
    -- can have blank highlighting
    not ts.is_active(buf)
    -- Don't enable treesitter highlighting if buffer is a command window
    -- vimscript buffer as it can get very long over time and make treesitter
    -- very slow
    or vim.iter(vim.fn.win_findbuf(buf)):any(function(win)
      return vim.fn.win_gettype(win) == 'command'
    end)
  then
    return
  end
  pcall(vim.treesitter.start, buf)
end

-- Automatically start treesitter highlighting for buffers
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  enable_ts_hl(buf)
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('my.ts.auto_start', {}),
  desc = 'Automatically start treesitter highlighting for buffers.',
  callback = function(args)
    enable_ts_hl(args.buf)
  end,
})

---Enable treesitter folding for given buffer if fold expr and method are unset
---@param buf integer
local function enable_ts_folding(buf)
  if not ts.is_active(buf) then
    return
  end

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    local wo = vim.wo[win][0]
    if wo.foldexpr ~= '0' then
      goto continue
    end
    wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

    -- Default `foldmethod` is 'manual', set to 'indent' in `core.opts`
    -- Prefer treesitter folding over indent folding
    if wo.foldmethod ~= 'manual' and wo.foldmethod ~= 'indent' then
      goto continue
    end
    wo.foldmethod = 'expr'
    ::continue::
  end
end

for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  enable_ts_folding(buf)
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('my.ts.set_folding', {}),
  desc = 'Set treesitter folding.',
  callback = function(args)
    enable_ts_folding(args.buf)
  end,
})
