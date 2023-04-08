local utils = require "utils"
local prefix_1 = "<leader>f"
local prefix_2 = "<leader>g"
local keys = {
  { ";e", desc = "File Browser" },
  { ";f", desc = "Frequent Files" },
  { ";b", desc = "List Buffers" },
  { ";o", desc = "Old Files" },
  { ";t", desc = "TreeSitter Symbols" },
  { ";;", desc = "Project Files" },
  -- leader f prefix
  { prefix_1 .. "t", desc = "Telescope Builtin" },
  { prefix_1 .. ";", desc = "List Tabs" },
  { prefix_1 .. "m", desc = "Media Files" },
  { prefix_1 .. "g", desc = "Find Grep" },
  { prefix_1 .. "l", desc = "Find Live Grep" },
  { prefix_1 .. "h", desc = "Search History" },
  { prefix_1 .. "cc", desc = "Select Colorscheme" },
  { prefix_1 .. "cs", desc = "Search Commands" },
  { prefix_1 .. "ch", desc = "Search Commands History" },
  { prefix_1 .. "k", desc = "Show All Keymaps" },
  { prefix_1 .. "f", desc = "Select Filetype" },
  { prefix_1 .. "b", desc = "Buffer Fuzzy Find" },
  { prefix_1 .. "r", desc = "LSP References" },
  { prefix_1 .. "s", desc = "LSP Symbols" },
  { prefix_1 .. "i", desc = "LSP Implementations" },
  { prefix_1 .. "d", desc = "LSP diagnostics" },
  -- Git builtin
  { prefix_2 .. "c", desc = "Git Buffer commits" },
  { prefix_2 .. "b", desc = "Git Branches" },
  { prefix_2 .. "s", desc = "Git Status" },
  { prefix_2 .. "t", desc = "Git Stash" },
  -- {"<Leader>ft", require('telescope.builtin').help_tags)
  { "<leader>m", desc = "Show Marks" },
  { "<leader>ss", desc = "Spell Suggest" },
}

local function setup()
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
        "--trim", -- add this value
      },
      prompt_prefix = "  ",
      selection_caret = "» ",
      initial_mode = "normal",
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      -- layout_strategy = "bottom_pane",
      layout_strategy = "horizontal",
      layout_config = {
        bottom_pane = {
          prompt_position = "top",
          preview_cutoff = 0,
        },
        horizontal = {
          prompt_position = "top",
          preview_cutoff = 0,
        },
      },
      -- file_sorter = require("telescope.sorters").get_fuzzy_file,
      -- file_sorter = require("telescope.sorters").get_fzy_file,
      file_ignore_patterns = { "__pycache__", "node_modules" },
      path_display = { "shorten" },
      winblend = 0,
      border = {},
      -- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
      results_title = "Results",
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
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
      media_files = {
        filetypes = { "png", "webp", "jpg", "jpeg" },
        find_cmd = "rg", -- find command (defaults to `fd`)
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

  local extensions = { "frecency", "zf-native", "media_files", "file_browser" }
  for _, extension in ipairs(extensions) do
    require("telescope").load_extension(extension)
  end

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

  git_commits = function(opts)
    opts = opts or {}
    opts.previewer = {
      delta,
      previewers.git_commit_message.new(opts),
      previewers.git_commit_diff_as_was.new(opts),
    }
    builtin.git_commits(opts)
  end

  git_bcommits = function(opts)
    opts = opts or {}
    opts.previewer = {
      delta_bcommits,
      previewers.git_commit_message.new(opts),
      previewers.git_commit_diff_as_was.new(opts),
    }
    builtin.git_bcommits(opts)
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
    require("telescope-tabs").list_tabs,
    ext.media_files.media_files,
    function()
      builtin.grep_string(cwd_conf)
    end,
    function()
      builtin.live_grep(cwd_conf)
    end,
    builtin.search_history,
    builtin.colorscheme,
    builtin.commands,
    builtin.command_history,
    builtin.keymaps,
    builtin.filetypes,
    builtin.current_buffer_fuzzy_find,
    builtin.lsp_references,
    builtin.lsp_document_symbols,
    builtin.lsp_implementations,
    builtin.diagnostics,
    -- leader g prefix
    -- builtin.git_bcommits,
    git_bcommits,
    builtin.git_branches,
    builtin.git_status,
    builtin.git_stash,
    -- require('telescope.builtin').help_tags)
    builtin.marks,
    builtin.spell_suggest,
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
end

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = keys,
    config = setup,
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      -- "nvim-telescope/telescope-dap.nvim",
      "natecraddock/telescope-zf-native.nvim",
      {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "tami5/sqlite.lua" },
      },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-media-files.nvim",
    },
  },
  {
    "LukasPietzschmann/telescope-tabs",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = true,
  },
}
