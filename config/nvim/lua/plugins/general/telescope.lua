local utils = require "utils.keymap"
local prefix_1 = "<leader>f"
local prefix_2 = "<leader>g"
local prefix_3 = "<leader>l"
local keys = {
  { ";e", desc = "[e]xplorer" },
  { ";f", desc = "[f]requent Files" },
  { ";b", desc = "[b]uffers" },
  { ";o", desc = "[o]ld Files" },
  { ";t", desc = "[t]reeSitter Symbols" },
  { ";;", desc = "Project Files" },
  -- leader f prefix
  { prefix_1 .. "b", desc = "[f]ind [b]uiltin" },
  { prefix_1 .. "w", desc = "[f]ind [w]ord" },
  { prefix_1 .. "l", desc = "[f]ind [l]ive Grep" },
  { prefix_1 .. "h", desc = "[f]ind [h]elp tags" },
  { prefix_1 .. "s", desc = "[f]ind [s]earch History" },
  { prefix_1 .. "C", desc = "[f]ind [c]olor[s]cheme" },
  { prefix_1 .. "c", desc = "[f]ind [c]ommands" },
  { prefix_1 .. "H", desc = "[f]ind commands [H]istory" },
  { prefix_1 .. "k", desc = "[f]ind [k]eymaps" },
  { prefix_1 .. "t", desc = "[f]ile[t]ype" },
  { prefix_1 .. "f", desc = "[f]uzzy [f]ind" },
  { prefix_1 .. "m", desc = "[f]ind [m]ars" },
  { prefix_3 .. "r", desc = "[l]SP [r]eferences" },
  { prefix_3 .. "s", desc = "[l]SP [s]ymbols" },
  { prefix_3 .. "i", desc = "[l]SP [i]mplementations" },
  { prefix_3 .. "d", desc = "[l]SP [d]iagnostics" },
  -- Git builtin
  { prefix_2 .. "C", desc = "[g]it Buffer [c]ommits" },
  { prefix_2 .. "b", desc = "[g]it [b]ranches" },
  { prefix_2 .. "s", desc = "[g]it [s]tatus" },
  { prefix_2 .. "S", desc = "[g]it [S]tash" },
  { "<leader>ss", desc = "[s]pell [s]uggest" },
}

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = keys,
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
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
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
      local extensions = { "zf-native", "frecency", "file_browser" }
      for _, extension in ipairs(extensions) do
        require("telescope").load_extension(extension)
      end

      require("telescope-all-recent").setup {}

      local builtin = require "telescope.builtin"
      local ext = require("telescope").extensions

      -- File Pickers
      local project_files = function()
        local opts = {} -- define here if you want to define something
        local ok = pcall(builtin.git_files, opts)
        if not ok then
          builtin.find_files(opts)
        end
      end

      local cwd_conf = {
        cwd = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
      }

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

      local delta = previewers.new_termopen_previewer {
        get_command = function(entry)
          return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", entry.value .. "^!" }
        end,
      }

      Delta_git_commits = function(opts)
        opts = opts or {}
        opts.previewer = {
          delta,
          previewers.git_commit_message.new(opts),
          previewers.git_commit_diff_as_was.new(opts),
        }
        builtin.git_commits(opts)
      end

      Delta_git_bcommits = function(opts)
        opts = opts or {}
        opts.previewer = {
          delta_bcommits,
          previewers.git_commit_message.new(opts),
          previewers.git_commit_diff_as_was.new(opts),
        }
        builtin.git_bcommits(opts)
      end

      function spell_check()
        builtin.spell_suggest {
          layout_strategy = "cursor",
          layout_config = {
            cursor = {
              height = 0.35,
              preview_cutoff = 0,
              width = 0.20,
            },
          },
        }
      end

      maps = {
        ext.file_browser.file_browser,
        ext.frecency.frecency,
        builtin.buffers,
        builtin.oldfiles,
        builtin.treesitter,
        project_files,
        -- leader f prefix
        builtin.builtin,
        function()
          builtin.grep_string(cwd_conf)
        end,
        function()
          builtin.live_grep(cwd_conf)
        end,
        builtin.help_tags,
        builtin.search_history,
        builtin.colorscheme,
        builtin.commands,
        builtin.command_history,
        builtin.keymaps,
        builtin.filetypes,
        builtin.current_buffer_fuzzy_find,
        builtin.marks,
        builtin.lsp_references,
        builtin.lsp_document_symbols,
        builtin.lsp_implementations,
        builtin.diagnostics,
        -- leader g prefix
        -- builtin.git_bcommits,
        Delta_git_bcommits,
        builtin.git_branches,
        builtin.git_status,
        builtin.git_stash,
        -- builtin.spell_suggest,
        spell_check,
        -- utils.map('n', '<leader>bt', builtin.current_buffer_tags, { desc = "Buffer Tags" })

        -- -- LSP Pickers
        -- utils.map('n', '<leader>fd', builtin.lsp_definitions)
        --
        -- Git Pickers
        -- {"<leader>gc", builtin.git_commits)
      }

      for i, map in ipairs(keys) do
        utils.map("n", map[1], maps[i])
      end
    end,
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "natecraddock/telescope-zf-native.nvim",
      "prochri/telescope-all-recent.nvim",
      {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "kkharji/sqlite.lua" },
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
  },
}
