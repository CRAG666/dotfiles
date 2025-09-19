return {
  src = 'https://github.com/rcarriga/nvim-dap-ui',
  data = {
    lazy = true,
    deps = {
      { src = 'https://github.com/mfussenegger/nvim-dap' },
      { src = 'https://github.com/nvim-neotest/nvim-nio' },
      {
        src = 'https://github.com/kyazdani42/nvim-web-devicons',
        data = { optional = true },
      },
    },
    postload = function()
      local dap, dapui = require('dap'), require('dapui')
      local static = require('utils.static')

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      vim.keymap.set({ 'n', 'x' }, '<F24>', dapui.eval, {
        desc = 'Inspect element value',
      })
      vim.keymap.set({ 'n', 'x' }, '<Leader>GK', dapui.eval, {
        desc = 'Inspect element value',
      })

      ---@diagnostic disable-next-line: missing-fields
      dapui.setup({
        expand_lines = false, -- don't overflow text in debug info wins
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.25 },
              { id = 'watches', size = 0.25 },
              { id = 'breakpoints', size = 0.25 },
              { id = 'stacks', size = 0.25 },
            },
            position = 'left',
            size = 0.3,
          },
          {
            elements = {
              { id = 'repl', size = 0.5 },
              { id = 'console', size = 0.5 },
            },
            position = 'bottom',
            size = 0.25,
          },
        },
        icons = {
          expanded = vim.trim(static.icons.ui.AngleDown),
          collapsed = vim.trim(static.icons.ui.AngleRight),
          current_frame = vim.trim(static.icons.StackFrameCurrent),
        },
        ---@diagnostic disable-next-line: missing-fields
        controls = {
          icons = {
            play = vim.trim(static.icons.debug.Start),
            pause = vim.trim(static.icons.debug.Pause),
            run_last = vim.trim(static.icons.debug.Restart),
            step_back = vim.trim(static.icons.debug.StepBack),
            step_into = vim.trim(static.icons.debug.StepInto),
            step_out = vim.trim(static.icons.debug.StepOut),
            step_over = vim.trim(static.icons.debug.StepOver),
            terminate = vim.trim(static.icons.debug.Stop),
            disconnect = vim.trim(static.icons.debug.Disconnect),
          },
        },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { '=', 'za' },
          open = { '<CR>', 'o', 'zo' },
          remove = { 'dd', 'x' },
          edit = { 's', 'cc' },
          repl = 'r',
          toggle = '<Leader><Leader>',
        },
        floating = {
          border = 'solid',
          max_height = 20,
          max_width = 80,
          mappings = {
            close = { 'q', '<Esc>' },
          },
        },
        windows = { indent = 1 },
      })

      require('utils.hl').persist(function()
        vim.api.nvim_set_hl(0, 'DapUIFloatBorder', { link = 'FloatBorder' })
      end)
    end,
  },
}
