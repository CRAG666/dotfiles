return {
  src = 'https://github.com/folke/snacks.nvim',
  data = {
    deps = {
      {
        src = 'https://github.com/kyazdani42/nvim-web-devicons',
        data = { optional = true },
      },
    },
    postload = function()
      require('snacks').setup({
        animate = { enabled = false },
        scroll = { enabled = false },
        bigfile = { enabled = true },
        statuscolumn = { enabled = false },
        dim = { enabled = true },
        indent = { enabled = true },
        scope = { enabled = true },
        layout = { enabled = true },
        picker = {
          enabled = true,
          layout = {
            preset = 'sidebar',
            layout = { position = 'right' },
          },
          previewers = {
            diff = {
              builtin = false,
            },
            git = {
              builtin = false,
            },
          },
        },
        image = { enabled = true },
        explorer = { enabled = true },
        quickfile = { enabled = false },
        input = { enabled = true },
        notifier = {
          enabled = true,
        },
        words = { enabled = true },
        dashboard = {
          enabled = true,
          sections = {
            {
              section = 'terminal',
              cmd = 'npx oh-my-logo@latest "Aguilar" fire --filled',
              height = 8,
              padding = 1,
            },
            {
              -- pane = 2,
              { section = 'keys', gap = 1, padding = 1 },
            },
            {
              icon = ' ',
              title = 'Recent Files',
              section = 'recent_files',
              indent = 2,
              padding = 1,
            },
            {
              icon = ' ',
              title = 'Projects',
              section = 'projects',
              indent = 2,
              padding = 1,
            },
          },
        },
      })

      local key = require('utils.keymap')

      local top_leader_maps = {
        {
          ',',
          function()
            require('snacks').picker.buffers()
          end,
          'Buffers',
        },
        {
          '/',
          function()
            require('snacks').picker.grep()
          end,
          'Grep',
        },
        {
          ':',
          function()
            require('snacks').picker.command_history()
          end,
          'Command History',
        },
        {
          '.',
          function()
            require('snacks').explorer()
          end,
          'File Explorer',
        },
        {
          'x',
          function()
            require('snacks').scratch()
          end,
          'Toggle Scratch Buffer',
        },
        {
          'S',
          function()
            require('snacks').scratch.select()
          end,
          'Select Scratch Buffer',
        },
        {
          'bd',
          function()
            require('snacks').bufdelete()
          end,
          'Delete Buffer',
        },
        {
          'cR',
          function()
            require('snacks').rename.rename_file()
          end,
          'Rename File',
        },
        {
          'un',
          function()
            require('snacks').notifier.hide()
          end,
          'Dismiss All Notifications',
        },
        {
          'N',
          function()
            require('snacks').win({
              file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
              width = 0.6,
              height = 0.6,
              wo = {
                spell = false,
                wrap = false,
                signcolumn = 'yes',
                statuscolumn = ' ',
                conceallevel = 3,
              },
            })
          end,
          'Neovim News',
        },
      }
      key.pmaps('n', '<leader>', top_leader_maps)

      local find_maps = {
        {
          'b',
          function()
            require('snacks').picker.buffers()
          end,
          'Buffers',
        },
        {
          'c',
          function()
            require('snacks').picker.files({ cwd = vim.fn.stdpath('config') })
          end,
          'Find Config File',
        },
        {
          'd',
          function()
            require('snacks').picker.files()
          end,
          'Find Files in directory',
        },
        {
          'f',
          function()
            require('snacks').picker.files({
              cwd = vim.lsp.buf.list_workspace_folders()[1] or '.',
            })
          end,
          'Find Files in root path',
        },
        {
          'g',
          function()
            require('snacks').picker.git_files()
          end,
          'Find Git Files',
        },
        {
          'p',
          function()
            require('snacks').picker.projects()
          end,
          'Projects',
        },
        {
          'r',
          function()
            require('snacks').picker.recent()
          end,
          'Recent',
        },
      }
      key.pmaps('n', '<leader>f', find_maps)

      local git_maps = {
        {
          'b',
          function()
            require('snacks').picker.git_branches()
          end,
          'Git Branches',
        },
        {
          'l',
          function()
            require('snacks').picker.git_log()
          end,
          'Git Log',
        },
        {
          'L',
          function()
            require('snacks').picker.git_log_line()
          end,
          'Git Log Line',
        },
        {
          's',
          function()
            require('snacks').picker.git_status()
          end,
          'Git Status',
        },
        {
          'S',
          function()
            require('snacks').picker.git_stash()
          end,
          'Git Stash',
        },
        {
          'd',
          function()
            require('snacks').picker.git_diff()
          end,
          'Git Diff (Hunks)',
        },
        {
          'f',
          function()
            require('snacks').picker.git_log_file()
          end,
          'Git Log File',
        },
      }
      key.pmaps('n', '<leader>g', git_maps)

      local search_maps = {
        {
          'B',
          function()
            require('snacks').picker.grep_buffers()
          end,
          'Grep Open Buffers',
        },
        {
          'g',
          function()
            require('snacks').picker.grep()
          end,
          'Grep',
        },
        {
          '"',
          function()
            require('snacks').picker.registers()
          end,
          'Registers',
        },
        {
          '/',
          function()
            require('snacks').picker.search_history()
          end,
          'Search History',
        },
        {
          'a',
          function()
            require('snacks').picker.autocmds()
          end,
          'Autocmds',
        },
        {
          'b',
          function()
            require('snacks').picker.lines()
          end,
          'Buffer Lines',
        },
        {
          'c',
          function()
            require('snacks').picker.command_history()
          end,
          'Command History',
        },
        {
          'C',
          function()
            require('snacks').picker.commands()
          end,
          'Commands',
        },
        {
          'D',
          function()
            require('snacks').picker.diagnostics()
          end,
          'Diagnostics',
        },
        {
          'd',
          function()
            require('snacks').picker.diagnostics_buffer()
          end,
          'Buffer Diagnostics',
        },
        {
          'h',
          function()
            require('snacks').picker.help()
          end,
          'Help Pages',
        },
        {
          'H',
          function()
            require('snacks').picker.highlights()
          end,
          'Highlights',
        },
        {
          'i',
          function()
            require('snacks').picker.icons()
          end,
          'Icons',
        },
        {
          'j',
          function()
            require('snacks').picker.jumps()
          end,
          'Jumps',
        },
        {
          'k',
          function()
            require('snacks').picker.keymaps()
          end,
          'Keymaps',
        },
        {
          'l',
          function()
            require('snacks').picker.loclist()
          end,
          'Location List',
        },
        {
          'm',
          function()
            require('snacks').picker.marks()
          end,
          'Marks',
        },
        {
          'M',
          function()
            require('snacks').picker.man()
          end,
          'Man Pages',
        },
        {
          'q',
          function()
            require('snacks').picker.qflist()
          end,
          'Quickfix List',
        },
        {
          'R',
          function()
            require('snacks').picker.resume()
          end,
          'Resume',
        },
        {
          'u',
          function()
            require('snacks').picker.undo()
          end,
          'Undo History',
        },
        {
          's',
          function()
            require('snacks').picker.lsp_symbols()
          end,
          'LSP Symbols',
        },
        {
          'S',
          function()
            require('snacks').picker.lsp_workspace_symbols()
          end,
          'LSP Workspace Symbols',
        },
      }

      key.map({ 'n', 'x' }, '<leader>sw', function()
        require('snacks').picker.grep_word()
      end, { desc = 'Visual selection or word' })

      key.pmaps('n', '<leader>s', search_maps)

      key.map('n', '<leader>uC', function()
        require('snacks').picker.colorschemes()
      end, { desc = 'Colorschemes' })

      local lsp_maps = {
        {
          'd',
          function()
            require('snacks').picker.lsp_definitions()
          end,
          'Goto Definition',
        },
        {
          'D',
          function()
            require('snacks').picker.lsp_declarations()
          end,
          'Goto Declaration',
        },
        {
          'R',
          function()
            require('snacks').picker.lsp_references()
          end,
          'References',
          { nowait = true },
        },
        {
          'I',
          function()
            require('snacks').picker.lsp_implementations()
          end,
          'Goto Implementation',
        },
        {
          'y',
          function()
            require('snacks').picker.lsp_type_definitions()
          end,
          'Goto T[y]pe Definition',
        },
      }

      key.pmaps('n', 'g', lsp_maps)

      key.map({ 'n', 't' }, ']]', function()
        require('snacks').words.jump(vim.v.count1)
      end, { desc = 'Next Reference' })
      key.map({ 'n', 't' }, '[[', function()
        require('snacks').words.jump(-vim.v.count1)
      end, { desc = 'Prev Reference' })
    end,
  },
}
