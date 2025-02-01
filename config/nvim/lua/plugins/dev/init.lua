local setup = require('utils.fn').setup
return {
  {
    'vhyrro/luarocks.nvim',
    priority = 1000,
    config = true,
  },
  {

    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    opts = {
      ensure_installed = {
        'stylua',
        'shfmt',
        'lua-language-server',
        -- ast-grep
        -- harper-ls
        -- lemmy-help
        -- lua-language-server
        -- luacheck
        -- luaformatter
        -- selene
        -- "flake8",
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require('mason-registry')
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require('lazy.core.handler.event').trigger({
            event = 'FileType',
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
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
    end,
  },
  { 'folke/neodev.nvim', ft = 'lua' },
  {
    'VidocqH/lsp-lens.nvim',
    event = 'LspAttach',
    config = setup('lsp-lens'),
  },
  {
    'RaafatTurki/corn.nvim',
    event = 'LspAttach',
    config = function()
      require('corn').setup()
      local group = vim.api.nvim_create_augroup('CornStatus', { clear = true })
      vim.api.nvim_create_autocmd({ 'LspAttach' }, {
        group = group,
        callback = function(...)
          require('corn').toggle()
        end,
      })
    end,
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = '[U]ndotree' },
    },
  },
  {
    'nvimtools/none-ls.nvim',
    event = 'InsertEnter',
    opts = function(_, opts)
      local nls = require('null-ls')
      opts.root_dir = opts.root_dir
        or require('null-ls.utils').root_pattern(
          '.null-ls-root',
          '.neoconf.json',
          'Makefile',
          '.git'
        )
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.stylua,
        nls.builtins.formatting.shfmt,
      })
    end,
  },
  {
    'rachartier/tiny-code-action.nvim',
    keys = {
      {
        '<C-.>',
        function()
          require('tiny-code-action').code_action()
        end,
        desc = 'Code Action',
      },
    },
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope.nvim' },
    },
    event = 'LspAttach',
    config = function()
      require('tiny-code-action').setup({ backend = 'delta' })
    end,
  },
  {
    'Omochice/TeXTable.vim',
    ft = { 'tex' },
  },
  {
    'folke/ts-comments.nvim',
    event = 'BufEnter',
    opts = {},
  },
}
