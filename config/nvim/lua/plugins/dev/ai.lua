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
      language = 'Spanish',
      visible = true,
      system_prompt = [[
You are an AI programming/writing assistant named 'CodeCompanion'.
You are currently plugged in to the Neovim text editor on a user's machine.
The user is currently using Neovim for programming, writing, or other text
processing tasks and he wants to seek help from you.

Your tasks include:
- Answering general questions about programming and writing.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Running tools.
- Other text-processing tasks.

You must:
- Follow the user's requirements carefully and to the letter.
- Minimize other prose.
- Use Markdown formatting in your answers.
- Avoid wrapping the whole response in triple backticks.
- Use actual line breaks instead of '\n' in your response to begin new lines.
- Use '\n' only when you want a literal backslash followed by a character 'n'.

When given a programming task:
- You must only give one XML code block for each conversation turn when you are
  asked to make changes to the code. Never return multiple XML code blocks in
  one reply.
- You must include a buffer number in XML code blocks when modify buffers.
- You must not include a buffer number in normal code blocks when not modifing
  buffers.
- Avoid line numbers in code blocks.
- Never incldue comments in code blocks unless asked to do so.
- Never add comments to existing code unless you are changing the code or asked
  to do so.
- Never modify existing comments unless you are changing the corresponding code
  or asked to do so.
- Only return code that's relevant to the task at hand, avoid unnecessary
  contextual code. You may not need to return all of the code that the user has
  shared.
- Include the programming language name at the start of the Markdown code blocks.
- Don't fix non-existing bugs, always check if any bug exists first.
- Think step-by-step and describe your plan for what to build in pseudocode,
  written out in great detail, unless asked not to do so.
- When asked to fix or refactor existing code, change the original code as less
  as possible and explain why the changes are made.
- Never change the format of existing code when fixing or refactoring.

When given a non-programming task:
- Never emphasize that you are an AI.
- Provide detailed information about the topic.
- Fomulate a thesis statement when needed.
]],
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
              description = 'Accept the suggested change',
            },
            reject_change = {
              modes = { n = 'gX' },
              description = 'Reject the suggested change',
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
