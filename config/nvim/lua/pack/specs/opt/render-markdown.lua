local file_types = { 'markdown', 'vimwiki', 'codecompanion', 'quarto' }

return {
  src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  data = {
    events = {
      event = 'FileType',
      pattern = file_types,
    },
    postload = function()
      -- Treesitter's `conceal_lines` check before drawing each row walks every
      -- injected tree in the buffer, which makes scrolling slow in markdown.
      -- Skip it in rendered filetypes: treesitter still conceals the lines
      -- while drawing them and render-markdown conceals code fences itself
      local ts_hl = require('vim.treesitter.highlighter')
      local function skip_conceal_line_check(hl)
        if vim.tbl_contains(file_types, vim.bo[hl.bufnr].ft) then
          hl._conceal_line = false
        end
        return hl
      end
      local ts_hl_new = ts_hl.new
      ts_hl.new = function(...)
        return skip_conceal_line_check(ts_hl_new(...))
      end
      for _, hl in pairs(ts_hl.active) do
        skip_conceal_line_check(hl)
      end

      local function render()
        require('render-markdown').setup({
          file_types = file_types,
          completions = {
            blink = { enabled = true },
            lsp = { enabled = true },
          },
        })
      end
      if vim.bo.ft == 'markdown' or vim.bo.ft == 'quarto' then
        vim.schedule(render)
      else
        render()
      end
    end,
  },
}
