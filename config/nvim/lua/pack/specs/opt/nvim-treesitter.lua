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
    events = require('utils.load').ft_event,
    postload = function()
      local requested = {} ---@type table<string, true>

      ---Install the parsers requested by ftplugins in `g:ts`
      local install = vim.schedule_wrap(function()
        local langs = vim.tbl_filter(function(lang)
          local new = not requested[lang]
          requested[lang] = true
          return new
        end, vim.g.ts or {})
        if #langs > 0 then
          require('nvim-treesitter').install(langs)
        end
      end)

      install()
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('ts.install_parsers', {}),
        desc = 'Install treesitter parsers requested by ftplugins.',
        callback = install,
      })
    end,
  },
}
