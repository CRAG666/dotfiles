local neorg_leader = '<leader>o'
local neorg_enabled = false
-- vim.w.toc_open = false
-- vim.w.win_toc = -1
return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'norg', 'norg_meta' })
      end
    end,
  },
  {
    'nvim-neorg/neorg',
    dependencies = {
      {
        'juniorsundar/neorg-extras',
        version = '*',
      },
    },
    cmd = 'Neorg',
    ft = 'norg',
    keys = {
      {
        neorg_leader .. 'o',
        function()
          if neorg_enabled then
            vim.cmd.Neorg('return')
            neorg_enabled = false
            return
          end
          vim.cmd.Neorg.workspace('notes')
          neorg_enabled = true
        end,
        desc = 'Toggle org notes',
      },
      {
        neorg_leader .. 'c',
        function()
          vim.cmd.Neorg('toggle-concealer')
        end,
        desc = 'Toggle highlighting org',
      },
      {
        neorg_leader .. 'tt',
        function()
          -- if vim.w.toc_open then
          --   vim.api.nvim_win_close(vim.w.win_toc, false)
          --   vim.w.toc_open = false
          --   return
          -- end
          vim.cmd.Neorg('toc')
          vim.cmd('vert resize 60')
          -- vim.w.win_toc = vim.api.nvim_win_get_number(0)
          -- vim.w.toc_open = true
        end,
        desc = 'Toggle highlighting org',
      },
    },
    opts = {
      load = {
        ['core.defaults'] = {},
        ["core.keybinds"] = {},
        ['core.concealer'] = {
          config = {
            dim_code_blocks = { conceal = false },
            icon_preset = 'basic',
            -- icon_preset = "diamond",
            icons = {
              code_block = {
                conceal = true,
              },
              delimiter = {
                horizontal_line = {
                  icon = '■',
                },
              },
              definition = {
                single = { icon = '🔖 ' },
                multi_prefix = { icon = '󰉾 ' },
                multi_suffix = { icon = '󰝗 ' },
              },
              list = {
                icons = { '✿' },
              },
              quote = {
                icons = { '󰇙' },
              },
              heading = {
                icons = {
                  '🌸 ',
                  '🌼 ',
                  '🌺 ',
                  '💠 ',
                  '🍀 ',
                  '🪻 ',
                },
              },
            },
          },
        },
        ['core.dirman'] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = '~/Documentos/Org/Notes',
              state_art = '~/Documentos/Org/Estado_Arte/',
            },
          },
        },
        ['core.looking-glass'] = {},
        ['core.export'] = {},
        ['core.summary'] = {},
        ['core.ui.calendar'] = {},
        ['core.latex.renderer'] = {},
        ['external.many-mans'] = {
          config = {
            metadata_fold = true, -- If want @data property ... @end to fold
            code_fold = true,     -- If want @code ... @end to fold
          },
        },
        -- OPTIONAL
        ['external.agenda'] = {},
      }
    }
  },
}
