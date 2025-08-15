vim.bo.sw = 4
vim.bo.cindent = false
vim.bo.smartindent = false
vim.bo.commentstring = '<!-- %s -->'
vim.g.mason = { 'marksman', 'remark-language-server' }

vim.pack.add({ 'https://github.com/OXY2DEV/markview.nvim' })

require('markview.extras.checkboxes').setup()
require('markview').setup({
  preview = {
    filetypes = {
      'markdown',
      'codecompanion',
      'norg',
      'vimwiki',
      'typst',
      'latex',
      'quarto',
    },
    ignore_buftypes = {},
    condition = function(buffer)
      local ft, bt = vim.bo[buffer].ft, vim.bo[buffer].bt

      if bt == 'nofile' and ft == 'codecompanion' then
        return true
      elseif bt == 'nofile' then
        return false
      else
        return true
      end
    end,
  },
  latex = {
    enable = true,
    blocks = {
      enable = true,
      conceal = true,
      markers = { '$$', '\\\\[', '\\begin{equation}' },
      preview = true,
    },
    inlines = true,
    commands = true,
  },
})
