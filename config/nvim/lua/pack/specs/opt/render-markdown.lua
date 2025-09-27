return {
  src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  data = {
    events = {
      event = 'FileType',
      pattern = { 'markdown', 'vimwiki', 'codecompanion', 'quarto' },
    },
    postload = function()
      local function render()
        require('render-markdown').setup({
          file_types = { 'markdown', 'vimwiki', 'codecompanion', 'quarto' },
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
