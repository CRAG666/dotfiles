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
      {
        '<leader>aw',
        [[:CodeCompanion /buffer #wassistant <cr>]],
        mode = 'x',
        desc = '[A]i: Writting Assistant',
      },
      {
        '<leader>ai',
        [[:CodeCompanion /buffer #translate <cr>]],
        mode = 'x',
        desc = '[A]i: Translate to Engl[i]sh',
      },
      {
        '<leader>as',
        [[:CodeCompanion /buffer #traducir <cr>]],
        mode = 'x',
        desc = '[A]i: Translate to Engl[i]sh',
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
              -- Actúa como un escritor de articulos cientificos experimentado, enfocándote en mejorar la claridad y legibilidad del texto. Eres responsable de revisar un el texto. Simplifica las oraciones sin perder el significado ni los matices originales. Usa la puntuación adecuada, simplifica el lenguaje y elimina cualquier jerga innecesaria o palabras de relleno. Asegúrate de que el contenido se ajuste a una guía de estilo coherente y conserve su propósito original, a la vez que sea más fácil de leer y comprender.
              callback = function()
                return [[
                Como escritor experimentado en articulos cientificos, tu tarea es realizar una revisión final del texto. Identifica y corrige cualquier error tipográfico, gramatical, redacción inapropiada u otros pequeños errores que se hayan pasado por alto. Ademas enfocate en mejorar la claridad y legibilidad del texto. Eres responsable de revisar un el texto. Usa la puntuación adecuada, simplifica el lenguaje y elimina cualquier jerga innecesaria o palabras de relleno. Asegúrate de que el contenido se ajuste a una guía de estilo coherente en materia cientifica y conserve su propósito original, a la vez que sea más fácil de leer y comprender.
                ]]
              end,
              description = 'My Cientific Writting assistant',
              opts = {
                contains_code = true,
              },
            },
            ['translate'] = {
              ---@return string
              callback = function()
                return
                [[Por favor, traduce el siguiente texto al inglés de manera precisa y natural, evitando traducciones literales. Asegúrate de que la traducción suene fluida y respete el estilo y las expresiones propias del inglés, transmitiendo correctamente el significado y el tono del texto original. Revisa la traducción para eliminar cualquier error gramatical o de vocabulario, y garantiza que el texto sea coherente y profesional.]]
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
                [[Por favor, traduce el siguiente texto al español de manera precisa y natural, evitando traducciones literales. Asegúrate de que la traducción suene fluida y respete el estilo y las expresiones propias del español, transmitiendo correctamente el significado y el tono del texto original. Revisa la traducción para eliminar cualquier error gramatical o de vocabulario, y garantiza que el texto sea coherente y profesional.]]
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
