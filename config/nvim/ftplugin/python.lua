vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.bo.textwidth = 80
vim.bo.autoindent = true
vim.bo.smartindent = true

vim.pack.add({
  'nvim-neotest/neotest-python',
})

require('neotest').setup({
  adapters = {
    ['neotest-python'] = {
      -- Here you can specify the settings for the adapter, i.e.
      -- runner = "pytest",
      -- python = ".venv/bin/python",
    },
  },
})
