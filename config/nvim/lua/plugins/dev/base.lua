-- Common dependencies used across multiple plugins
vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/williamboman/mason.nvim' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },
})

-- Mason setup
local mason_opts = {
  ensure_installed = {
    'stylua',
    'shfmt',
    'lua-language-server',
    'efm',
    'luacheck',
  },
}

require('mason').setup(mason_opts)
local mr = require('mason-registry')

-- Auto-install packages
local function ensure_installed()
  for _, tool in ipairs(mason_opts.ensure_installed) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end

if mr.refresh then
  mr.refresh(ensure_installed)
else
  ensure_installed()
end

-- Other plugins from original init
local key = require('utils.keymap')

vim.pack.add({ { src = 'https://github.com/VidocqH/lsp-lens.nvim' } })
require('lsp-lens').setup({})

vim.pack.add({ { src = 'https://github.com/mbbill/undotree' } })
key.map('n', '<leader>ut', '<cmd>UndotreeToggle<cr>', { desc = '[U]ndotree' })

vim.pack.add({
  { src = 'https://github.com/rachartier/tiny-code-action.nvim' },
})
require('tiny-code-action').setup({
  backend = 'delta',
  picker = { 'snacks' },
})
key.map('n', '<C-.>', function()
  require('tiny-code-action').code_action()
end, { desc = 'Code Action' })

vim.pack.add({
  { src = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim' },
})
require('tiny-inline-diagnostic').setup()

vim.pack.add({ { src = 'https://github.com/folke/ts-comments.nvim' } })
require('ts-comments').setup({})

vim.pack.add({ { src = 'https://github.com/nvzone/minty' } })
