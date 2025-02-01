local icons = require('utils.static').icons
return {
  -- Add C/C++ to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'c', 'cpp', 'cmake', 'make' })
      end
    end,
  },

  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        role_icons = {
          ['type'] = icons.Type,
          ['declaration'] = icons.Function,
          ['expression'] = icons.Snippet,
          ['specifier'] = icons.Specifier,
          ['statement'] = icons.Statement,
          ['template argument'] = icons.TypeParameter,
        },
        kind_icons = {
          ['Compound'] = icons.Namespace,
          ['Recovery'] = icons.DiagnosticSignError,
          ['TranslationUnit'] = icons.Unit,
          ['PackExpansion'] = icons.Ellipsis,
          ['TemplateTypeParm'] = icons.TypeParameter,
          ['TemplateTemplateParm'] = icons.TypeParameter,
          ['TemplateParamObject'] = icons.TypeParameter,
        },
      },
      memory_usage = { border = 'solid' },
      symbol_info = { border = 'solid' },
    },
  },
  -- {
  --   "nvim-cmp",
  --   opts = function(_, opts)
  --     table.insert(opts.sorting.comparators, 1, require "clangd_extensions.cmp_scores")
  --   end,
  -- },
  {
    'mfussenegger/nvim-dap',
    optional = true,
    dependencies = {
      -- Ensure C/C++ debugger is installed
      'williamboman/mason.nvim',
      optional = true,
      opts = function(_, opts)
        if type(opts.ensure_installed) == 'table' then
          vim.list_extend(opts.ensure_installed, { 'codelldb' })
        end
      end,
    },
    opts = function()
      local dap = require('dap')
      if not dap.adapters['codelldb'] then
        require('dap').adapters['codelldb'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'codelldb',
            args = {
              '--port',
              '${port}',
            },
          },
        }
      end
      for _, lang in ipairs({ 'c', 'cpp' }) do
        dap.configurations[lang] = {
          {
            type = 'codelldb',
            request = 'launch',
            name = 'Launch file',
            program = function()
              return vim.fn.input(
                'Path to executable: ',
                vim.fn.getcwd() .. '/',
                'file'
              )
            end,
            cwd = '${workspaceFolder}',
          },
          {
            type = 'codelldb',
            request = 'attach',
            name = 'Attach to process',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end,
  },
}
