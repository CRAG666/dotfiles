return {
  src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  data = {
    deps = {
      { src = 'https://github.com/williamboman/mason.nvim' },
    },
    cmds = {
      'Mason',
      'MasonInstall',
      'MasonUninstall',
      'MasonLog',
      'MasonToolsInstall',
      'MasonToolsInstallSync',
      'MasonToolsUpdate',
      'MasonToolsUpdateSync',
      'MasonToolsClean',
    },
    keys = {
      {
        lhs = '<leader>pm',
        opts = { desc = '[m]ason' },
      },
      {
        lhs = '<leader>ps',
        opts = { desc = '[m]ason [s]ync' },
      },
    },
    postload = function()
      require('mason').setup()
      vim.g.mason = vim.g.mason or {}
      require('mason-tool-installer').setup({ ensure_installed = vim.g.mason })
      vim.cmd.MasonToolsInstallSync()
      vim.keymap.set('n', '<leader>pm', ':Mason<CR>')
      vim.keymap.set('n', '<leader>ps', ':MasonToolsInstallSync<CR>')
    end,
  },
}
