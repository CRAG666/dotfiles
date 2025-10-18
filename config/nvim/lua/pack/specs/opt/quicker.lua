---@type pack.spec
return {
  src = 'https://github.com/stevearc/quicker.nvim',
  data = {
    load = function(spec, path)
      local load = require('utils.load')

      local function load_quicker()
        if spec.data and spec.data.preload then
          spec.data.preload(spec, path)
        end
        load.load('quicker.nvim')
        if spec.data and spec.data.postload then
          spec.data.postload(spec, path)
        end
      end

      if vim.v.vim_did_enter then
        vim.schedule(load_quicker)
      else
        load.on_events('UIEnter', 'quicker', vim.schedule_wrap(load_quicker))
      end
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
