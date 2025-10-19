---@type pack.spec
return {
  src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  -- 'main' branch uses `vim.treesitter` module and does not depend on
  -- nvim-treesitter, compatible with nvim-treesitter 'master' -> 'main'
  -- switch
  version = 'main',
  data = {
    events = { event = 'FileType', pattern = '[^_]\\+' },
    postload = function()
      require('nvim-treesitter-textobjects').setup({
        select = {
          lookahead = true,
          selection_modes = {
            ['@block.outer'] = 'V',
            ['@block.inner'] = 'V',
            ['@header.outer'] = 'V',
            ['@header.inner'] = 'V',
          },
        },
      })

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')
      local swap = require('nvim-treesitter-textobjects.swap')

      local sel = select.select_textobject

      local goto_next_end = move.goto_next_end
      local goto_next_start = move.goto_next_start
      local goto_previous_end = move.goto_previous_end
      local goto_previous_start = move.goto_previous_start

      local swap_next = swap.swap_next
      local swap_previous = swap.swap_previous

      -- stylua: ignore start
      vim.keymap.set({ 'x', 'o' }, 'am', function() sel('@function.outer') end,    { desc = 'Select around function' })
      vim.keymap.set({ 'x', 'o' }, 'im', function() sel('@function.inner') end,    { desc = 'Select inside function' })
      vim.keymap.set({ 'x', 'o' }, 'ao', function() sel('@loop.outer') end,        { desc = 'Select around loop' })
      vim.keymap.set({ 'x', 'o' }, 'io', function() sel('@loop.inner') end,        { desc = 'Select inside loop' })
      vim.keymap.set({ 'x', 'o' }, 'ak', function() sel('@class.outer') end,       { desc = 'Select around class' })
      vim.keymap.set({ 'x', 'o' }, 'ik', function() sel('@class.inner') end,       { desc = 'Select inside class' })
      vim.keymap.set({ 'x', 'o' }, 'a,', function() sel('@parameter.outer') end,   { desc = 'Select around parameter' })
      vim.keymap.set({ 'x', 'o' }, 'i,', function() sel('@parameter.inner') end,   { desc = 'Select inside parameter' })
      vim.keymap.set({ 'x', 'o' }, 'a/', function() sel('@comment.outer') end,     { desc = 'Select around comment' })
      vim.keymap.set({ 'x', 'o' }, 'a*', function() sel('@comment.outer') end,     { desc = 'Select inside comment' })
      vim.keymap.set({ 'x', 'o' }, 'i/', function() sel('@comment.inner') end,     { desc = 'Select around comment' })
      vim.keymap.set({ 'x', 'o' }, 'i*', function() sel('@comment.inner') end,     { desc = 'Select inside comment' })
      vim.keymap.set({ 'x', 'o' }, 'a.', function() sel('@block.outer') end,       { desc = 'Select around block' })
      vim.keymap.set({ 'x', 'o' }, 'i.', function() sel('@block.inner') end,       { desc = 'Select inside block' })
      vim.keymap.set({ 'x', 'o' }, 'a?', function() sel('@conditional.outer') end, { desc = 'Select around conditional' })
      vim.keymap.set({ 'x', 'o' }, 'i?', function() sel('@conditional.inner') end, { desc = 'Select inside conditional' })
      vim.keymap.set({ 'x', 'o' }, 'a=', function() sel('@assignment.outer') end,  { desc = 'Select around assignment' })
      vim.keymap.set({ 'x', 'o' }, 'i=', function() sel('@assignment.inner') end,  { desc = 'Select inside assignment' })
      vim.keymap.set({ 'x', 'o' }, 'a#', function() sel('@header.outer') end,      { desc = 'Select around header' })
      vim.keymap.set({ 'x', 'o' }, 'i#', function() sel('@header.inner') end,      { desc = 'Select inside header' })
      vim.keymap.set({ 'x', 'o' }, 'a3', function() sel('@header.outer') end,      { desc = 'Select around header' })
      vim.keymap.set({ 'x', 'o' }, 'i3', function() sel('@header.inner') end,      { desc = 'Select inside header' })
      vim.keymap.set({ 'x', 'o' }, 'ar', function() sel('@return.inner') end,      { desc = 'Select around return' })
      vim.keymap.set({ 'x', 'o' }, 'ir', function() sel('@return.outer') end,      { desc = 'Select inside return' })
      -- stylua: ignore end

      -- stylua: ignore start
      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() goto_next_start('@function.outer') end,        { desc = 'Go to next start of function' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']o', function() goto_next_start('@loop.outer') end,            { desc = 'Go to next start of loop' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() goto_next_start('@function.outer') end,        { desc = 'Go to next start of function' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']k', function() goto_next_start('@class.outer') end,           { desc = 'Go to next start of class' })
      vim.keymap.set({ 'n', 'x', 'o' }, '],', function() goto_next_start('@parameter.outer') end,       { desc = 'Go to next start of parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, '].', function() goto_next_start('@block.outer') end,           { desc = 'Go to next start of block' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']?', function() goto_next_start('@conditional.outer') end,     { desc = 'Go to next start of conditional' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']=', function() goto_next_start('@assignment.inner') end,      { desc = 'Go to next start of assignment' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']#', function() goto_next_start('@header.outer') end,          { desc = 'Go to next start of header' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']3', function() goto_next_start('@header.outer') end,          { desc = 'Go to next start of header' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() goto_next_end('@function.outer') end,          { desc = 'Go to next end of function' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']O', function() goto_next_end('@loop.outer') end,              { desc = 'Go to next end of loop' })
      vim.keymap.set({ 'n', 'x', 'o' }, '][', function() goto_next_end('@function.outer') end,          { desc = 'Go to next end of function' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']K', function() goto_next_end('@class.outer') end,             { desc = 'Go to next end of class' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']<', function() goto_next_end('@parameter.outer') end,         { desc = 'Go to next end of parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']/', function() goto_next_end('@comment.outer') end,           { desc = 'Go to next end of comment' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']>', function() goto_next_end('@block.outer') end,             { desc = 'Go to next end of block' })

      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() goto_previous_start('@function.outer') end,    { desc = 'Go to previous start of function' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[o', function() goto_previous_start('@loop.outer') end,        { desc = 'Go to previous start of loop' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() goto_previous_start('@function.outer') end,    { desc = 'Go to previous start of function' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[k', function() goto_previous_start('@class.outer') end,       { desc = 'Go to previous start of class' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[,', function() goto_previous_start('@parameter.outer') end,   { desc = 'Go to previous start of parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[.', function() goto_previous_start('@block.outer') end,       { desc = 'Go to previous start of block' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[?', function() goto_previous_start('@conditional.outer') end, { desc = 'Go to previous start of conditional' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[=', function() goto_previous_start('@assignment.inner') end,  { desc = 'Go to previous start of assignment' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[#', function() goto_previous_start('@header.outer') end,      { desc = 'Go to previous start of header' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[3', function() goto_previous_start('@header.outer') end,      { desc = 'Go to previous start of header' })

      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() goto_previous_end('@function.outer') end,      { desc = 'Go to previous end of function' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[O', function() goto_previous_end('@loop.outer') end,          { desc = 'Go to previous end of loop' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() goto_previous_end('@function.outer') end,      { desc = 'Go to previous end of function' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[K', function() goto_previous_end('@class.outer') end,         { desc = 'Go to previous end of class' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[<', function() goto_previous_end('@parameter.outer') end,     { desc = 'Go to previous end of parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[/', function() goto_previous_end('@comment.outer') end,       { desc = 'Go to previous end of comment' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[>', function() goto_previous_end('@block.outer') end,         { desc = 'Go to previous end of block' })

      vim.keymap.set('n', 'gsh',       function() swap_previous('@parameter.inner') end, { desc = 'Swap with previous parameter' })
      vim.keymap.set('n', 'gs<Left>',  function() swap_previous('@parameter.inner') end, { desc = 'Swap with previous parameter' })
      vim.keymap.set('n', 'gsl',       function() swap_next('@parameter.inner') end,     { desc = 'Swap with next parameter' })
      vim.keymap.set('n', 'gs<Right>', function() swap_next('@parameter.inner') end,     { desc = 'Swap with next parameter' })
      -- stylua: ignore end
    end,
  },
}
