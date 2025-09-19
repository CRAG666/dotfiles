return {
  src = 'https://github.com/stevearc/quicker.nvim',
  data = {
    ---@param spec vim.pack.Spec
    load = function(spec)
      local load = require('utils.load')

      load.on_events(
        'UIEnter',
        'quicker',
        vim.schedule_wrap(function()
          load.load('quicker.nvim')
          spec.data.postload()
        end)
      )
    end,
    postload = function()
      local icons = require('utils.static.icons')
      local boxes = require('utils.static.boxes')
      local quicker = require('quicker')

      quicker.setup({
        use_default_opts = false,
        opts = {
          -- Required for type icons to work
          signcolumn = 'auto',
        },
        highlight = {
          lsp = false,
          treesitter = true,
          load_buffers = false,
        },
        type_icons = {
          E = icons.DiagnosticSignError,
          W = icons.DiagnosticSignWarn,
          I = icons.DiagnosticSignInfo,
          N = icons.DiagnosticSignHint,
          H = icons.DiagnosticSignHint,
        },
        borders = {
          vert = vim.go.tgc and ' ' or boxes.single.vt,
          -- Strong headers separate results from different files
          strong_header = boxes.single.hr,
          strong_cross = vim.go.tgc and boxes.single.hr or boxes.single.x,
          strong_end = vim.go.tgc and boxes.single.hr or boxes.single.xr,
          -- Soft headers separate results within the same file
          soft_header = boxes.single.hr,
          soft_cross = vim.go.tgc and boxes.single.hr or boxes.single.x,
          soft_end = vim.go.tgc and boxes.single.hr or boxes.single.xr,
        },
        on_qf = function(buf)
          -- Disable custom qf syntax, see `syntax/qf.vim`
          vim.bo[buf].syntax = ''
        end,
        max_filename_width = function()
          return math.max(32, math.ceil(vim.go.columns / 4))
        end,
      })
    end,
  },
}
