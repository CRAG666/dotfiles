vim.pack.add({
  'https://github.com/DaikyXendo/nvim-material-icon',
  'https://github.com/stevearc/dressing.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/brenoprata10/nvim-highlight-colors',
  'https://github.com/rasulomaroff/reactive.nvim',
  'https://github.com/chentoast/marks.nvim',
})

vim.ui.select = function(...)
  require('lazy').load({ plugins = { 'dressing.nvim' } })
  return vim.ui.select(...)
end

require('which-key').setup({ preset = 'modern' })

require('nvim-highlight-colors').setup({
  render = 'background',
  enable_tailwind = false,
})

require('reactive').setup({
  builtin = {
    cursorline = true,
    cursor = true,
    modemsg = true,
  },
  load = { 'catppuccin-mocha-cursor', 'catppuccin-mocha-cursorline' },
})

require('marks').setup({})
