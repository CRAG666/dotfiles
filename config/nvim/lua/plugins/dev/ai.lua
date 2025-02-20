local icons = require('utils.static.icons')
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
        '<leader>ac',
        function()
          require('codecompanion').toggle()
        end,
        desc = '[A]i: Toggle',
      },
      {
        '<leader>ap',
        [[<Cmd>CodeCompanionActions<CR>]],
        desc = '[A]i: Action [P]alette',
      },
      {
        '<leader>aa',
        mode = { 'n', 'v' },
        [[:CodeCompanion ]],
        desc = '[A]i: [A]ction',
      },
      {
        '<leader>ad',
        [[<Cmd>CodeCompanionChat Add<CR>]],
        mode = 'x',
        desc = '[A]i: [A]dd selection',
      },
      {
        '<leader>ab',
        [[:CodeCompanion /buffer ]],
        mode = 'x',
        desc = '[A]i: Analyze [B]uffer',
      },
      {
        '<leader>af',
        [[:CodeCompanion /fix ]],
        mode = 'x',
        desc = '[A]i: [F]ix code',
      },
      {
        '<leader>ae',
        [[:CodeCompanion /explain ]],
        mode = 'x',
        desc = '[A]i: [E]xplain code',
      },
      {
        '<leader>at',
        [[:CodeCompanion /tests ]],
        mode = 'x',
        desc = '[A]i: [T]est code',
      },
    },
    opts = {
      opts = {
        visible = true,
        language = 'spanish',
      },
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
          keymaps = {
            options = { modes = { n = 'g?' } },
            close = { modes = { n = 'gX', i = '<M-C-X>' } },
            stop = { modes = { n = '<C-c>' } },
            codeblock = { modes = { n = 'cdb' } },
            next_header = { modes = { n = ']#' } },
            previous_header = { modes = { n = '[#' } },
            next_chat = { modes = { n = ']}' } },
            previous_chat = { modes = { n = '[{' } },
            clear = { modes = { n = 'gC' } },
            fold_code = { modes = { n = 'gF' } },
            debug = { modes = { n = 'g<C-g>' } },
            change_adapter = { modes = { n = 'gA' } },
            system_prompt = { modes = { n = 'gS' } },
            pin = {
              modes = { n = 'g>' },
              description = 'Pin Reference (resend whole contents on change)',
            },
            watch = {
              modes = { n = 'g=' },
              description = 'Watch Buffer (send diffs on change)',
            },
          },
        },
        inline = {
          adapter = 'deepseek',
          keymaps = {
            accept_change = {
              modes = { n = 'gA' },
              callback = 'keymaps.accept_change',
            },
            reject_change = {
              modes = { n = 'gX' },
              callback = 'keymaps.reject_change',
            },
          },
        },
      },
      display = {
        chat = {
          icons = {
            pinned_buffer = icons.Pin,
            watched_buffer = icons.Eye,
          },
          intro_message = 'Welcome to CodeCompanion! Press `g?` for options',
          window = {
            layout = 'vertical',
            opts = {
              winbar = '', -- disable winbar in codecompanion chat buffers
              statuscolumn = '',
              foldcolumn = '0',
              linebreak = true,
              breakindent = true,
              wrap = true,
              spell = true,
              number = false,
            },
          },
        },
        diff = {
          close_chat_at = 0,
          layout = 'vertical',
        },
        inline = {
          layout = 'vertical',
        },
      },
    },
  },
}
