local utils = require('utils')
local M = {}
local lsp_autostop_pending
---Automatically stop LSP servers that no longer attach to any buffers
---
---  Once `LspDetach` is triggered, wait for 60s before checking and
---  stopping servers, in this way the callback will be invoked once
---  every 60 seconds at most and can stop multiple clients at once
---  if possible, which is more efficient than checking and stopping
---  clients on every `LspDetach` events
---
---@return nil
local function setup_lsp_stopdetached()
  vim.api.nvim_create_autocmd('LspDetach', {
    group = vim.api.nvim_create_augroup('LspAutoStop', {}),
    desc = 'Automatically stop detached language servers.',
    callback = function()
      if lsp_autostop_pending then
        return
      end
      lsp_autostop_pending = true
      vim.defer_fn(function()
        lsp_autostop_pending = nil
        for _, client in ipairs(vim.lsp.get_clients()) do
          if vim.tbl_isempty(client.attached_buffers) then
            utils.lsp.soft_stop(client)
          end
        end
      end, 60000)
    end,
  })
end

---Setup LSP handlers overrides
---@return nil
local function setup_lsp_overrides()
  -- Show notification if no references, definition, declaration,
  -- implementation or type definition is found
  local methods = {
    'textDocument/references',
    'textDocument/definition',
    'textDocument/declaration',
    'textDocument/implementation',
    'textDocument/typeDefinition',
  }

  for _, method in ipairs(methods) do
    local obj_name = method:match('/(%w*)$'):gsub('s$', '')
    local handler = vim.lsp.handlers[method]

    vim.lsp.handlers[method] = function(err, result, ctx, ...)
      if not result or vim.tbl_isempty(result) then
        vim.notify('[LSP] no ' .. obj_name .. ' found')
        return
      end

      -- textDocument/definition can return Location or Location[]
      -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition
      if not vim.islist(result) then
        result = { result }
      end

      if #result == 1 then
        local enc = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
        vim.lsp.util.show_document(result[1], enc, { focus = true })
        return
      end

      handler(err, result, ctx, ...)
    end
  end

  -- Configure hovering window style
  -- Hijack LSP floating window function to use custom options
  local _open_floating_preview = vim.lsp.util.open_floating_preview
  ---@param contents table of lines to show in window
  ---@param syntax string of syntax to set for opened buffer
  ---@param opts table with optional fields (additional keys are passed on to |nvim_open_win()|)
  ---@returns bufnr,winnr buffer and window number of the newly created floating preview window
  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.lsp.util.open_floating_preview(contents, syntax, opts)
    local source_ft = vim.bo[vim.api.nvim_get_current_buf()].ft
    opts = vim.tbl_deep_extend('force', opts, {
      border = 'solid',
      max_width = math.max(80, math.ceil(vim.go.columns * 0.75)),
      max_height = math.max(20, math.ceil(vim.go.lines * 0.4)),
      close_events = {
        'CursorMovedI',
        'CursorMoved',
        'InsertEnter',
        'WinScrolled',
        'WinResized',
        'VimResized',
      },
    })
    -- If source filetype is markdown, use custom mkd syntax instead of
    -- markdown syntax to avoid using treesitter highlight and get math
    -- concealing provided by vimtex in the floating window
    if source_ft == 'markdown' then
      syntax = 'markdown'
      opts.wrap = false
    end
    local floating_bufnr, floating_winnr =
        _open_floating_preview(contents, syntax, opts)
    vim.wo[floating_winnr].concealcursor = 'nc'
    return floating_bufnr, floating_winnr
  end

  -- Use loclist instead of qflist by default when showing document symbols
  local _lsp_document_symbol = vim.lsp.buf.document_symbol
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.buf.document_symbol = function()
    ---@diagnostic disable-next-line: redundant-parameter
    _lsp_document_symbol({
      loclist = true,
    })
  end
end

-- Diagnostic configuration
local function setup_diagnostic_configs()
  local icons = utils.static.icons.diagnostics
  vim.diagnostic.config({
    severity_sort = true,
    jump = {
      float = true,
    },
    -- underline = false,
    -- virtual_text = {
    --   spacing = 4,
    --   prefix = vim.trim(utils.static.icons.AngleLeft),
    -- },
    virtual_text = false,
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
      severity_sort = true,
      -- virtual_lines = true,
    },
  })
end

---Setup diagnostic handlers overrides
local function setup_diagnostic_overrides()
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
        :filter(function(diag) ---@param diag diagnostic_t
          ---@class diagnostic_t: vim.Diagnostic
          ---@field _hidden boolean whether the diagnostic is shown as virtual text

          diag._hidden = vim
              .iter(diags_cache[diag.bufnr][diag.lnum])
              :any(function(d) ---@param d diagnostic_t
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

function M.setup()
  local lu = require('config.lsp.utils')
  vim.lsp.config('*', {
    capabilities = lu.capabilities(),
    root_markers = require('utils.fs').root_markers,
  })
  lu.on_attach(function(client, bufnr)
    -- if vim.lsp.inlay_hint.is_enabled() ~= true then
    --   vim.lsp.inlay_hint.enable()
    -- end
    require('config.lsp.commands').setup()
    require('config.lsp.keymaps').on_attach(client, bufnr)
    setup_lsp_overrides()
    setup_lsp_stopdetached()
    setup_diagnostic_overrides()
    setup_diagnostic_configs()
  end)
end

return M
