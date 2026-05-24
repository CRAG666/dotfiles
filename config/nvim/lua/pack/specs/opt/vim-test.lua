---@type pack.spec
return {
  src = 'https://github.com/vim-test/vim-test',
  data = {
    deps = 'https://github.com/tpope/vim-dispatch',
    keys = {
      {
        lhs = '<Leader>Tk',
        opts = { desc = 'Run the first test class in current file' },
      },
      {
        lhs = '<Leader>Tf',
        opts = { desc = 'Run all tests in current file' },
      },
      {
        lhs = '<Leader>Tt',
        opts = { desc = 'Run the test neartest to cursor' },
      },
      { lhs = '<Leader>Tr', opts = { desc = 'Run the last test' } },
      { lhs = '<Leader>Ts', opts = { desc = 'Run the whole test suite' } },
      { lhs = '<Leader>To', opts = { desc = 'Go to last visited test file' } },
    },
    cmds = {
      'TestClass',
      'TestVisit',
      'TestNearest',
      'TestSuite',
      'TestFile',
      'TestLast',
    },
    postload = function()
      local strategies = vim.g['test#custom_strategies'] or {}

      ---Modify & confirm test command before running
      strategies.confirm = function(cmd)
        vim.ui.input(
          { prompt = 'Test command: ', default = cmd },
          function(input)
            cmd = input
          end
        )
        if not cmd then
          return
        end
        return vim.fn['test#strategy#' .. (vim.g['test#confirm#strategy'] or 'basic')](
          cmd
        )
      end

      ---Yank instead of run the test command
      strategies.yank = function(cmd)
        vim.fn.setreg('"', cmd)
        vim.fn.setreg(vim.v.register, cmd)
        vim.notify(
          string.format(
            "[vim-test] yanked '%s' to register '%s'",
            cmd,
            vim.v.register
          )
        )
      end

      vim.g['test#custom_strategies'] = strategies

      vim.g['test#strategy'] = 'dispatch'
      vim.g['test#confirm#strategy'] = 'dispatch'

      -- Lazy-load test configs for each filetype
      require('utils.load').ft_auto_load_once(
        'pack.res.vim-test.tests',
        function(ft, configs)
          if not configs then
            return
          end
          -- Vim-test use autoload vim variables, e.g. `g:test#go#gotest#options...`
          -- so we have to first unnest lua table using '#' as delimiter then set
          -- the test global variable.
          -- Also see: https://www.reddit.com/r/neovim/comments/jwd0qx/how_do_i_define_vim_variable_in_lua/
          vim
            .iter(require('utils.lua').unnest({ test = { [ft] = configs } }, '#'))
            :each(function(name, val)
              vim.g[name] = val
            end)
        end
      )

      -- stylua: ignore start
      vim.keymap.set('n', '<Leader>Tk', '<Cmd>TestClass<CR>',   { desc = 'Run the first test class in current file' })
      vim.keymap.set('n', '<Leader>Tf', '<Cmd>TestFile<CR>',    { desc = 'Run all tests in current file' })
      vim.keymap.set('n', '<Leader>Tt', '<Cmd>TestNearest<CR>', { desc = 'Run the test neartest to cursor' })
      vim.keymap.set('n', '<Leader>Tr', '<Cmd>TestLast<CR>',    { desc = 'Run the last test' })
      vim.keymap.set('n', '<Leader>Ts', '<Cmd>TestSuite<CR>',   { desc = 'Run the whole test suite' })
      vim.keymap.set('n', '<Leader>To', '<Cmd>TestVisit<CR>',   { desc = 'Go to last visited test file' })
      -- stylua: ignore end
    end,
  },
}
