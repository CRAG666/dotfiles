local icons = require('utils.static.icons')
local key = require('utils.keymap')
local function setup()
  vim.pack.add({ { src = 'https://github.com/olimorris/codecompanion.nvim' } })
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
                    Actúa como un escritor experimentado en artículos científicos, especializado en la revisión y edición de textos académicos.
                  </role>
                  <task>
                    Realiza una revisión final del texto proporcionado, corrigiendo errores y mejorando su calidad para garantizar claridad, legibilidad y adherencia a estándares científicos.
                  </task>
                  <instructions>
                    <step1>
                      Identifica y corrige errores tipográficos, gramaticales, de puntuación o de redacción inapropiada.
                    </step1>
                    <step2>
                      Simplifica el lenguaje, eliminando jerga innecesaria, palabras de relleno o construcciones complejas que dificulten la comprensión.
                    </step2>
                    <step3>
                      Mejora la claridad y legibilidad, asegurando que el texto sea accesible para una audiencia académica multidisciplinar sin comprometer su rigor científico.
                    </step3>
                    <step4>
                      Asegúrate de que el texto cumpla con una guía de estilo científica coherente (por ejemplo, APA, AMA o la especificada por el usuario).
                    </step4>
                    <step5>
                      Conserva el propósito original del contenido, manteniendo la precisión técnica y el enfoque científico.
                    </step5>
                  </instructions>
                  <requirements>
                    - Usa puntuación adecuada y consistente según la guía de estilo seleccionada.
                    - Prioriza un lenguaje técnico preciso pero accesible, evitando ambigüedades.
                    - Mantén el tono formal y objetivo propio de la escritura científica.
                  </requirements>
                  <format>Devuelve el texto revisado con correcciones y mejoras aplicadas.</format>
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
                    Analiza el siguiente <text-input>texto proporcionado</text-input> y corrige cualquier error <orthography>ortográfico</orthography> o <grammar>gramatical</grammar> que encuentres.
                  </instruction>
                  <guidelines>
                    <guideline>
                      Mantén el <style>estilo</style> y el <tone>tono</tone> original del texto.
                    </guideline>
                    <guideline>
                      Mejora la <clarity>claridad</clarity> y la <coherence>coherencia</coherence> del mensaje solo si es estrictamente necesario, sin alterar significativamente el <content>contenido original</content>.
                    </guideline>
                  </guidelines>
                  <output>
                    Devuelve el texto corregido.
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
                    Traduce el siguiente <text-input>texto proporcionado</text-input> al <target-language>inglés</target-language> de manera precisa y natural, evitando traducciones literales.
                  </instruction>
                  <guidelines>
                    <guideline>
                      Asegúrate de que la traducción sea <fluency>fluida</fluency> y utilice <idiomatic-expressions>expresiones idiomáticas propias del inglés</idiomatic-expressions>, respetando el <style>estilo</style> y el <tone>tono</tone> del texto original.
                    </guideline>
                    <guideline>
                      Garantiza que la traducción transmita correctamente el <meaning>significado</meaning> del texto original y mantenga su <intent>propósito comunicativo</intent>.
                    </guideline>
                    <guideline>
                      Revisa la traducción para eliminar errores de <grammar>gramática</grammar>, <vocabulary>vocabulario</vocabulary> o <coherence>coherencia</coherence>, asegurando un resultado <professional>profesional</professional>.
                    </guideline>
                  </guidelines>
                  <output>
                    Proporciona la traducción final en inglés.
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
                    Traduce el siguiente <text-input>texto proporcionado</text-input> al <target-language>español</target-language> de manera precisa y natural, evitando traducciones literales.
                  </instruction>
                  <guidelines>
                    <guideline>
                      Asegúrate de que la traducción sea <fluency>fluida</fluency> y utilice <idiomatic-expressions>expresiones idiomáticas propias del español</idiomatic-expressions>, respetando el <style>estilo</style> y el <tone>tono</tone> del texto original.
                    </guideline>
                    <guideline>
                      Garantiza que la traducción transmita correctamente el <meaning>significado</meaning> del texto original y mantenga su <intent>propósito comunicativo</intent>.
                    </guideline>
                    <guideline>
                      Revisa la traducción para eliminar errores de <grammar>gramática</grammar>, <vocabulary>vocabulario</vocabulary> o <coherence>coherencia</coherence>, asegurando un resultado <professional>profesional</professional>.
                    </guideline>
                    <guideline>
                      Considera el <context>contexto cultural</context> del español para adaptar términos o expresiones cuando sea necesario, priorizando un lenguaje natural y apropiado para el público hispanohablante.
                    </guideline>
                  </guidelines>
                  <output>
                    Proporciona la traducción final en español.
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

local maps = {
  {
    'f',
    ':CodeCompanion /fix',
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
    ':CodeCompanion /buffer #wassistant',
    '[A]i: Writting Assistant',
  },
  {
    'e',
    ':CodeCompanion /buffer #translate',
    '[A]i: Translate to [e]nglish',
  },
  {
    's',
    ':CodeCompanion /buffer #traducir',
    '[A]i: Translate to [s]panish',
  },
  {
    'g',
    ':CodeCompanion /buffer #grammar',
    '[A]i: [G]rammar fix',
  },
  {
    'b',
    ':CodeCompanion /buffer',
    '[A]i: Add instructions',
  },
}
key.maps_lazy('codecompanion', setup, 'x', '<leader>a', maps)
