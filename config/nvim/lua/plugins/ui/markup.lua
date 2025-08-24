require('utils.fn').lazy_load('FileType', 'render-markdown', function()
  local function render()
    vim.pack.add({
      'https://github.com/MeanderingProgrammer/render-markdown.nvim',
    })

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
end, { pattern = { 'markdown', 'vimwiki', 'codecompanion' } })
