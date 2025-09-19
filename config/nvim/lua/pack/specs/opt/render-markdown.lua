return {
  src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  data = {
    events = {
      event = 'FileType',
      pattern = { 'markdown', 'vimwiki', 'codecompanion' },
    },
    postload = function()
      local function render()
        require('render-markdown').setup({
          file_types = { 'markdown', 'vimwiki', 'codecompanion' },
          completions = { blink = { enabled = true }, lsp = { enabled = true } },
        })
      end
      if vim.bo.ft == 'markdown' then
        vim.schedule(render)
      else
        render()
      end
    end,
  },
}