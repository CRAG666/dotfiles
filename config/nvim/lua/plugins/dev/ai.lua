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
        '<leader>aa',
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
        '<leader>ad',
        [[<Cmd>CodeCompanionChat Add<CR>]],
        mode = 'x',
        desc = '[A]i: [A]dd selection',
      },
      {
        '<leader>af',
        [[:CodeCompanion /fix ]],
        mode = 'x',
        desc = '[A]i: [F]ix code',
      },
      {
        '<leader>ac',
        [[:CodeCompanion /explain ]],
        mode = 'x',
        desc = '[A]i: Explain [c]ode',
      },
      {
        '<leader>at',
        [[:CodeCompanion /tests ]],
        mode = 'x',
        desc = '[A]i: [T]est code',
      },
      {
        '<leader>aw',
        [[:CodeCompanion /buffer #wassistant <cr>]],
        mode = 'x',
        desc = '[A]i: Writting Assistant',
      },
      {
        '<leader>ae',
        [[:CodeCompanion /buffer #translate <cr>]],
        mode = 'x',
        desc = '[A]i: Translate to [e]nglish',
      },
      {
        '<leader>as',
        [[:CodeCompanion /buffer #traducir <cr>]],
        mode = 'x',
        desc = '[A]i: Translate to [s]panish',
      },
      {
        '<leader>ag',
        [[:CodeCompanion /buffer #grammar <cr>]],
        mode = 'x',
        desc = '[A]i: [G]rammar fix',
      },
      {
        '<leader>ab',
        [[:CodeCompanion /buffer ]],
        mode = 'x',
        desc = '[A]i: Add instructions',
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
                -- default = 'deepseek-reasoner',
                default = 'deepseek-chat',
              },
            },
          })
        end,
      },
      prompt_library = {
        ["My New Prompt"] = {
          strategy = "chat",
          description = "Some cool custom prompt you can do",
          prompts = {
            {
              role = "system",
              content = "You are an experienced developer with Lua and Neovim",
            },
            {
              role = "user",
              content = "Can you explain why ..."
            }
          },
        }
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
                return
                [[
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
                return
                [[
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
                return
                [[
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
    },
  },
}

-- return {
--   "yetone/avante.nvim",
--   version = false,
--   build = "make",
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--     "MunifTanjim/nui.nvim",
--     {
--       "ravitemer/mcphub.nvim",
--       build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
--       config = function()
--         require("mcphub").setup({
--           use_bundled_binary = true, -- Use local `mcp-hub` binary
--         })
--       end,
--     }
--   },
--   keys = {
--     { "<leader>aa", "<cmd>Avante ask", desc = "Avante Ask" },
--   },
--   opts = {
--     provider = "deepseek",
--     vendors = {
--       deepseek = {
--         __inherited_from = "openai",
--         api_key_name = "DEEPSEEK_API_KEY",
--         endpoint = "https://api.deepseek.com",
--         model = "deepseek-coder",
--       },
--     },
--     file_selector = {
--       provider = "snacks",
--     },
--     -- behaviour = {
--     --   enable_claude_text_editor_tool_mode = true,
--     -- },
--     -- custom_tools = require("custom.avante.tools"),
--     -- system_prompt as function ensures LLM always has latest MCP server state
--     -- This is evaluated for every message, even in existing chats
--     system_prompt = function()
--       local hub = require("mcphub").get_hub_instance()
--       return hub and hub:get_active_servers_prompt() or ""
--     end,
--     -- Using function prevents requiring mcphub before it's loaded
--     custom_tools = function()
--       return {
--         require("mcphub.extensions.avante").mcp_tool(),
--       }
--     end,
--
--     disabled_tools = {
--       "list_files", -- Built-in file operations
--       "search_files",
--       "read_file",
--       "create_file",
--       "rename_file",
--       "delete_file",
--       "create_dir",
--       "rename_dir",
--       "delete_dir",
--       "bash", -- Built-in terminal access
--     },
--   }
-- }
