local M = {}
function M.on_attach(_, buffer)
  local utils = require "utils.keymap"
  local lsp = vim.lsp.buf
  local bufopt = { buffer = buffer }

  vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"
  local d = vim.diagnostic

  local function toggleDiagnosticList()
    local curr_win = vim.api.nvim_get_current_win()
    local loclist_win = vim.fn.getloclist(0, { winid = 0 }).winid

    if loclist_win ~= 0 then
      if curr_win == loclist_win then
        vim.cmd.lclose()
      else
        vim.cmd.lclose()
      end
    else
      vim.diagnostic.setloclist { open = true }
    end
  end

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

  utils.map("n", "]d", d.goto_next, vim.tbl_extend("force", bufopt, { desc = "Next diagnostic" }))
  utils.map("n", "[d", d.goto_prev, vim.tbl_extend("force", bufopt, { desc = "Prev diagnostic" }))

  -- vim.keymap.set("n", ";df", vim.diagnostic.open_float)

  local lsp_maps = {
    {
      prefix = "g",
      maps = {
        { "d", lsp.definition, "Goto Definition", bufopt },
        { "D", lsp.declaration, "Goto Declaration", bufopt },
        { "i", lsp.implementation, "Goto Implementation", bufopt },
        { "o", lsp.type_definition, "Type definition", bufopt },
        { "r", lsp.rename, "Rename", bufopt },
        { "s", lsp.signature_help, "Goto Implementation", bufopt },
        { "y", "<cmd>tab split | lua vim.lsp.buf.definition()<CR>", "Goto Definition in new Tab", bufopt },
        { "h", lsp.hover, "LSP Hover", bufopt },
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
end
return M
