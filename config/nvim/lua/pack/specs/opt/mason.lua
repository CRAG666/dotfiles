return {
  src = 'https://github.com/williamboman/mason.nvim',
  data = {
    deps = {
      { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
    },
    cmds = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonLog' },
    postload = function()
      require('mason').setup()
      vim.g.mason = vim.g.mason or {}
      require('mason-tool-installer').setup({
        ensure_installed = vim.g.mason,
      })
      vim.api.nvim_create_user_command('MasonToolsInstallSync', function()
        require('mason-tool-installer').install_sync()
      end, {})
    end,
  },
}