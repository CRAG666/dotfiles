local icons = require('utils.static.icons')
local key = require('utils.keymap')
local function setup()
  vim.pack.add({
    'https://github.com/olimorris/codecompanion.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
  })
  require('codecompanion').setup({
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
              -- default = 'deepseek-reasoner',
              default = 'deepseek-chat',
            },
          },
        })
      end,
    },
    prompt_library = {
      ['My New Prompt'] = {
        strategy = 'chat',
        description = 'Some cool custom prompt you can do',
        prompts = {
          {
            role = 'system',
            content = 'You are an experienced developer with Lua and Neovim',
          },
          {
            role = 'user',
            content = 'Can you explain why ...',
          },
        },
      },
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
        variables = {
          ['wassistant'] = {
            ---@return string
            callback = function()
              return [[
                <prompt>
                  <role>
                    Act as an experienced writer of scientific articles, specializing in the review and editing of academic texts.
                  </role>
                  <task>
                    Conduct a final review of the provided text, correcting errors and enhancing its quality to ensure clarity, readability, and adherence to scientific standards.
                  </task>
                  <instructions>
                    <step1>
                      Identify and correct typographical, grammatical, punctuation, or inappropriate wording errors.
                    </step1>
                    <step2>
                      Simplify the language, eliminating unnecessary jargon, filler words, or complex constructions that hinder comprehension.
                    </step2>
                    <step3>
                      Enhance clarity and readability, ensuring the text is accessible to a multidisciplinary academic audience without compromising its scientific rigor.
                    </step3>
                    <step4>
                      Ensure the text adheres to a consistent scientific style guide (e.g., APA, AMA, or as specified by the user).
                    </step4>
                    <step5>
                      Preserve the original purpose of the content, maintaining technical accuracy and a scientific focus.
                    </step5>
                  </instructions>
                  <requirements>
                    - Use appropriate and consistent punctuation according to the selected style guide.
                    - Prioritize precise yet accessible technical language, avoiding ambiguities.
                    - Maintain a formal and objective tone typical of scientific writing.
                  </requirements>
                  <format>Return the revised text with corrections and improvements applied.</format>
                </prompt>
              ]]
            end,
            description = 'My Cientific Writting assistant',
            opts = {
              contains_code = true,
            },
          },
          ['grammar'] = {
            ---@return string
            callback = function()
              return [[
                <prompt>
                  <instruction>
                    Analyze the text and correct any <orthography>spelling</orthography> or <grammar>grammatical</grammar> errors found.
                  </instruction>
                  <guidelines>
                    <guideline>
                      Maintain the <style>style</style> and <tone>tone</tone> of the original text.
                    </guideline>
                    <guideline>
                      Improve the <clarity>clarity</clarity> and <coherence>coherence</coherence> of the message only if strictly necessary, without significantly altering the <content>original content</content>.
                    </guideline>
                  </guidelines>
                  <output>
                    Provide the corrected text.
                  </output>
                </prompt>
                ]]
            end,
            description = 'Grammar Checker',
            opts = {
              contains_code = true,
            },
          },
          ['translate'] = {
            ---@return string
            callback = function()
              return [[
                <prompt>
                  <instruction>
                    Translate into <target-language>English</target-language> accurately and naturally, avoiding literal translations.
                  </instruction>
                  <guidelines>
                    <guideline>
                      Ensure the translation is <fluency>fluent</fluency> and uses <idiomatic-expressions>idiomatic expressions native to English</idiomatic-expressions>, respecting the <style>style</style> and <tone>tone</tone> of the original text.
                    </guideline>
                    <guideline>
                      Guarantee the translation accurately conveys the <meaning>meaning</meaning> of the original text and maintains its <intent>communicative purpose</intent>.
                    </guideline>
                    <guideline>
                      Review the translation to eliminate errors in <grammar>grammar</grammar>, <vocabulary>vocabulary</vocabulary>, or <coherence>coherence</coherence>, ensuring a <professional>professional</professional> result.
                    </guideline>
                    <guideline>
                      Consider the <context>cultural context</context> of English to adapt terms or expressions when necessary, prioritizing natural and appropriate language for an American audience.
                    </guideline>
                  </guidelines>
                  <output>
                    Provide the final translation in English.
                  </output>
                </prompt>
              ]]
            end,
            description = 'Translate to English',
            opts = {
              contains_code = true,
            },
          },
          ['traducir'] = {
            ---@return string
            callback = function()
              return [[
                <prompt>
                  <instruction>
                    Translate into <target-language>Spanish</target-language> accurately and naturally, avoiding literal translations.
                  </instruction>
                  <guidelines>
                    <guideline>
                      Ensure the translation is <fluency>fluent</fluency> and uses <idiomatic-expressions>idiomatic expressions native to Spanish</idiomatic-expressions>, respecting the <style>style</style> and <tone>tone</tone> of the original text.
                    </guideline>
                    <guideline>
                      Guarantee the translation accurately conveys the <meaning>meaning</meaning> of the original text and maintains its <intent>communicative purpose</intent>.
                    </guideline>
                    <guideline>
                      Review the translation to eliminate errors in <grammar>grammar</grammar>, <vocabulary>vocabulary</vocabulary>, or <coherence>coherence</coherence>, ensuring a <professional>professional</professional> result.
                    </guideline>
                    <guideline>
                      Consider the <context>cultural context</context> of Spanish to adapt terms or expressions when necessary, prioritizing natural and appropriate language for an Mexican audience.
                    </guideline>
                  </guidelines>
                  <output>
                    Provide the final translation in Spanish.
                  </output>
                </prompt>
              ]]
            end,
            description = 'Translate to English',
            opts = {
              contains_code = true,
            },
          },
        },
      },
      cmd = {
        adapter = 'deepseek',
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
        layout = 'horizontal',
      },
      inline = {
        layout = 'vertical',
      },
    },
  })
end

key.map_lazy('codecompanion', setup, 'n', '<leader>aa', function()
  require('codecompanion').toggle()
end, { desc = 'Tab [n]ew' })

key.map_lazy(
  'codecompanion',
  setup,
  'n',
  '<leader>ap',
  [[<Cmd>CodeCompanionActions<CR>]],
  { desc = 'Tab [n]ew' }
)

local maps = {
  {
    'f',
    [[:CodeCompanion /fix ]],
    '[A]i: [A]dd selection',
  },
  {
    'c',
    ':CodeCompanion /explain',
    '[A]i: Explain [c]ode',
  },
  {
    't',
    ':CodeCompanion /tests',
    '[A]i: [T]est code',
  },
  {
    'w',
    ':CodeCompanion /buffer #wassistant<CR>',
    '[A]i: Writting Assistant',
  },
  {
    'e',
    ':CodeCompanion /buffer #translate<CR>',
    '[A]i: Translate to [e]nglish',
  },
  {
    's',
    ':CodeCompanion /buffer #traducir<CR>',
    '[A]i: Translate to [s]panish',
  },
  {
    'g',
    ':CodeCompanion /buffer #grammar<CR>',
    '[A]i: [G]rammar fix',
  },
  {
    'b',
    [[:CodeCompanion /buffer ]],
    '[A]i: Add instructions',
  },
}

key.pmaps('x', '<leader>a', maps)
