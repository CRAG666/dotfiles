return {
  src = 'https://github.com/lewis6991/gitsigns.nvim',
  data = {
    events = { 'BufReadPre', 'SessionLoadPost' },
    cmds = 'Gitsigns',
    keys = { lhs = '<Leader>gG', opts = { desc = 'Git list repo hunks' } },
    postload = function()
      local icons = require('utils').static.icons
      local gs = require('gitsigns')

      gs.setup({
        preview_config = {
          border = 'solid',
          style = 'minimal',
        },
        signs = {
          add = { text = vim.trim(icons.GitSignAdd) },
          untracked = { text = vim.trim(icons.GitSignUntracked) },
          change = { text = vim.trim(icons.GitSignChange) },
          delete = { text = vim.trim(icons.GitSignDelete) },
          topdelete = { text = vim.trim(icons.GitSignTopdelete) },
          changedelete = { text = vim.trim(icons.GitSignChangedelete) },
        },
        signs_staged_enable = false,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 100,
        },
      })

      on_attach = function(buffer)
    local gs = package.loaded.gitsigns
    vim.keymap.set({ 'n', 'x' }, '[c', function()
      gs.nav_hunk('prev')
    end, { desc = 'Go to previous git hunk' })
    vim.keymap.set({ 'n', 'x' }, ']c', function()
      gs.nav_hunk('next')
    end, { desc = 'Go to next git hunk' })
    vim.keymap.set({ 'n', 'x' }, '[C', function()
      gs.nav_hunk('first')
    end, { desc = 'Go to first git hunk' })
    vim.keymap.set({ 'n', 'x' }, ']C', function()
      gs.nav_hunk('last')
    end, { desc = 'Go to last git hunk' })

    vim.keymap.set(
      'n',
      '<Leader>ghs',
      gs.stage_hunk,
      { desc = 'Git stage current hunk' }
    )
    vim.keymap.set(
      'n',
      '<Leader>gr',
      gs.reset_hunk,
      { desc = 'Git reset current hunk' }
    )
    vim.keymap.set(
      'n',
      '<Leader>ghS',
      gs.stage_buffer,
      { desc = 'Git stage current buffer' }
    )
    vim.keymap.set(
      'n',
      '<Leader>gR',
      gs.reset_buffer,
      { desc = 'Git reset current buffer' }
    )
    vim.keymap.set(
      'n',
      '<Leader>gp',
      gs.preview_hunk,
      { desc = 'Git preview current hunk' }
    )
    vim.keymap.set(
      'n',
      '<Leader>ghb',
      gs.blame_line,
      { desc = 'Git blame current line' }
    )
    vim.keymap.set(
      'n',
      '<Leader>gq',
      gs.setloclist,
      { desc = 'Git list file hunks' }
    )
    vim.keymap.set('n', '<Leader>gQ', function()
      gs.setqflist('all')
    end, { desc = 'Git list repo hunks' })
    vim.keymap.set('n', '<Leader>g<Esc>', '<Nop>')

    vim.keymap.set('x', '<Leader>gs', function()
      gs.stage_hunk({
        vim.fn.line('.'),
        vim.fn.line('v'),
      })
    end, { desc = 'Git stage current selection' })
    vim.keymap.set('x', '<Leader>gr', function()
      gs.reset_hunk({
        vim.fn.line('.'),
        vim.fn.line('v'),
      })
    end, { desc = 'Git reset current selection' })

    vim.keymap.set(
      { 'o', 'x' },
      'ic',
      ':<C-u>Gitsigns select_hunk<CR>',
      { silent = true, desc = 'Select git hunk' }
    )
    vim.keymap.set(
      { 'o', 'x' },
      'ac',
      ':<C-u>Gitsigns select_hunk<CR>',
      { silent = true, desc = 'Select git hunk' }
    )
  end,
    end,
  },
}
