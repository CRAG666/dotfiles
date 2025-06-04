return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      -- Top Pickers & Explorer
      -- { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
      { "<leader>,",  function() Snacks.picker.buffers() end,                                                       desc = "Buffers" },
      { "<leader>/",  function() Snacks.picker.grep() end,                                                          desc = "Grep" },
      { "<leader>:",  function() Snacks.picker.command_history() end,                                               desc = "Command History" },
      -- { "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "Notification History" },
      { "<leader>.",  function() Snacks.explorer() end,                                                             desc = "File Explorer" },
      -- find
      { "<leader>fb", function() Snacks.picker.buffers() end,                                                       desc = "Buffers" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,                       desc = "Find Config File" },
      { "<leader>fd", function() Snacks.picker.files() end,                                                         desc = "Find Files in directory" },
      { "<leader>ff", function() Snacks.picker.files({ cwd = vim.lsp.buf.list_workspace_folders()[1] or "." }) end, desc = "Find Files in root path" },
      { "<leader>fg", function() Snacks.picker.git_files() end,                                                     desc = "Find Git Files" },
      { "<leader>fp", function() Snacks.picker.projects() end,                                                      desc = "Projects" },
      { "<leader>fr", function() Snacks.picker.recent() end,                                                        desc = "Recent" },
      -- git
      { "<leader>gb", function() Snacks.picker.git_branches() end,                                                  desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log() end,                                                       desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end,                                                  desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end,                                                    desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end,                                                     desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end,                                                      desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end,                                                  desc = "Git Log File" },
      -- Grep
      { "<leader>sB", function() Snacks.picker.grep_buffers() end,                                                  desc = "Grep Open Buffers" },
      { "<leader>sg", function() Snacks.picker.grep() end,                                                          desc = "Grep" },
      { "<leader>sw", function() Snacks.picker.grep_word() end,                                                     desc = "Visual selection or word", mode = { "n", "x" } },
      -- search
      { '<leader>s"', function() Snacks.picker.registers() end,                                                     desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history() end,                                                desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end,                                                      desc = "Autocmds" },
      { "<leader>sb", function() Snacks.picker.lines() end,                                                         desc = "Buffer Lines" },
      { "<leader>sc", function() Snacks.picker.command_history() end,                                               desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end,                                                      desc = "Commands" },
      { "<leader>sD", function() Snacks.picker.diagnostics() end,                                                   desc = "Diagnostics" },
      { "<leader>sd", function() Snacks.picker.diagnostics_buffer() end,                                            desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end,                                                          desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end,                                                    desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end,                                                         desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end,                                                         desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end,                                                       desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end,                                                       desc = "Location List" },
      { "<leader>sm", function() Snacks.picker.marks() end,                                                         desc = "Marks" },
      { "<leader>sM", function() Snacks.picker.man() end,                                                           desc = "Man Pages" },
      { "<leader>sp", function() Snacks.picker.lazy() end,                                                          desc = "Search for Plugin Spec" },
      { "<leader>sq", function() Snacks.picker.qflist() end,                                                        desc = "Quickfix List" },
      { "<leader>sR", function() Snacks.picker.resume() end,                                                        desc = "Resume" },
      { "<leader>su", function() Snacks.picker.undo() end,                                                          desc = "Undo History" },
      { "<leader>uC", function() Snacks.picker.colorschemes() end,                                                  desc = "Colorschemes" },
      -- LSP
      { "gd",         function() Snacks.picker.lsp_definitions() end,                                               desc = "Goto Definition" },
      { "gD",         function() Snacks.picker.lsp_declarations() end,                                              desc = "Goto Declaration" },
      { "gR",         function() Snacks.picker.lsp_references() end,                                                nowait = true,                     desc = "References" },
      { "gI",         function() Snacks.picker.lsp_implementations() end,                                           desc = "Goto Implementation" },
      { "gy",         function() Snacks.picker.lsp_type_definitions() end,                                          desc = "Goto T[y]pe Definition" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end,                                                   desc = "LSP Symbols" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,                                         desc = "LSP Workspace Symbols" },
      -- Other
      { "<leader>x",  function() Snacks.scratch() end,                                                              desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end,                                                       desc = "Select Scratch Buffer" },
      { "<leader>bd", function() Snacks.bufdelete() end,                                                            desc = "Delete Buffer" },
      { "<leader>cR", function() Snacks.rename.rename_file() end,                                                   desc = "Rename File" },
      { "<leader>un", function() Snacks.notifier.hide() end,                                                        desc = "Dismiss All Notifications" },
      { "]]",         function() Snacks.words.jump(vim.v.count1) end,                                               desc = "Next Reference",           mode = { "n", "t" } },
      { "[[",         function() Snacks.words.jump(-vim.v.count1) end,                                              desc = "Prev Reference",           mode = { "n", "t" } },
      {
        "<leader>N",
        desc = "Neovim News",
        function()
          Snacks.win({
            file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "yes",
              statuscolumn = " ",
              conceallevel = 3,
            },
          })
        end,
      }
    }, --@type snacks.Config
    opts = {
      animate = { enabled = true },
      indent = { enabled = true },
      scope = { enabled = true },
      bigfile = { enabled = true },
      layout = { enabled = true },
      picker = {
        enabled = true,
        -- layout = { preset = "ivy" },
        previewers = {
          diff = {
            builtin = false,
          },
          git = {
            builtin = false,
          },
        }
      },
      image = { enabled = true },
      explorer = { enabled = true },
      quickfile = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      words = { enabled = true },
    },
  }
}
