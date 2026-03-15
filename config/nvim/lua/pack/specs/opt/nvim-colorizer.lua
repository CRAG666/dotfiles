---@type pack.spec
return {
  src = 'https://github.com/NvChad/nvim-colorizer.lua',
  data = {
    events = {
      'BufNew',
      'BufRead',
      'BufWritePost',
      'TextChanged',
      'TextChangedI',
      'StdinReadPre',
    },
    postload = function()
      -- Setting `termguicolors` in linux TTY have negative effect on
      -- visibility, but is required by the plugin, so skip setting up this
      -- plugin when in linux TTY
      if vim.env.TERM == 'linux' then
        return
      end

      -- Colorizer throws error if `termguicolors` is not set
      if not vim.o.termguicolors then
        vim.o.termguicolors = true
      end

      require('colorizer').setup({
        user_default_options = {
          names = false,
          rgb_fn = true,
          hsl_fn = true,
        },
      })
    end,
  },
}
