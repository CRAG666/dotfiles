local utils = require "utils"
local M = {}

local lsp_autostop_pending
---Automatically stop LSP servers that no longer attaches to any buffers
---
---  Once `BufDelete` is triggered, wait for 60s before checking and
---  stopping servers, in this way the callback will be invoked once
---  every 60 seconds at most and can stop multiple clients at once
---  if possible, which is more efficient than checking and stopping
---  clients on every `BufDelete` events
---
---@return nil
local function setup_lsp_stopidle()
  vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("LspAutoStop", {}),
    desc = "Automatically stop idle language servers.",
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
  local handlers = {
    ["textDocument/references"] = vim.lsp.handlers["textDocument/references"],
    ["textDocument/definition"] = vim.lsp.handlers["textDocument/definition"],
    ["textDocument/declaration"] = vim.lsp.handlers["textDocument/declaration"],
    ["textDocument/implementation"] = vim.lsp.handlers["textDocument/implementation"],
    ["textDocument/typeDefinition"] = vim.lsp.handlers["textDocument/typeDefinition"],
  }
  for method, handler in pairs(handlers) do
    local obj_name = method:match("/(%w*)$"):gsub("s$", "")
    vim.lsp.handlers[method] = function(err, result, ctx, cfg)
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
      handler(err, result, ctx, cfg)
    end
  end

  -- Configure hovering window style
  local opts_override_floating_preview = {
    border = "solid",
    max_width = math.max(80, math.ceil(vim.go.columns * 0.75)),
    max_height = math.max(20, math.ceil(vim.go.lines * 0.4)),
    close_events = {
      "CursorMoved",
      "CursorMovedI",
      "WinScrolled",
    },
  }
  vim.api.nvim_create_autocmd("VimResized", {
    desc = "Update LSP floating window maximum size on VimResized.",
    group = vim.api.nvim_create_augroup("LspUpdateFloatingWinMaxSize", {}),
    callback = function()
      opts_override_floating_preview.max_width = math.max(80, math.ceil(vim.go.columns * 0.75))
      opts_override_floating_preview.max_height = math.max(20, math.ceil(vim.go.lines * 0.4))
    end,
  })
  -- Hijack LSP floating window function to use custom options
  local _open_floating_preview = vim.lsp.util.open_floating_preview
  ---@param contents table of lines to show in window
  ---@param syntax string of syntax to set for opened buffer
  ---@param opts table with optional fields (additional keys are passed on to |nvim_open_win()|)
  ---@returns bufnr,winnr buffer and window number of the newly created floating preview window
  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.lsp.util.open_floating_preview(contents, syntax, opts)
    local source_ft = vim.bo[vim.api.nvim_get_current_buf()].ft
    opts = vim.tbl_deep_extend("force", opts, opts_override_floating_preview)
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
  local lu = require "config.lsp.utils"
  lu.on_attach(function(client, bufnr)
    require("config.lsp.highlighter").on_attach(client, bufnr)
    require("config.lsp.format").on_attach(client, bufnr)
    require("config.lsp.keymaps").on_attach(client, bufnr)
    setup_lsp_overrides()
    setup_lsp_stopidle()
    setup_diagnostic()
    if on_attach ~= nil then
      on_attach(client, bufnr)
    end
  end)
  server.capabilities = lu.capabilities()
  local fs = utils.fs
  server.root_dir =
    fs.proj_dir(vim.api.nvim_buf_get_name(0), vim.list_extend(server.root_patterns or {}, fs.root_patterns or {}))
  server.root_patterns = nil
  vim.lsp.start(server)
end

return M
