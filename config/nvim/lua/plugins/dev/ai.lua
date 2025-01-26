return {
  {
    'yetone/avante.nvim',
    keys = {
      { '<leader>aa' },
    },
    -- opts = {
    --   provider = 'ollama',
    --   vendors = {
    --     ollama = {
    --       __inherited_from = 'openai',
    --       api_key_name = '',
    --       endpoint = 'http://127.0.0.1:11434/v1',
    --       model = 'deepseek-r1:8b',
    --     },
    --   },
    -- },
    opts = {
      provider = 'openai',
      -- auto_suggestions_provider = 'copilot',
      openai = {
        endpoint = 'https://api.deepseek.com/v1',
        model = 'deepseek-chat',
        timeout = 30000,
        temperature = 0,
        max_tokens = 4096,
        api_key_name = 'DEEPSEEK_API_KEY',
      },
    },
    build = 'make',
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
  },
  -- {
  --   'olimorris/codecompanion.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-treesitter/nvim-treesitter',
  --   },
  --   keys = {
  --     {
  --       '<leader>aa',
  --       function()
  --         require('codecompanion').toggle()
  --       end,
  --       desc = 'Toggle code companion',
  --     },
  --   },
  --   opts = {
  --     adapters = {
  --       deepseek = function()
  --         return require('codecompanion.adapters').extend('deepseek', {
  --           env = {
  --             api_key = 'DEEPSEEK_API_KEY', -- See note above about using cmd for secure API key storage
  --           },
  --           schema = {
  --             model = {
  --               default = 'deepseek-chat',
  --             },
  --           },
  --         })
  --       end,
  --     },
  --     strategies = {
  --       chat = {
  --         adapter = 'deepseek',
  --       },
  --       inline = {
  --         adapter = 'deepseek',
  --       },
  --     },
  --   },
  -- },
}
