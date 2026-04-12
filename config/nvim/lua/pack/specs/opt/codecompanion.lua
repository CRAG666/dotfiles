local prefix = '<leader>a'
return {
  src = 'https://github.com/olimorris/codecompanion.nvim',
  data = {
    deps = {
      {
        src = 'https://github.com/nvim-lua/plenary.nvim',
        data = { optional = false },
      },
      {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter',
        data = { optional = false },
      },
      {
        src = 'https://github.com/saghen/blink.cmp',
        data = { optional = false },
      },
    },
    keys = {
      {
        lhs = prefix .. 'a',
        opts = { desc = '[A]i: Toggle' },
      },
      {
        lhs = prefix .. 'p',
        opts = { desc = '[A]i: Action [P]alette' },
      },
      {
        mode = 'x',
        lhs = prefix .. 'd',
        opts = { desc = '[A]i: [A]dd selection' },
      },
      {
        mode = 'x',
        lhs = prefix .. 'f',
        opts = { desc = '[A]i: [F]ix code' },
      },
      {
        mode = 'x',
        lhs = prefix .. 'e',
        opts = { desc = '[A]i: [E]xplain code' },
      },
      {
        mode = 'x',
        lhs = prefix .. 't',
        opts = { desc = '[A]i: [T]est code' },
      },
      {
        mode = 'x',
        lhs = prefix .. 'g',
        opts = { desc = '[A]i: [G]rammar and spelling' },
      },
      {
        mode = 'x',
        lhs = prefix .. 'i',
        opts = { desc = '[A]i: Translate to Engl[i]sh' },
      },
    },
    postload = function()
      require('codecompanion').setup({
        opts = {
          visible = true,
          language = 'spanish',
        },
        adapters = {
          http = {
            -- deepseek = function()
            --   return require('codecompanion.adapters').extend('deepseek', {
            --     env = {
            --       api_key = 'cmd:gak ai/deepseek',
            --     },
            --     schema = {
            --       model = {
            --         -- default = 'deepseek-reasoner',
            --         default = 'deepseek-chat',
            --       },
            --     },
            --   })
            -- end,
            nvidia_nim = function()
              return require('codecompanion.adapters').extend('openai', {
                name = 'nvidia_nim',
                url = 'https://integrate.api.nvidia.com/v1/chat/completions',
                env = {
                  api_key = 'NVIDIA_API_KEY',
                },
                schema = {
                  model = {
                    default = 'stepfun-ai/step-3.5-flash',
                    -- default = 'deepseek-ai/deepseek-v3.2',
                    -- default = 'nvidia/nemotron-3-nano-30b-a3b',
                    -- default = 'z-ai/glm5',
                    -- default = 'minimaxai/minimax-m2.7',
                  },
                },
              })
            end,
          },
        },
        prompt_library = {
          ['Translate to English'] = {
            interaction = 'inline',
            description = 'Translate to English',
            opts = {
              alias = 'tr_en',
              modes = { 'v' },
              placement = 'replace',
              ignore_system_prompt = true,
            },
            prompts = {
              {
                role = 'user',
                content = [[You are a professional Spanish-to-English translator. Your task is to produce an accurate, natural-sounding English translation of the text below.

                Rules:
                - Preserve the original tone, register, and formatting
                - Do not add, remove, or explain anything
                - Output ONLY the translated text, nothing else

                Text to translate:
                #{selection}]],
              },
            },
          },
          ['Fix Grammar and Spelling'] = {
            interaction = 'inline',
            description = 'Correct spelling and grammar',
            opts = {
              alias = 'fix_gs',
              modes = { 'v' },
              placement = 'replace',
              ignore_system_prompt = true,
            },
            prompts = {
              {
                role = 'user',
                content = [[You are a professional copy editor. Your task is to correct ONLY spelling, grammar, and punctuation errors in the text below.

                Rules:
                - Fix errors silently — do not explain any change
                - Do NOT rephrase, restructure, or improve sentences
                - Do NOT change vocabulary or word choice
                - Preserve the original language (do not translate)
                - Preserve the author's tone, style, and voice
                - Output ONLY the corrected text, nothing else

                Text to correct:
                #{selection}]],
              },
            },
          },
        },
        interactions = {
          chat = {
            adapter = 'nvidia_nim',
          },
          inline = {
            adapter = 'nvidia_nim',
          },
          cmd = {
            adapter = 'nvidia_nim',
          },
        },
      })
      local key = require('utils.keymap')
      local normal_keys = {
        {
          'a',
          [[:CodeCompanionChat Toggle<CR>]],
          '[A]i: Toggle',
        },
        {
          'p',
          [[:CodeCompanionActions<CR>]],
          '[A]i: Action [P]alette',
        },
      }
      key.pmaps('n', prefix, normal_keys)

      local visual_keys = {
        {
          'd',
          [[:CodeCompanionChat Add<CR>]],
          '[A]i: [A]dd selection',
        },
        {
          'f',
          [[:CodeCompanion /fix ]],
          '[A]i: [F]ix code',
        },
        {
          'e',
          [[:CodeCompanion /explain ]],
          '[A]i: [E]xplain code',
        },
        {
          't',
          [[:CodeCompanion /tests ]],
          '[A]i: [T]est code',
        },
        {
          'g',
          [[:CodeCompanion /fix_gs<CR>]],
          '[A]i: [G]rammar and spelling',
        },
        {
          'i',
          [[:CodeCompanion /tr_en<CR>]],
          '[A]i: Translate to Engl[i]sh',
        },
      }
      key.pmaps('x', prefix, visual_keys)
    end,
  },
}
