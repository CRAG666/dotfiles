local utils = require "utils"
local M = {}
local root_patterns = {
  ".git/",
  ".svn/",
  ".bzr/",
  ".hg/",
  ".project/",
  ".pro",
  ".sln",
  ".vcxproj",
  "Makefile",
  "makefile",
  "MAKEFILE",
  ".gitignore",
  ".editorconfig",
}

local lsp_autostop_pending
---Automatically stop LSP servers that no longer attach to any buffers
---
---  Once `BufDelete` is triggered, wait for 60s before checking and
---  stopping servers, in this way the callback will be invoked once
---  every 60 seconds at most and can stop multiple clients at once
---  if possible, which is more efficient than checking and stopping
---  clients on every `BufDelete` events
---
---@return nil
local function setup_lsp_stopdetached()
  vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("LspAutoStop", {}),
    desc = "Automatically stop detached language servers.",
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
    "textDocument/references",
    "textDocument/definition",
    "textDocument/declaration",
    "textDocument/implementation",
    "textDocument/typeDefinition",
  }

  for _, method in ipairs(methods) do
    local obj_name = method:match("/(%w*)$"):gsub("s$", "")
    local handler = vim.lsp.handlers[method]

    vim.lsp.handlers[method] = function(err, result, ctx, ...)
      if not result or vim.tbl_isempty(result) then
        vim.notify("[LSP] no " .. obj_name .. " found")
        return
      end

      -- textDocument/definition can return Location or Location[]
      -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition
      if not vim.islist(result) then
        result = { result }
      end

      if #result == 1 then
        local enc = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
        vim.lsp.util.jump_to_location(result[1], enc)
        vim.notify("[LSP] found 1 " .. obj_name)
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
    opts = vim.tbl_deep_extend("force", opts, {
      border = "solid",
      max_width = math.max(80, math.ceil(vim.go.columns * 0.75)),
      max_height = math.max(20, math.ceil(vim.go.lines * 0.4)),
      close_events = {
        "CursorMovedI",
        "CursorMoved",
        "InsertEnter",
        "WinScrolled",
        "WinResized",
        "VimResized",
      },
    })
    -- If source filetype is markdown, use custom mkd syntax instead of
    -- markdown syntax to avoid using treesitter highlight and get math
    -- concealing provided by vimtex in the floating window
    if source_ft == "markdown" then
      syntax = "markdown"
      opts.wrap = false
    end
    local floating_bufnr, floating_winnr = _open_floating_preview(contents, syntax, opts)
    vim.wo[floating_winnr].concealcursor = "nc"
    return floating_bufnr, floating_winnr
  end

  -- Use loclist instead of qflist by default when showing document symbols
  local _lsp_document_symbol = vim.lsp.buf.document_symbol
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.buf.document_symbol = function()
    ---@diagnostic disable-next-line: redundant-parameter
    _lsp_document_symbol {
      loclist = true,
    }
  end
end

local function setup_diagnostic()
  -- Diagnostic configuration
  local icons = utils.static.icons.diagnostics
  vim.diagnostic.config {
    underline = false,
    virtual_text = false,
    -- virtual_text = { spacing = 4, prefix = "●" },
    -- virtual_text = {
    --   severity = {
    --     min = vim.diagnostic.severity.ERROR,
    --   },
    -- },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.DiagnosticSignError,
        [vim.diagnostic.severity.WARN] = icons.DiagnosticSignWarn,
        [vim.diagnostic.severity.INFO] = icons.DiagnosticSignInfo,
        [vim.diagnostic.severity.HINT] = icons.DiagnosticSignHint,
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
      severity_sort = true,
      -- virtual_lines = true,
    },
  }
end

function M.setup(server, on_attach)
  -- if vim.lsp.inlay_hint.is_enabled() ~= true then
  --   vim.lsp.inlay_hint.enable()
  -- end
  local lu = require "config.lsp.utils"
  lu.on_attach(function(client, bufnr)
    require("config.lsp.highlighter").on_attach(client, bufnr)
    require("config.lsp.format").on_attach(client, bufnr)
    require("config.lsp.keymaps").on_attach(client, bufnr)
    setup_lsp_overrides()
    setup_lsp_stopdetached()
    setup_diagnostic()
    if on_attach ~= nil then
      on_attach(client, bufnr)
    end
  end)
  server.capabilities = lu.capabilities()
  server.root_dir = vim.fs.root(0, vim.list_extend(server.root_patterns or {}, root_patterns or {}))
  server.root_patterns = nil
  return vim.lsp.start(server)
end

return M
