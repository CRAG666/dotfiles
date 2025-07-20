return {
  {
    'supermaven-inc/supermaven-nvim',
    event = 'InsertEnter',
    opts = {
      keymaps = {
        accept_suggestion = '<C-CR>',
        clear_suggestion = '<C-BS>',
        accept_word = '<C-J>',
      },
      ignore_filetypes = { 'bigfile' },
      -- disable_inline_completion = true,
      -- disable_keymaps = true,
    },
  },
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '*',
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
      'jc-doyle/cmp-pandoc-references',
      {
        'L3MON4D3/LuaSnip',
        -- version = 'v2.*',
        build = 'make install_jsregexp',
        event = 'ModeChanged *:[iRss\x13vV\x16]*',
        dependencies = {
          {
            'iurimateus/luasnip-latex-snippets.nvim',
            ft = { 'tex', 'bib' },
            config = function()
              require('luasnip-latex-snippets').setup({ use_treesitter = true })
            end,
          },
        },
        config = function()
          local ls = require('luasnip')
          local ls_types = require('luasnip.util.types')
          local ls_ft = require('luasnip.extras.filetype_functions')
          local utils = require('utils')

          ---Load snippets for a given filetype
          ---@param ft string?
          local function load_snippets(ft)
            ft = ft or vim.bo.ft

            utils.ft.load_once('snippets', ft, function(_, snips)
              if not snips or vim.tbl_isempty(snips) then
                return false
              end
              for _, group in pairs(snips) do
                ls.add_snippets(ft, group.snip or group, group.opts or {})
              end
              return true
            end)
          end

          ls.setup({
            ft_func = function()
              load_snippets('all')
              local langs = ls_ft.from_pos_or_filetype()
              for _, lang in ipairs(langs) do
                load_snippets(lang)
              end
              return langs
            end,
            keep_roots = true,
            link_roots = true,
            exit_roots = false,
            link_children = true,
            region_check_events = 'CursorMoved,CursorMovedI,InsertEnter',
            delete_check_events = 'TextChanged,TextChangedI,InsertLeave',
            enable_autosnippets = true,
            cut_selection_keys = '<Tab>',
            ext_opts = {
              [ls_types.choiceNode] = {
                active = {
                  virt_text = {
                    {
                      utils.static.icons.ArrowUpDown,
                      'Number',
                    },
                  },
                },
              },
            },
          })
        end,
      },
      {
        'saghen/blink.compat',
        version = '*',
        opts = {},
      },
      'mikavilpas/blink-ripgrep.nvim',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'enter' },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = { auto_show = true },
        ghost_text = { enabled = false },
        list = { selection = { preselect = false } },
        menu = {
          draw = {
            columns = {
              { 'kind_icon' },
              { 'label',    'label_description', gap = 1, 'kind' },
            },
            components = {
              kind_icon = {
                text = function(ctx)
                  return ' ' .. ctx.kind_icon .. ctx.icon_gap .. ' '
                end,
              },
              kind = {
                text = function(ctx)
                  return '(' .. ctx.kind .. ')'
                end,
                highlight = function(ctx)
                  return 'BlinkCmpCustomType'
                end,
              },
            },
          },
        },
      },
      sources = {
        default = {
          'snippets',
          'lsp',
          'path',
          'buffer',
          'ripgrep',
        },
        per_filetype = {
          codecompanion = { 'codecompanion' },
          markdown = {
            'snippets',
            'lsp',
            'path',
            'buffer',
            'ripgrep',
            'pandoc_references',
          },
          norg = {
            'snippets',
            'lsp',
            'path',
            'buffer',
            'ripgrep',
          },
          quarto = {
            'snippets',
            'lsp',
            'path',
            'buffer',
            'ripgrep',
            'pandoc_references',
          },
          tex = {
            'snippets',
            'lsp',
            'path',
            'buffer',
            'ripgrep',
            'pandoc_references',
          },
        },
        -- cmdline = {},
        providers = {
          ripgrep = {
            module = 'blink-ripgrep',
            name = 'Ripgrep',
            score_offset = -4,
            -- the options below are optional, some default values are shown
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              -- For many options, see `rg --help` for an exact description of
              -- the values that ripgrep expects.

              -- the minimum length of the current word to start searching
              -- (if the word is shorter than this, the search will not start)
              prefix_min_len = 3,

              -- The number of lines to show around each match in the preview window
              context_size = 5,

              -- The maximum file size that ripgrep should include in its search.
              -- Useful when your project contains large files that might cause
              -- performance issues.
              -- Examples: "1024" (bytes by default), "200K", "1M", "1G"
              max_filesize = '1G',
            },
          },
          pandoc_references = {
            name = 'pandoc_references',
            module = 'blink.compat.source',
            score_offset = -1,
          },
          snippets = {
            score_offset = 100,
          },
          lsp = {
            score_offset = 99,
          },
        },
      },
      snippets = { preset = 'luasnip' },
      signature = { enabled = true },
    },
    opts_extend = { 'sources.default' },
  },
}
