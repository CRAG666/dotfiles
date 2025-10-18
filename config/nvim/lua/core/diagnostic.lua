local icons = require('utils.static.icons')

-- Diagnostic configs
vim.diagnostic.config({
  severity_sort = true,
  jump = {
    float = true,
  },
  float = {
    source = true,
  },
  virtual_text = {
    spacing = 4,
    prefix = vim.trim(icons.AngleLeft),
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.DiagnosticSignError,
      [vim.diagnostic.severity.WARN] = icons.DiagnosticSignWarn,
      [vim.diagnostic.severity.INFO] = icons.DiagnosticSignInfo,
      [vim.diagnostic.severity.HINT] = icons.DiagnosticSignHint,
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
      [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
      [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
    },
  },
})

-- Diagnostic handlers overrides
do
  ---Filter out diagnostics that overlap with diagnostics from other sources
  ---For each diagnostic, checks if there exists another diagnostic from a different
  ---namespace that has the same start line and column
  ---
  ---If multiple diagnostics overlap, prefer the one with higher severity
  ---
  ---This helps reduce redundant diagnostics when multiple language servers
  ---(usually a language server and a linter hooked to an lsp wrapper) report
  ---the same issue for the same range
  ---@param diags vim.Diagnostic[]
  ---@return vim.Diagnostic[]
  local function filter_overlapped(diags)
    ---Diagnostics cache, indexed by buffer number and line number (0-indexed)
    ---to avoid calling `vim.diagnostic.get()` for the same buffer and line
    ---repeatedly
    ---@type table<integer, table<integer, table<integer, vim.Diagnostic>>>
    local diags_cache = vim.defaulttable(function(bufnr)
      local ds = vim.defaulttable() -- mapping from lnum to diagnostics
      -- Avoid using another layer of default table index by lnum using
      -- `vim.diagnostic.get(bufnr, { lnum = lnum })` to get diagnostics
      -- by line number since it requires traversing all diagnostics in
      -- the buffer each time
      for _, d in ipairs(vim.diagnostic.get(bufnr)) do
        table.insert(ds[d.lnum], d)
      end
      return ds
    end)

    return vim
      .iter(diags)
      :filter(function(diag) ---@param diag diagnostic
        ---@class diagnostic : vim.Diagnostic
        ---@field _hidden boolean whether the diagnostic is shown as virtual text

        diag._hidden = vim
          .iter(diags_cache[diag.bufnr][diag.lnum])
          :any(function(d) ---@param d diagnostic
            return not d._hidden
              and d.namespace ~= diag.namespace
              and d.severity <= diag.severity
              and d.col == diag.col
          end)

        return not diag._hidden
      end)
      :totable()
  end

  ---Truncates multi-line diagnostic messages to their first line
  ---@param diags vim.Diagnostic[]
  ---@return vim.Diagnostic[]
  local function truncate_multiline(diags)
    return vim
      .iter(diags)
      :map(function(d) ---@param d vim.Diagnostic
        local first_line = vim.gsplit(d.message, '\n')()
        if not first_line or first_line == d.message then
          return d
        end
        return vim.tbl_extend('keep', {
          message = first_line,
        }, d)
      end)
      :totable()
  end

  vim.diagnostic.handlers.virtual_text.show = (function(cb)
    ---@param ns integer
    ---@param buf integer
    ---@param diags vim.Diagnostic[]
    ---@param opts vim.diagnostic.OptsResolved
    return function(ns, buf, diags, opts)
      return cb(ns, buf, truncate_multiline(filter_overlapped(diags)), opts)
    end
  end)(vim.diagnostic.handlers.virtual_text.show)
end

-- stylua: ignore start
vim.keymap.set({ 'n', 'x' }, '<Leader>d', function() vim.diagnostic.setloclist() end, { desc = 'Show document diagnostics' })
vim.keymap.set({ 'n', 'x' }, '<Leader>D', function() vim.diagnostic.setqflist() end, { desc = 'Show workspace diagnostics' })
-- stylua: ignore end

---Open diagnostic floating window, jump to existing window if possible
local function diagnostic_open_float()
  ---@param win integer
  ---@return boolean
  local function is_diag_win(win)
    if vim.fn.win_gettype(win) ~= 'popup' then
      return false
    end
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.bo[buf].bt == 'nofile'
      and unpack(vim.api.nvim_buf_get_lines(buf, 0, 1, false))
        == 'Diagnostics:'
  end

  -- If a diagnostic float window is already open, switch to it
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_diag_win(win) then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  -- Else open diagnostic float
  vim.diagnostic.open_float()
end

-- stylua: ignore start
-- nvim's default mapping
vim.keymap.set({ 'n', 'x' }, '<M-d>', diagnostic_open_float, { desc = 'Open diagnostic floating window' })
vim.keymap.set({ 'n', 'x' }, '<C-w>d', diagnostic_open_float, { desc = 'Open diagnostic floating window' })
vim.keymap.set({ 'n', 'x' }, '<C-w><C-d>', diagnostic_open_float, { desc = 'Open diagnostic floating window' })
vim.keymap.set({ 'n', 'x' }, '<Leader>i', diagnostic_open_float, { desc = 'Open diagnostic floating window' })
-- stylua: ignore end

vim.keymap.set('n', 'yd', function()
  local diags = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
  local n_diags = #diags
  if n_diags == 0 then
    vim.notify('No diagnostics found in current line', vim.log.levels.WARN)
    return
  end

  ---@param msg string?
  local function yank(msg)
    if not msg then
      return
    end
    vim.fn.setreg('"', msg)
    vim.fn.setreg(vim.v.register, msg)
    vim.notify(
      string.format("Yanked diagnostic message '%s'", msg),
      vim.log.levels.INFO
    )
  end

  if n_diags == 1 then
    local msg = diags[1].message
    yank(msg)
    return
  end

  vim.ui.select(
    vim.tbl_map(function(d)
      return d.message
    end, diags),
    { prompt = 'Select diagnostic message to yank: ' },
    yank
  )
end, { desc = 'Yank diagnostic message on current line' })

-- stylua: ignore start
vim.keymap.set({ 'n', 'x' }, '[d', function() vim.diagnostic.jump({ count = -vim.v.count1 }) end, { desc = 'Go to previous diagnostic' })
vim.keymap.set({ 'n', 'x' }, ']d', function() vim.diagnostic.jump({ count =  vim.v.count1 }) end, { desc = 'Go to next diagnostic' })
vim.keymap.set({ 'n', 'x' }, '[e', function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR }) end, { desc = 'Go to previous diagnostic error' })
vim.keymap.set({ 'n', 'x' }, ']e', function() vim.diagnostic.jump({ count =  vim.v.count1, severity = vim.diagnostic.severity.ERROR }) end, { desc = 'Go to next diagnostic error' })
vim.keymap.set({ 'n', 'x' }, '[w', function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN }) end, { desc = 'Go to previous diagnostic warning' })
vim.keymap.set({ 'n', 'x' }, ']w', function() vim.diagnostic.jump({ count =  vim.v.count1, severity = vim.diagnostic.severity.WARN }) end, { desc = 'Go to next diagnostic warning' })
vim.keymap.set({ 'n', 'x' }, '[i', function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.INFO }) end, { desc = 'Go to previous diagnostic info' })
vim.keymap.set({ 'n', 'x' }, ']i', function() vim.diagnostic.jump({ count =  vim.v.count1, severity = vim.diagnostic.severity.INFO }) end, { desc = 'Go to next diagnostic info' })
vim.keymap.set({ 'n', 'x' }, '[h', function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.HINT }) end, { desc = 'Go to previous diagnostic hint' })
vim.keymap.set({ 'n', 'x' }, ']h', function() vim.diagnostic.jump({ count =  vim.v.count1, severity = vim.diagnostic.severity.HINT }) end, { desc = 'Go to next diagnostic hint' })
-- stylua: ignore end
