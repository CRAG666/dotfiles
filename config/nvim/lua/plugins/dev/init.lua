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
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = '[U]ndotree' },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        json = { 'jq' },
        bib = { 'bibtex-tidy' },
        tex = { 'tex-fmt' },
      },
      formatters = {
        ["tex-fmt"] = {
          args = {
            "-s",
            "--wraplen",
            "112",
          },
        },
        ["bibtex-tidy"] = {
          args = {
            "--curly",
            "--numeric",
            "--align=13",
            "--blank-lines",
            "--duplicates=key,doi,citation,abstract",
            "--merge",
            "--sort-fields",
            "--remove-empty-fields",
            "--wrap=106",
            "$FILENAME"
          },
        },
      },
    },
  },
  {
    'rachartier/tiny-code-action.nvim',
    event = 'LspAttach',
    keys = {
      {
        '<C-.>',
        function()
          require('tiny-code-action').code_action()
        end,
        desc = 'Code Action',
      },
    },
    opts = {
      backend = 'delta',
      picker = { "snacks" }
    },
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      require('tiny-inline-diagnostic').setup()
    end
  },
  {
    'folke/ts-comments.nvim',
    event = 'BufEnter',
    opts = {},
  },
}
