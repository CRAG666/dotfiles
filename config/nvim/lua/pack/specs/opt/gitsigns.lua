---@type pack.spec
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
        worktrees = {
          -- Make gitsigns aware of bare repo for dotfiles
          -- https://github.com/lewis6991/gitsigns.nvim/pull/600
          {
            toplevel = vim.uv.os_homedir(),
            gitdir = vim.env.DOT_DIR,
          },
        },
      })

      -- Setup keymaps
      -- Navigation
      -- stylua: ignore start
      vim.keymap.set({ 'n', 'x' }, '[g', function() gs.nav_hunk('prev') end, { desc = 'Go to previous git hunk' })
      vim.keymap.set({ 'n', 'x' }, ']g', function() gs.nav_hunk('next') end, { desc = 'Go to next git hunk' })
      vim.keymap.set({ 'n', 'x' }, '[G', function() gs.nav_hunk('first') end, { desc = 'Go to first git hunk' })
      vim.keymap.set({ 'n', 'x' }, ']G', function() gs.nav_hunk('last') end, { desc = 'Go to last git hunk' })
      -- stylua: ignore end

      -- Actions
      -- stylua: ignore start
      ---@diagnostic disable-next-line: deprecated
      vim.keymap.set('n', '<Leader>gu', gs.undo_stage_hunk, { desc = 'Git unstage current hunk' })
      vim.keymap.set('n', '<Leader>gs', gs.stage_hunk, { desc = 'Git stage current hunk' })
      vim.keymap.set('n', '<Leader>gr', gs.reset_hunk, { desc = 'Git reset current hunk' })
      vim.keymap.set('n', '<Leader>gU', gs.reset_buffer_index, { desc = 'Git unstage current buffer' })
      vim.keymap.set('n', '<Leader>gS', gs.stage_buffer, { desc = 'Git stage current buffer' })
      vim.keymap.set('n', '<Leader>gR', gs.reset_buffer, { desc = 'Git reset current buffer' })
      vim.keymap.set('n', '<Leader>gp', gs.preview_hunk, { desc = 'Git preview current hunk' })
      vim.keymap.set('n', '<Leader>gb', gs.blame_line, { desc = 'Git blame current line' })
      vim.keymap.set('n', '<Leader>gg', gs.setloclist, { desc = 'Git list file hunks' })
      vim.keymap.set('n', '<Leader>gG', function() gs.setqflist('all') end, { desc = 'Git list repo hunks' })
      vim.keymap.set('x', '<Leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v'), }) end, { desc = 'Git stage current selection' })
      vim.keymap.set('x', '<Leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v'), }) end, { desc = 'Git reset current selection' })
      vim.keymap.set('n', '<Leader>g<Esc>', '<Nop>')
      vim.keymap.set('x', '<Leader>g<Esc>', '<Nop>')
      -- stylua: ignore end

      -- Text object
      -- stylua: ignore start
      vim.keymap.set({ 'o', 'x' }, 'ig', ':<C-u>Gitsigns select_hunk<CR>', { silent = true, desc = 'Select git hunk' })
      vim.keymap.set({ 'o', 'x' }, 'ag', ':<C-u>Gitsigns select_hunk<CR>', { silent = true, desc = 'Select git hunk' })
      -- stylua: ignore end

      -- Auto-refresh fugitive buffers on staging/unstaging hunks
      vim.api.nvim_create_autocmd('User', {
        pattern = 'GitSignsChanged',
        desc = 'Automatically refresh fugitive buffers on staging/unstaging hunks.',
        group = vim.api.nvim_create_augroup(
          'my.gitsigns.fugitive_integration',
          {}
        ),
        callback = function(args)
          local file = args.data.file ---@type string
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            -- Only update fugitive buffers that matches the updated file
            if
              vim.bo[buf].ft == 'fugitive'
              and require('utils.fs').contains(
                vim.fn.fnamemodify(
                  vim.api.nvim_buf_get_name(buf):match('fugitive://(.*)'),
                  ':h:h'
                ),
                file
              )
            then
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                  vim.api.nvim_buf_call(buf, vim.cmd.edit)
                end
              end)
              break
            end
          end
        end,
      })
    end,
  },
}
