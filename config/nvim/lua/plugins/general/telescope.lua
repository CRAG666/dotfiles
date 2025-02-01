local utils = require('utils.keymap')
local fn = require('utils.fn')
local border = require('utils.static.borders')
local prefix_1 = '<leader>f'
local git_prefix = '<leader>g'
local lsp_prefix = 'g'
local cwd_conf = {
  cwd = vim.fs.dirname(vim.fs.find({ '.git' }, { upward = true })[1]),
}

return {
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      {
        ';e',
        fn.telescope_ext('file_browser'),
        desc = '[e]xplorer',
      },
      {
        ';f',
        fn.telescope_ext('frecency'),
        desc = '[f]requent Files',
      },
      {
        ';b',
        fn.telescope('buffers'),
        desc = '[b]uffers',
      },
      {
        ';o',
        fn.telescope('oldfiles'),
        desc = '[o]ld Files',
      },
      {
        ';s',
        fn.telescope('treesitter'),
        desc = '[t]reeSitter Symbols',
      },
      {
        ';;',
        function()
          local builtin = require('telescope.builtin')
          local opts = {} -- define here if you want to define something
          local ok = pcall(builtin.git_files, opts)
          if not ok then
            builtin.find_files(opts)
          end
        end,
        desc = 'Project Files',
      },
      {
        ';m',
        fn.telescope('marks'),
        desc = '[f]ind [m]ars',
      },
      {
        prefix_1 .. 'b',
        fn.telescope('builtin'),
        desc = '[f]ind [b]uiltin',
      },
      {
        prefix_1 .. 'w',
        fn.telescope('grep_string'),
        desc = '[f]ind [w]ord',
      },
      {
        prefix_1 .. 'l',
        fn.telescope('live_grep', cwd_conf),
        desc = '[f]ind [l]ive Grep',
      },
      {
        prefix_1 .. 'h',
        fn.telescope('help_tags'),
        desc = '[f]ind [h]elp tags',
      },
      {
        prefix_1 .. 's',
        fn.telescope('search_history'),
        desc = '[f]ind [s]earch History',
      },
      {
        prefix_1 .. 'C',
        fn.telescope('colorscheme'),
        desc = '[f]ind [C]olorscheme',
      },
      {
        prefix_1 .. 'c',
        fn.telescope('commands'),
        desc = '[f]ind [c]ommands',
      },
      {
        prefix_1 .. 'H',
        fn.telescope('command_history'),
        desc = '[f]ind commands [H]istory',
      },
      {
        prefix_1 .. 'k',
        fn.telescope('keymaps'),
        desc = '[f]ind [k]eymaps',
      },
      {
        prefix_1 .. 't',
        fn.telescope('filetypes'),
        desc = '[f]ile[t]ype',
      },
      {
        prefix_1 .. 'f',
        fn.telescope('current_buffer_fuzzy_find'),
        desc = '[f]uzzy [f]ind',
      },
      {
        prefix_1 .. 'j',
        fn.telescope('jumplist'),
        desc = '[f]ind [j]umplist',
      },
      {
        prefix_1 .. 'q',
        fn.telescope('quickfix'),
        desc = '[f]ind [q]uickfix',
      },
      {
        prefix_1 .. 'u',
        fn.telescope_ext('undo'),
        desc = '[f]ind undo',
      },
      {
        lsp_prefix .. 'd',
        fn.telescope('lsp_definitions'),
        desc = 'LSP [d]efinitions',
      },
      {
        lsp_prefix .. 'R',
        fn.telescope('lsp_references'),
        desc = 'LSP [r]eferences',
      },
      {
        lsp_prefix .. 's',
        fn.telescope('lsp_document_symbols'),
        desc = 'LSP [s]ymbols',
      },
      {
        lsp_prefix .. 'i',
        fn.telescope('lsp_implementations'),
        desc = 'LSP [i]mplementations',
      },
      {
        ';dd',
        fn.telescope('diagnostics', { bufnr = 0 }),
        desc = 'LSP [d]iagnostics',
      },
      {
        ';dw',
        fn.telescope('diagnostics'),
        desc = 'LSP [d]iagnostics Workspace',
      },
      {
        '<leader>ss',
        fn.telescope('spell_suggest', {
          layout_strategy = 'cursor',
          layout_config = {
            cursor = {
              height = 0.35,
              preview_cutoff = 0,
              width = 0.20,
            },
          },
        }),
        desc = '[s]pell [s]uggest',
      },
      {
        git_prefix .. 'b',
        fn.telescope('git_branches'),
        desc = 'Git [b]ranches',
      },
      {
        git_prefix .. 'S',
        fn.telescope('git_stash'),
        desc = 'Git [S]tash',
      },
    },
    config = function()
      local actions = require('telescope.actions')
      local previewers = require('telescope.previewers')
      local mappings = {
        i = {
          ['<CR>'] = actions.select_tab,
          ['<C-l>'] = actions.select_default,
        },
        n = {
          ['<CR>'] = actions.select_tab,
          ['l'] = actions.select_default,
        },
      }
      require('telescope').setup({
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
          },
          prompt_prefix = '  ',
          selection_caret = '» ',
          entry_prefix = '  ',
          initial_mode = 'normal',
          selection_strategy = 'reset',
          sorting_strategy = 'ascending',
          layout_strategy = 'bottom_pane',
          -- layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = 'top',
              -- preview_width = 0.55,
              -- results_width = 0.8,
              preview_cutoff = 0,
            },
            height = math.floor(vim.o.lines / 2),
            width = vim.o.columns,
            -- preview_cutoff = 120,
          },
          -- file_sorter = require("telescope.sorters").get_fuzzy_file,
          file_ignore_patterns = {},
          -- generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          path_display = { 'absolute' },
          winblend = 0,
          border = {},
          borderchars = border.rounded_clc,
          color_devicons = true,
          use_less = true,
          set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
          file_previewer = previewers.vim_buffer_cat.new,
          grep_previewer = previewers.vim_buffer_vimgrep.new,
          qflist_previewer = previewers.vim_buffer_qflist.new,
          -- Developer configurations: Not meant for general override
          buffer_previewer_maker = previewers.buffer_previewer_maker,
        },
        pickers = {
          find_files = {
            find_command = { 'fd', '--type', 'f', '--strip-cwd-prefix' },
            mappings = mappings,
          },
          git_files = {
            mappings = mappings,
          },
          oldfiles = {
            mappings = mappings,
          },
          live_grep = {
            mappings = mappings,
          },
          grep_string = {
            mappings = mappings,
          },
          current_buffer_fuzzy_find = {
            previewer = false,
          },
        },
        extensions = {
          ['zf-native'] = {
            -- options for sorting file-like items
            file = {
              -- override default telescope file sorter
              enable = true,

              -- highlight matching text in results
              highlight_results = true,

              -- enable zf filename match priority
              match_filename = true,

              -- optional function to define a sort order when the query is empty
              initial_sort = nil,

              -- set to false to enable case sensitive matching
              smart_case = true,
            },

            -- options for sorting all other items
            generic = {
              -- override default telescope generic item sorter
              enable = true,

              -- highlight matching text in results
              highlight_results = true,

              -- disable zf filename match priority
              match_filename = false,

              -- optional function to define a sort order when the query is empty
              initial_sort = nil,

              -- set to false to enable case sensitive matching
              smart_case = true,
            },
          },
          file_browser = {
            -- hijack_netrw = true,
            mappings = mappings,
          },
          frecency = {
            mappings = mappings,
            show_unindexed = false,
            ignore_patterns = { '*.git/*', '*/tmp/*' },
            workspaces = {
              ['dotfiles'] = '~/Git/dotfiles',
            },
          },
        },
      })
      local extensions = { 'zf-native', 'frecency', 'file_browser', 'undo' }
      for _, extension in ipairs(extensions) do
        require('telescope').load_extension(extension)
      end

      local builtin = require('telescope.builtin')

      git_bcommits = function()
        local opt_commits = {}
        opt_commits.previewer = previewers.new_termopen_previewer({
          get_command = function(entry)
            return {
              'git',
              '-c',
              'core.pager=delta',
              '-c',
              'delta.pager=less -R',
              'show',
              entry.value,
            }
          end,
        })

        builtin.git_bcommits(opt_commits)
      end
      git_status = function()
        local opt_status = {}
        opt_status.previewer = previewers.new_termopen_previewer({
          get_command = function(entry)
            -- vim.print(entry)
            if entry.status == ' D' then
              return { 'git', 'show', 'HEAD:' .. entry.value }
            elseif entry.status == '??' then
              return { 'bat', '--style=plain', entry.path }
            end
            return {
              'git',
              '-c',
              'core.pager=delta',
              '-c',
              'delta.pager=less -R',
              'diff',
              entry.path,
            }
          end,
        })
        local icons = require('utils.static.icons').git
        opt_status.git_icons = {
          added = icons.Added,
          changed = icons.Modified,
          copied = icons.Changedelete,
          deleted = icons.Removed,
          renamed = 'R',
          unmerged = 'U',
          untracked = icons.Untracked,
        }

        builtin.git_status(opt_status)
      end
      utils.map(
        'n',
        git_prefix .. 'c',
        git_bcommits,
        { desc = 'Git Buffer [c]ommits' }
      )
      utils.map('n', git_prefix .. 's', git_status, { desc = 'Git [s]tatus' })
    end,
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'natecraddock/telescope-zf-native.nvim',
      'debugloop/telescope-undo.nvim',
      {
        'nvim-telescope/telescope-frecency.nvim',
        dependencies = { 'kkharji/sqlite.lua' },
      },
      'nvim-telescope/telescope-file-browser.nvim',
    },
  },
}
