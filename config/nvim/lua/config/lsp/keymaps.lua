local M = {}
function M.on_attach(_, buffer)
  local utils = require('utils.keymap')
  local lsp = vim.lsp.buf
  local bufopt = { buffer = buffer }

  vim.bo[buffer].omnifunc = 'v:lua.vim.lsp.omnifunc'
  local lsp_maps = {
    {
      prefix = 'g',
      maps = {
        { 'o', lsp.type_definition, 'Type definition', bufopt }
        -- { "D", "<cmd>tab split | lua vim.lsp.buf.definition()<CR>", "Goto Definition in new Tab", bufopt },
        -- { "R", lsp.references, "LSP References", bufopt },
      },
    },
    {
      prefix = '<leader>',
      maps = {
        { 'aw', vim.lsp.buf.add_workspace_folder, 'LSP Add Folder', bufopt },
        -- { "dt", require("lsp_lines").toggle, "Toggle Diagnostic", bufopt },
      },
    },
  }
  utils.maps(lsp_maps)
  vim.keymap.set({ 'n', 'x' }, 'gy', function()
    local diags = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
    local n_diags = #diags
    if n_diags == 0 then
      vim.notify(
        '[LSP] no diagnostics found in current line',
        vim.log.levels.WARN
      )
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
      vim.notify(
        string.format([[[LSP] yanked diagnostic message '%s']], msg),
        vim.log.levels.INFO
      )
      return
    end

    vim.ui.select(
      vim.tbl_map(function(d)
        return d.message
      end, diags),
      { prompt = 'Select diagnostic message to yank: ' },
      _yank
    )
  end, { desc = 'Yank diagnostic message on current line' })
end
return M
