-- Hola mundo
return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    cmd = 'CodeCompanion',
    keys = {
      {
        '<leader>aa',
        function()
          require('codecompanion').toggle()
        end,
        desc = '[A]i: Toggle',
      },
      {
        '<leader>ap',
        [[:CodeCompanion /buffer ]],
        desc = '[A]i: Action [P]alette',
      },
      {
        '<leader>ab',
        [[:CodeCompanion /buffer ]],
        mode = 'v',
        desc = '[A]i: Analyze [B]uffer',
      },
      {
        '<leader>af',
        [[:CodeCompanion /fix ]],
        mode = 'v',
        desc = '[A]i: [F]ix code',
      },
      {
        '<leader>ae',
        [[:CodeCompanion /explain ]],
        mode = 'v',
        desc = '[A]i: [E]xplain code',
      },
      {
        '<leader>at',
        [[:CodeCompanion /tests ]],
        mode = 'v',
        desc = '[A]i: [T]est code',
      },
    },
    opts = {
      language = 'Spanish',
      adapters = {
        deepseek = function()
          return require('codecompanion.adapters').extend('deepseek', {
            env = {
              api_key = 'cmd:gak ai/deepseek',
            },
            schema = {
              model = {
                default = 'deepseek-chat',
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'deepseek',
        },
        inline = {
          adapter = 'deepseek',
          keymaps = {
            accept_change = {
              modes = { n = 'ca' },
              description = 'Accept the suggested change',
            },
            reject_change = {
              modes = { n = 'cr' },
              description = 'Reject the suggested change',
            },
          },
        },
      },
    },
  },
}
