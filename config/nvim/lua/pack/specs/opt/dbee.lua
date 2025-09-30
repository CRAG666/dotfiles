return {
  src = 'https://github.com/kndndrj/nvim-dbee',
  data = {
    deps = {
      {
        src = 'https://github.com/MunifTanjim/nui.nvim',
        data = { optional = false },
      },
    },
    keys = {
      mode = 'n',
      lhs = '<leader>dm',
      opts = { desc = '[d]atabase [m]ode' },
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require('dbee').install()
    end,
    cmds = { 'Dbee' },
    postload = function()
      require('dbee').setup({})
      vim.keymap.set('n', '<leader>dm', function()
        require('dbee').toggle()
      end)
    end,
  },
}
