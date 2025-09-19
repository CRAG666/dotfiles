return {
  src = 'https://github.com/nvimdev/template.nvim',
  data = {
    cmds = { 'Template' },
    postload = function()
      require('template').setup({
        temp_dir = '~/Plantillas',
        author = 'Diego Crag',
        email = 'dcrag@pm.me',
      })
    end,
  },
}