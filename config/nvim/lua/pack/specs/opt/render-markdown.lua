local file_types = { 'markdown', 'vimwiki', 'codecompanion', 'quarto' }

return {
  src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  data = {
    events = {
      event = 'FileType',
      pattern = file_types,
    },
    preload = function()
      -- Read by the plugin's own setup on load; a second `setup()` call would
      -- clear the first render until the cursor moves
      vim.g.render_markdown_config = {
        file_types = file_types,
        completions = {
          blink = { enabled = true },
          lsp = { enabled = true },
        },
        code = { render_modes = { 'i' } },
        dash = { render_modes = { 'i' } },
      }
    end,
    postload = function()
      local hl = require('utils.hl')
      hl.persist(function()
        hl.set(0, 'markdownCode', { bg = 'RenderMarkdownCode' })
        hl.set(0, 'markdownCodeDelimiter', { bg = 'RenderMarkdownCode' })
        hl.set(0, '@markup.raw.markdown_inline', {
          fg = 'String',
          bg = 'RenderMarkdownCode',
        })
      end)
    end,
  },
}
