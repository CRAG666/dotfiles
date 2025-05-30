local utils = require('utils')
local icons = utils.static.icons.diagnostics
local boxes = require('utils.static.boxes')
return {
  { 'MunifTanjim/nui.nvim', lazy = true },
  {
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.select(...)
      end
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      -- window = { position = "top" },
      preset = "modern",
      icons = {
        breadcrumb = '»',
        separator = '➜',
        group = '…',
      },
      spelling = { enabled = true },
    },
  },
  {
    'brenoprata10/nvim-highlight-colors',
    event = 'LazyFile',
    opts = {
      render = 'background', -- or 'foreground' or 'first_column'
      enable_tailwind = false,
    },
  },
  {
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      use_default_opts = false,
      opts = {
        signcolumn = 'auto',
      },
      keys = {
        {
          'g>',
          function()
            require('quicker').expand({
              before = 2,
              after = 2,
              add_to_existing = true,
            })
          end,
          desc = 'Expand quickfix context',
        },
        {
          'g<',

          function()
            require('quicker').collapse()
          end,
          desc = 'Collapse quickfix context',
        },
      },
      highlight = {
        lsp = true,
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
        return math.ceil(vim.go.columns / 2)
      end,
    },
  },
  {
    'rasulomaroff/reactive.nvim',
    event = 'LazyFile',
    opts = {
      builtin = {
        cursorline = true,
        cursor = true,
        modemsg = true
      },
      load = { 'catppuccin-mocha-cursor', 'catppuccin-mocha-cursorline' }
    }
  },
  {
    "folke/todo-comments.nvim",
    keys = {
      { "<leader>st", function() Snacks.picker.todo_comments() end,                                          desc = "Todo" },
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },
  {
    'hat0uma/csvview.nvim',
    ft = { 'csv' },
    config = function()
      require('csvview').setup({
        view = {
          display_mode = 'border',
        },
      })
      require('csvview').toggle()
    end,
  },
  {
    '3rd/image.nvim',
    ft = { 'markdown', 'norg', 'quarto' },
    build = false,
    opts = {
      processor = 'magick_cli',
      window_overlap_clear_enabled = true,
      clear_in_insert_mode = true,
      integrations = {
        markdown = {
          filetypes = { 'markdown', 'vimwiki', 'quarto' }, -- markdown extensions (ie. quarto) can go here
        },
      },
    },
  },
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
    opts = {
      timeout = 1,
      maxkeys = 5,
      position = "top-right",
      -- more opts
    }
  }
}
