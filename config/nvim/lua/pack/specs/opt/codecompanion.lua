local p = '<leader>a'
local keys = {
  {
    mode = 'n',
    lhs = p .. 'a',
    rhs = function()
      require('codecompanion').toggle()
    end,
    opts = { desc = 'Toggle CodeCompanion' },
  },
  {
    mode = 'n',
    lhs = p .. 'p',
    rhs = '<Cmd>CodeCompanionActions<CR>',
    opts = { desc = 'CodeCompanion Actions' },
  },
  {
    mode = 'x',
    lhs = p .. 'w',
    rhs = ':CodeCompanion /buffer #wassistant<CR>',
    opts = { desc = '[A]i: Writting Assistant' },
  },
  {
    mode = 'x',
    lhs = p .. 'e',
    rhs = ':CodeCompanion /buffer #translate<CR>',
    opts = { desc = '[A]i: Translate to [e]nglish' },
  },
  {
    mode = 'x',
    lhs = p .. 's',
    rhs = ':CodeCompanion /buffer #traducir<CR>',
    opts = { desc = '[A]i: Translate to [s]panish' },
  },
  {
    mode = 'x',
    lhs = p .. 'g',
    rhs = ':CodeCompanion /buffer #grammar<CR>',
    opts = { desc = '[A]i: [G]rammar fix' },
  },
  {
    mode = 'x',
    lhs = p .. 'f',
    rhs = [[:CodeCompanion /fix ]],
    opts = { desc = '[A]i: [A]dd selection' },
  },
  {
    mode = 'x',
    lhs = p .. 'c',
    rhs = ':CodeCompanion /explain',
    opts = { desc = '[A]i: Explain [c]ode' },
  },
  {
    mode = 'x',
    lhs = p .. 't',
    rhs = ':CodeCompanion /tests',
    opts = { desc = '[A]i: [T]est code' },
  },
  {
    mode = 'x',
    lhs = p .. 'b',
    rhs = [[:CodeCompanion /buffer ]],
    opts = { desc = '[A]i: Add instructions' },
  },
}

return {
  src = 'https://github.com/olimorris/codecompanion.nvim',
  data = {
    deps = {
      { src = 'https://github.com/nvim-lua/plenary.nvim' },
    },
    keys = keys,
    postload = function()
      local icons = require('utils.static.icons')
      require('codecompanion').setup({
        opts = {
          visible = true,
          language = 'spanish',
        },
        adapters = {
          http = {
            deepseek = function()
              return require('codecompanion.adapters').extend('deepseek', {
                env = {
                  api_key = 'cmd:gak ai/deepseek',
                  -- api_key = 'DEEPSEEK_API_KEY',
                },
                schema = {
                  model = {
                    default = 'deepseek-reasoner',
                    -- default = 'deepseek-chat',
                  },
                },
              })
            end,
            upstage = function()
              return require('codecompanion.adapters').extend(
                'openai_compatible',
                {
                  env = {
                    url = 'https://api.upstage.ai',
                    api_key = 'cmd:gak ai/upstage',
                    chat_url = '/v1/chat/completions',
                    models_endpoint = '/v1/models',
                  },
                  schema = {
                    model = {
                      default = 'solar-pro2',
                    },
                  },
                }
              )
            end,
          },
          acp = {
            gemini_cli = function()
              return require('codecompanion.adapters').extend('gemini_cli', {
                env = {
                  api_key = 'GEMINI_API_KEY',
                },
              })
            end,
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
            adapter = 'upstage',
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
                    Role: You are an experienced writer of scientific articles, specializing in reviewing and editing academic texts to ensure they meet high scholarly standards.
                    Task: Conduct a comprehensive final review of the provided text, refining it to improve clarity, readability, and adherence to academic writing conventions while humanizing the tone to make it engaging and accessible to a broad academic audience.
                    Instructions

                    Correct Errors: Identify and correct any typographical, grammatical, punctuation, or wording errors to ensure the text is accurate and professional.
                    Simplify Language: Streamline the text by eliminating unnecessary jargon, filler words, or complex phrasing to enhance comprehension without compromising precision.
                    Enhance Clarity and Readability: Revise the text to ensure it is clear, concise, and engaging for a multidisciplinary academic audience, maintaining its scientific rigor.
                    Humanize the Tone: Adjust the language to be natural and relatable, using active voice where appropriate, avoiding overly formal or rigid phrasing, and ensuring a professional yet approachable tone.
                    Adhere to a Style Guide: Ensure the text follows a consistent scientific style guide (e.g., APA, AMA, or as specified by the user) for formatting, citations, and terminology.
                    Preserve Intent: Maintain the text’s original purpose, ensuring technical accuracy and a focus on scientific content while incorporating humanized elements.

                    Requirements:
                    Use consistent and appropriate punctuation as per the chosen style guide.
                    Employ precise, accessible technical language to avoid ambiguity.
                    Maintain a formal yet approachable tone suitable for scientific writing, balancing objectivity with a natural, engaging style.
                    Ensure humanization enhances readability by using concise, relatable language without sacrificing academic rigor.

                    Format: Provide the revised text with all corrections, enhancements, and humanization applied.
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
            adapter = 'upstage',
          },
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

      for _, k in ipairs(keys) do
        vim.keymap.set(k.mode, k.lhs, k.rhs)
      end
    end,
  },
}
