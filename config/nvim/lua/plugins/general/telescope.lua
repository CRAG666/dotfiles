local utils = require "utils.keymap"
local prefix_1 = "<leader>f"
local git_prefix = "<leader>g"
local lsp_prefix = "g"
local cwd_conf = {
  cwd = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
}

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        ";e",
        function()
          require("telescope").extensions.file_browser.file_browser()
        end,
        desc = "[e]xplorer",
      },
      {
        ";f",
        function()
          require("telescope").extensions.frecency.frecency()
        end,
        desc = "[f]requent Files",
      },
      {
        ";b",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "[b]uffers",
      },
      {
        ";o",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "[o]ld Files",
      },
      {
        ";t",
        function()
          require("telescope.builtin").treesitter()
        end,
        desc = "[t]reeSitter Symbols",
      },
      {
        ";;",
        function()
          local builtin = require "telescope.builtin"
          local opts = {} -- define here if you want to define something
          local ok = pcall(builtin.git_files, opts)
          if not ok then
            builtin.find_files(opts)
          end
        end,
        desc = "Project Files",
      },
      {
        ";m",
        function()
          require("telescope.builtin").marks()
        end,
        desc = "[f]ind [m]ars",
      },
      {
        prefix_1 .. "b",
        function()
          require("telescope.builtin").builtin()
        end,
        desc = "[f]ind [b]uiltin",
      },
      {
        prefix_1 .. "w",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "[f]ind [w]ord",
      },
      {
        prefix_1 .. "l",
        function()
          require("telescope.builtin").live_grep(cwd_conf)
        end,
        desc = "[f]ind [l]ive Grep",
      },
      {
        prefix_1 .. "h",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "[f]ind [h]elp tags",
      },
      {
        prefix_1 .. "s",
        function()
          require("telescope.builtin").search_history()
        end,
        desc = "[f]ind [s]earch History",
      },
      {
        prefix_1 .. "C",
        function()
          require("telescope.builtin").colorscheme()
        end,
        desc = "[f]ind [C]olorscheme",
      },
      {
        prefix_1 .. "c",
        function()
          require("telescope.builtin").commands()
        end,
        desc = "[f]ind [c]ommands",
      },
      {
        prefix_1 .. "H",
        function()
          require("telescope.builtin").command_history()
        end,
        desc = "[f]ind commands [H]istory",
      },
      {
        prefix_1 .. "k",
        function()
          require("telescope.builtin").keymaps()
        end,
        desc = "[f]ind [k]eymaps",
      },
      {
        prefix_1 .. "t",
        function()
          require("telescope.builtin").filetypes()
        end,
        desc = "[f]ile[t]ype",
      },
      {
        prefix_1 .. "f",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "[f]uzzy [f]ind",
      },
      {
        prefix_1 .. "j",
        function()
          require("telescope.builtin").jumplist()
        end,
        desc = "[f]ind [j]umplist",
      },
      {
        prefix_1 .. "q",
        function()
          require("telescope.builtin").quickfix()
        end,
        desc = "[f]ind [q]uickfix",
      },
      {
        prefix_1 .. "u",
        function()
          require("telescope").extensions.undo.undo()
        end,
        desc = "[f]ind undo",
      },
      {
        lsp_prefix .. "d",
        function()
          require("telescope.builtin").lsp_definitions()
        end,
        desc = "LSP [d]efinitions",
      },
      {
        lsp_prefix .. "R",
        function()
          require("telescope.builtin").lsp_references()
        end,
        desc = "LSP [r]eferences",
      },
      {
        lsp_prefix .. "s",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "LSP [s]ymbols",
      },
      {
        lsp_prefix .. "i",
        function()
          require("telescope.builtin").lsp_implementations()
        end,
        desc = "LSP [i]mplementations",
      },
      {
        ";dd",
        function()
          require("telescope.builtin").diagnostics { bufnr = 0 }
        end,
        desc = "LSP [d]iagnostics",
      },
      {
        ";dw",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "LSP [d]iagnostics Workspace",
      },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").spell_suggest {
            layout_strategy = "cursor",
            layout_config = {
              cursor = {
                height = 0.35,
                preview_cutoff = 0,
                width = 0.20,
              },
            },
          }
        end,
        desc = "[s]pell [s]uggest",
      },
      {
        git_prefix .. "b",
        function()
          require("telescope.builtin").git_branches()
        end,
        desc = "[g]it [b]ranches",
      },
      {
        git_prefix .. "S",
        function()
          require("telescope.builtin").git_stash()
        end,
        desc = "[g]it [S]tash",
      },
    },
    config = function()
      local actions = require "telescope.actions"
      local mappings = {
        i = {
          ["<CR>"] = actions.select_tab,
          ["<C-l>"] = actions.select_default,
        },
        n = {
          ["<CR>"] = actions.select_tab,
          ["l"] = actions.select_default,
        },
      }
      require("telescope").setup {
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
          prompt_prefix = "  ",
          selection_caret = "» ",
          entry_prefix = "  ",
          initial_mode = "normal",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "bottom_pane",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              -- preview_width = 0.55,
              -- results_width = 0.8,
              preview_cutoff = 0,
            },
            height = math.floor(vim.o.lines / 2),
            width = vim.o.columns,
            -- preview_cutoff = 120,
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,
          file_ignore_patterns = {},
          generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          path_display = { "absolute" },
          winblend = 0,
          border = {},
          borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
          color_devicons = true,
          use_less = true,
          set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
          -- Developer configurations: Not meant for general override
          buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
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
          ["zf-native"] = {
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
            ignore_patterns = { "*.git/*", "*/tmp/*" },
            workspaces = {
              ["dotfiles"] = "~/Git/dotfiles",
            },
          },
        },
      }
      local extensions = { "zf-native", "frecency", "file_browser", "undo" }
      for _, extension in ipairs(extensions) do
        require("telescope").load_extension(extension)
      end

      local builtin = require "telescope.builtin"
      local previewers = require "telescope.previewers"
      local delta_bcommits = previewers.new_termopen_previewer {
        get_command = function(entry)
          return {
            "git",
            "-c",
            "core.pager=delta",
            "-c",
            "delta.side-by-side=false",
            "diff",
            entry.value .. "^!",
            "--",
            entry.current_file,
          }
        end,
      }

      git_bcommits = function()
        local opt_commits = {}
        opt_commits.previewer = previewers.new_termopen_previewer {
          get_command = function(entry)
            return {
              "git",
              "-c",
              "core.pager=delta",
              "-c",
              "delta.pager=less -R",
              "show",
              entry.value,
            }
          end,
        }

        builtin.git_bcommits(opt_commits)
      end
      git_status = function()
        local opt_status = {}
        opt_status.previewer = previewers.new_termopen_previewer {
          get_command = function(entry)
            -- vim.print(entry)
            if entry.status == " D" then
              return { "git", "show", "HEAD:" .. entry.value }
            elseif entry.status == "??" then
              return { "bat", "--style=plain", entry.path }
            end
            return {
              "git",
              "-c",
              "core.pager=delta",
              "-c",
              "delta.pager=less -R",
              "diff",
              entry.path,
            }
          end,
        }
        local icons = require("utils.static.icons").git
        opt_status.git_icons = {
          added = icons.Added,
          changed = icons.Modified,
          copied = icons.Changedelete,
          deleted = icons.Removed,
          renamed = "R",
          unmerged = "U",
          untracked = icons.Untracked,
        }

        builtin.git_status(opt_status)
      end
      utils.map("n", git_prefix .. "c", git_bcommits, { desc = "[g]it Buffer [c]ommits" })
      utils.map("n", git_prefix .. "s", git_status, { desc = "[g]it [s]tatus" })
    end,
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "natecraddock/telescope-zf-native.nvim",
      "debugloop/telescope-undo.nvim",
      {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "kkharji/sqlite.lua" },
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
  },
}
