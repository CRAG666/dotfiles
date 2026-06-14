---@type pack.spec
return {
  src = 'https://github.com/vim-test/vim-test',
  data = {
    deps = 'https://github.com/tpope/vim-dispatch',
    keys = {
      {
        lhs = '<Leader>tk',
        opts = { desc = 'Run the test class nearest to cursor' },
      },
      {
        lhs = '<Leader>tf',
        opts = { desc = 'Run all tests in current file' },
      },
      {
        lhs = '<Leader>tt',
        opts = { desc = 'Run the test nearest to cursor' },
      },
      { lhs = '<Leader>tr', opts = { desc = 'Run the last test' } },
      { lhs = '<Leader>ts', opts = { desc = 'Run the whole test suite' } },
      { lhs = '<Leader>to', opts = { desc = 'Go to last visited test file' } },
      { lhs = '<Leader>tg', opts = { desc = 'Select test strategy' } },
      {
        lhs = '<Leader>tyk',
        opts = { desc = 'Yank command to run test class' },
      },
      {
        lhs = '<Leader>tyf',
        opts = { desc = 'Yank command to run test file' },
      },
      {
        lhs = '<Leader>tyy',
        opts = { desc = 'Yank command to run nearest test function' },
      },
      {
        lhs = '<Leader>tyr',
        opts = { desc = 'Yank command to run the last test' },
      },
      {
        lhs = '<Leader>tys',
        opts = { desc = 'Yank command to run the whole test suite' },
      },
    },
    cmds = {
      'TestClass',
      'TestVisit',
      'TestNearest',
      'TestSuite',
      'TestFile',
      'TestLast',
      'TestStrategy',
      'TestYank',
    },
    postload = function()
      local utils = require('utils')

      local custom_strategies = vim.g['test#custom_strategies'] or {}

      ---Modify & confirm test command before running
      custom_strategies.confirm = function(cmd)
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
      custom_strategies.yank = function(cmd)
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

      vim.g['test#custom_strategies'] = custom_strategies

      vim.g['test#strategy'] = 'dispatch'
      vim.g['test#confirm#strategy'] = 'dispatch'

      ---Get a list of all test strategies (including custom strategies defined by user)
      ---@return string[]
      local function get_strategies()
        -- Load strategy definitions in vim-test so that `getcompletion`
        -- returns a full list of shipped strategies
        vim.cmd.runtime('autoload/test/strategy.vim')

        return utils.lua.dedup(
          vim.list_extend(
            vim.tbl_keys(vim.g['test#custom_strategies']) or {},
            vim
              .iter(vim.fn.getcompletion('test#strategy#', 'function'))
              :map(
                ---@param compl string
                ---@return string
                function(compl)
                  return compl:match('test#strategy#(%w+)')
                end
              )
              :totable()
          )
        )
      end

      ---Select a strategy interactively
      ---@return nil
      local function select_strategy()
        vim.ui.select(
          get_strategies(),
          { prompt = 'Select a strategy: ' },
          function(strategy)
            if not strategy then
              return
            end
            vim.g['test#strategy'] = strategy
          end
        )
      end

      vim.api.nvim_create_user_command('TestStrategy', function(opts)
        if opts.args == '' then
          select_strategy()
          return
        end

        local strategy = opts.args
        local strategies = get_strategies()
        if not vim.tbl_contains(strategies, strategy) then
          vim.notify(
            string.format(
              "[vim-test] strategy '%s' invalid, must be one of: %s",
              strategy,
              table.concat(strategies, ', ')
            ),
            vim.log.levels.WARN
          )
          return
        end

        vim.g['test#strategy'] = strategy
      end, {
        nargs = '?',
        count = -1,
        desc = 'Set global test strategy.',
        complete = function()
          return get_strategies()
        end,
      })

      local test_scopes = { 'nearest', 'class', 'file', 'suite', 'last' }

      vim.api.nvim_create_user_command('TestYank', function(opts)
        local scope = opts.fargs[1]
        if not scope or scope == '' then
          scope = 'nearest'
        end

        if not vim.tbl_contains(test_scopes, scope) then
          vim.notify(
            string.format(
              "[vim-test] test scope '%s' invalid, must be one of: %s",
              scope,
              table.concat(test_scopes, ', ')
            )
          )
          return
        end

        table.remove(opts.fargs, 1)
        opts.fargs[#opts.fargs + 1] = '-strategy=yank'

        if scope == 'last' then
          vim.fn['test#run_last'](opts.fargs)
        else
          vim.fn['test#run'](scope, opts.fargs)
        end
      end, {
        nargs = '*',
        count = -1,
        desc = 'Yank test command.',
        complete = function()
          return test_scopes
        end,
      })

      -- Lazy-load test configs for each filetype
      utils.load.ft_auto_load_once(
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
            .iter(utils.lua.unnest({ test = { [ft] = configs } }, '#'))
            :each(function(name, val)
              vim.g[name] = val
            end)
        end
      )

      -- stylua: ignore start
      vim.keymap.set('n', '<Leader>tk', '<Cmd>TestClass<CR>',    { desc = 'Run the test class nearest to cursor' })
      vim.keymap.set('n', '<Leader>tf', '<Cmd>TestFile<CR>',     { desc = 'Run all tests in current file' })
      vim.keymap.set('n', '<Leader>tt', '<Cmd>TestNearest<CR>',  { desc = 'Run the test neartest to cursor' })
      vim.keymap.set('n', '<Leader>tr', '<Cmd>TestLast<CR>',     { desc = 'Run the last test' })
      vim.keymap.set('n', '<Leader>ts', '<Cmd>TestSuite<CR>',    { desc = 'Run the whole test suite' })
      vim.keymap.set('n', '<Leader>to', '<Cmd>TestVisit<CR>',    { desc = 'Go to last visited test file' })
      vim.keymap.set('n', '<Leader>tg',  '<Cmd>TestStrategy<CR>', { desc = 'Select test strategy' })
      vim.keymap.set('n', '<Leader>tyk', '<Cmd>TestYank class<CR>',   { desc = 'Yank command to run test class' })
      vim.keymap.set('n', '<Leader>tyf', '<Cmd>TestYank file<CR>',    { desc = 'Yank command to run test file' })
      vim.keymap.set('n', '<Leader>tyy', '<Cmd>TestYank nearest<CR>', { desc = 'Yank command to run nearest test function' })
      vim.keymap.set('n', '<Leader>tyr', '<Cmd>TestYank last<CR>',    { desc = 'Yank command to run the last test' })
      vim.keymap.set('n', '<Leader>tys', '<Cmd>TestYank suite<CR>',   { desc = 'Yank command to run the whole test suite' })
      -- stylua: ignore end
    end,
  },
}
