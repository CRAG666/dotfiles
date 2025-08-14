local icons = require('utils.static.icons')
local key = require('utils.keymap')

-- ============================================================================
-- SNACKS CONFIGURATION (Migrated from lazy.nvim structure)
-- ============================================================================

-- Add Snacks plugin
vim.pack.add({ { src = 'https://github.com/folke/snacks.nvim' } })
local snacks = require('snacks')

-- Setup Snacks
snacks.setup({
  animate = { enabled = true },
  indent = { enabled = true },
  scope = { enabled = true },
  bigfile = { enabled = true },
  layout = { enabled = true },
  picker = {
    enabled = true,
    layout = {
      preview = 'main',
      layout = {
        backdrop = false,
        width = 40,
        min_width = 40,
        height = 0,
        position = 'right',
        border = 'none',
        box = 'vertical',
        {
          win = 'input',
          height = 1,
          border = 'rounded',
          title = '{title} {live} {flags}',
          title_pos = 'center',
        },
        { win = 'list', border = 'none' },
        { win = 'preview', title = '{preview}', height = 0.4, border = 'top' },
      },
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
    timeout = 3000,
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

-- ============================================================================
-- SNACKS KEYMAPS
-- ============================================================================

-- Top Pickers & Explorer
key.map('n', '<leader>,', function()
  snacks.picker.buffers()
end, { desc = 'Buffers' })
key.map('n', '<leader>/', function()
  snacks.picker.grep()
end, { desc = 'Grep' })
key.map('n', '<leader>:', function()
  snacks.picker.command_history()
end, { desc = 'Command History' })
key.map('n', '<leader>.', function()
  snacks.explorer()
end, { desc = 'File Explorer' })

-- Find
key.map('n', '<leader>fb', function()
  snacks.picker.buffers()
end, { desc = 'Buffers' })
key.map('n', '<leader>fc', function()
  snacks.picker.files({ cwd = vim.fn.stdpath('config') })
end, { desc = 'Find Config File' })
key.map('n', '<leader>fd', function()
  snacks.picker.files()
end, { desc = 'Find Files in directory' })
key.map('n', '<leader>ff', function()
  snacks.picker.files({ cwd = vim.lsp.buf.list_workspace_folders()[1] or '.' })
end, { desc = 'Find Files in root path' })
key.map('n', '<leader>fg', function()
  snacks.picker.git_files()
end, { desc = 'Find Git Files' })
key.map('n', '<leader>fp', function()
  snacks.picker.projects()
end, { desc = 'Projects' })
key.map('n', '<leader>fr', function()
  snacks.picker.recent()
end, { desc = 'Recent' })

-- Git
key.map('n', '<leader>gb', function()
  snacks.picker.git_branches()
end, { desc = 'Git Branches' })
key.map('n', '<leader>gl', function()
  snacks.picker.git_log()
end, { desc = 'Git Log' })
key.map('n', '<leader>gL', function()
  snacks.picker.git_log_line()
end, { desc = 'Git Log Line' })
key.map('n', '<leader>gs', function()
  snacks.picker.git_status()
end, { desc = 'Git Status' })
key.map('n', '<leader>gS', function()
  snacks.picker.git_stash()
end, { desc = 'Git Stash' })
key.map('n', '<leader>gd', function()
  snacks.picker.git_diff()
end, { desc = 'Git Diff (Hunks)' })
key.map('n', '<leader>gf', function()
  snacks.picker.git_log_file()
end, { desc = 'Git Log File' })

-- Grep
key.map('n', '<leader>sB', function()
  snacks.picker.grep_buffers()
end, { desc = 'Grep Open Buffers' })
key.map('n', '<leader>sg', function()
  snacks.picker.grep()
end, { desc = 'Grep' })
key.map({ 'n', 'x' }, '<leader>sw', function()
  snacks.picker.grep_word()
end, { desc = 'Visual selection or word' })

-- Search
key.map('n', '<leader>s"', function()
  snacks.picker.registers()
end, { desc = 'Registers' })
key.map('n', '<leader>s/', function()
  snacks.picker.search_history()
end, { desc = 'Search History' })
key.map('n', '<leader>sa', function()
  snacks.picker.autocmds()
end, { desc = 'Autocmds' })
key.map('n', '<leader>sb', function()
  snacks.picker.lines()
end, { desc = 'Buffer Lines' })
key.map('n', '<leader>sc', function()
  snacks.picker.command_history()
end, { desc = 'Command History' })
key.map('n', '<leader>sC', function()
  snacks.picker.commands()
end, { desc = 'Commands' })
key.map('n', '<leader>sD', function()
  snacks.picker.diagnostics()
end, { desc = 'Diagnostics' })
key.map('n', '<leader>sd', function()
  snacks.picker.diagnostics_buffer()
end, { desc = 'Buffer Diagnostics' })
key.map('n', '<leader>sh', function()
  snacks.picker.help()
end, { desc = 'Help Pages' })
key.map('n', '<leader>sH', function()
  snacks.picker.highlights()
end, { desc = 'Highlights' })
key.map('n', '<leader>si', function()
  snacks.picker.icons()
end, { desc = 'Icons' })
key.map('n', '<leader>sj', function()
  snacks.picker.jumps()
end, { desc = 'Jumps' })
key.map('n', '<leader>sk', function()
  snacks.picker.keymaps()
end, { desc = 'Keymaps' })
key.map('n', '<leader>sl', function()
  snacks.picker.loclist()
end, { desc = 'Location List' })
key.map('n', '<leader>sm', function()
  snacks.picker.marks()
end, { desc = 'Marks' })
key.map('n', '<leader>sM', function()
  snacks.picker.man()
end, { desc = 'Man Pages' })
-- key.map('n', '<leader>sp', function()
--   snacks.picker.lazy()
-- end, { desc = 'Search for Plugin Spec' })
key.map('n', '<leader>sq', function()
  snacks.picker.qflist()
end, { desc = 'Quickfix List' })
key.map('n', '<leader>sR', function()
  snacks.picker.resume()
end, { desc = 'Resume' })
key.map('n', '<leader>su', function()
  snacks.picker.undo()
end, { desc = 'Undo History' })
key.map('n', '<leader>uC', function()
  snacks.picker.colorschemes()
end, { desc = 'Colorschemes' })

-- LSP
key.map('n', 'gd', function()
  snacks.picker.lsp_definitions()
end, { desc = 'Goto Definition' })
key.map('n', 'gD', function()
  snacks.picker.lsp_declarations()
end, { desc = 'Goto Declaration' })
key.map('n', 'gR', function()
  snacks.picker.lsp_references()
end, { desc = 'References', nowait = true })
key.map('n', 'gI', function()
  snacks.picker.lsp_implementations()
end, { desc = 'Goto Implementation' })
key.map('n', 'gy', function()
  snacks.picker.lsp_type_definitions()
end, { desc = 'Goto T[y]pe Definition' })
key.map('n', '<leader>ss', function()
  snacks.picker.lsp_symbols()
end, { desc = 'LSP Symbols' })
key.map('n', '<leader>sS', function()
  snacks.picker.lsp_workspace_symbols()
end, { desc = 'LSP Workspace Symbols' })

-- Other
key.map('n', '<leader>x', function()
  snacks.scratch()
end, { desc = 'Toggle Scratch Buffer' })
key.map('n', '<leader>S', function()
  snacks.scratch.select()
end, { desc = 'Select Scratch Buffer' })
key.map('n', '<leader>bd', function()
  snacks.bufdelete()
end, { desc = 'Delete Buffer' })
key.map('n', '<leader>cR', function()
  snacks.rename.rename_file()
end, { desc = 'Rename File' })
key.map('n', '<leader>un', function()
  snacks.notifier.hide()
end, { desc = 'Dismiss All Notifications' })
key.map({ 'n', 't' }, ']]', function()
  snacks.words.jump(vim.v.count1)
end, { desc = 'Next Reference' })
key.map({ 'n', 't' }, '[[', function()
  snacks.words.jump(-vim.v.count1)
end, { desc = 'Prev Reference' })

-- Neovim News
key.map('n', '<leader>N', function()
  snacks.win({
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
end, { desc = 'Neovim News' })
