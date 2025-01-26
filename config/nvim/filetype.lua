vim.filetype.add({
  extension = {
    -- Special filetypes for Weixin Mini Program
    wxss = 'css',
    wxml = 'html',
  },
})

vim.filetype.add({
  pattern = { ['.*/hypr/.*%.conf'] = 'hyprlang' },
})

vim.filetype.add({
  pattern = { ['zathurarc'] = 'zathurarc' },
})

vim.filetype.add({
  pattern = { ['.*%.rasi'] = 'rasi' },
})
vim.treesitter.language.register('markdown', 'quarto')
vim.treesitter.language.register('markdown', 'Avante')
vim.filetype.add({
  pattern = { ['.*%.ipynb'] = 'jupyter' },
})
