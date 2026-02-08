---@type pack.spec
return {
  src = 'https://github.com/nvim-treesitter/nvim-treesitter',
  version = 'main', -- master branch is deprecated
  data = {
    build = function()
      vim.cmd.packadd('nvim-treesitter')
      require('nvim-treesitter.install').update()
    end,
    cmds = {
      'TSInstall',
      'TSInstallFromGrammar',
      'TSUninstall',
      'TSUpdate',
    },
    -- Skip loading nvim-treesitter for plugin-specific filetypes containing
    -- underscores (e.g. 'cmp_menu') to improve initial cmdline responsiveness
    -- on slower systems
    events = { event = 'FileType', pattern = '[^_]\\+' },
    postload = function()
      vim.g.ts = vim.g.ts or {}
      require('nvim-treesitter').install(vim.g.ts)
    end,
  },
}
