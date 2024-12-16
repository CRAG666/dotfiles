local M = {}
function M.on_attach(_, buffer)
  local utils = require "utils.keymap"
  local lsp = vim.lsp.buf
  local bufopt = { buffer = buffer }

  vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"
  local d = vim.diagnostic

  -- local function toggleDiagnosticList()
  --   local curr_win = vim.api.nvim_get_current_win()
  --   local loclist_win = vim.fn.getloclist(0, { winid = 0 }).winid
  --
  --   if loclist_win ~= 0 then
  --     if curr_win == loclist_win then
  --       vim.cmd.lclose()
  --     else
  --       vim.cmd.lclose()
  --     end
  --   else
  --     vim.diagnostic.setloclist { open = true }
  --   end
  -- end

  -- utils.map({ "n", "l" }, ";dl", toggleDiagnosticList, { desc = "Toggle diagnostic local" })
  --
  -- local function toggleDiagnosticQuickfix()
  --   local quickfix_win = vim.fn.getqflist({ winid = 0 }).winid
  --
  --   if quickfix_win ~= 0 and vim.fn.win_getid() == quickfix_win then
  --     -- Si el foco está en la ventana del quickfix, ciérrala
  --     vim.cmd "cclose"
  --   elseif quickfix_win ~= 0 then
  --     -- Si el quickfix está abierto pero el foco no está en él, también ciérralo
  --     vim.cmd "cclose"
  --   else
  --     -- Si el quickfix está cerrado, ábrelo
  --     vim.diagnostic.setqflist { open = true }
  --   end
  -- end
  --
  -- utils.map({ "n", "c" }, ";dg", toggleDiagnosticQuickfix, { desc = "Toggle diagnostic global" })
  -- utils.map(
  --   { "n", "c" },
  --   ";dg",
  --   toggleDiagnosticQuickfix,
  --   vim.tbl_extend("force", bufopt, { desc = "Next diagnostic" })
  -- )

  -- vim.keymap.set("n", ";df", vim.diagnostic.open_float)

  local lsp_maps = {
    {
      prefix = "g",
      maps = {
        { "r", lsp.rename, "Rename", bufopt },
        { "d", lsp.definition, "Goto Definition", bufopt },
        { "D", lsp.declaration, "Goto Declaration", bufopt },
        { "i", lsp.implementation, "Goto Implementation", bufopt },
        { "o", lsp.type_definition, "Type definition", bufopt },
        { "s", lsp.signature_help, "Goto Implementation", bufopt },
        { "y", "<cmd>tab split | lua vim.lsp.buf.definition()<CR>", "Goto Definition in new Tab", bufopt },
        { "/", lsp.references, "LSP References", bufopt },
      },
    },
    {
      prefix = "<leader>",
      maps = {
        { "aw", vim.lsp.buf.add_workspace_folder, "LSP Add Folder", bufopt },
        -- { "dt", require("lsp_lines").toggle, "Toggle Diagnostic", bufopt },
      },
    },
  }
  utils.maps(lsp_maps)
  utils.map({ "n", "x" }, "<C-.>", lsp.code_action, vim.tbl_extend("force", bufopt, { desc = "Code actions" }))
  vim.keymap.set({ "n", "x" }, "gy", function()
    local diags = vim.diagnostic.get(0, { lnum = vim.fn.line "." - 1 })
    local n_diags = #diags
    if n_diags == 0 then
      vim.notify("[LSP] no diagnostics found in current line", vim.log.levels.WARN)
      return
    end

    ---@param msg string
    local function _yank(msg)
      vim.fn.setreg('"', msg)
      vim.fn.setreg(vim.v.register, msg)
    end

    if n_diags == 1 then
      local msg = diags[1].message
      _yank(msg)
      vim.notify(string.format([[[LSP] yanked diagnostic message '%s']], msg), vim.log.levels.INFO)
      return
    end

    vim.ui.select(
      vim.tbl_map(function(d)
        return d.message
      end, diags),
      { prompt = "Select diagnostic message to yank: " },
      _yank
    )
  end, { desc = "Yank diagnostic message on current line" })
end
return M
