local utils = require('utils')
local icons = utils.static.icons.diagnostics
local boxes = require('utils.static.boxes')
return {
  { 'MunifTanjim/nui.nvim', lazy = true },
  {
    'echasnovski/mini.indentscope',
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = 'LazyFile',
    opts = {
      -- symbol = "▏",
      symbol = '│',
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'help',
          'alpha',
          'dashboard',
          'neo-tree',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- {
  --   "echasnovski/mini.tabline",
  --   -- Agregar keys
  --   keys = { { "<leader>ts", [[:execute 'set showtabline=' . (&showtabline ==# 0 ? 2 : 0)<CR>]] } },
  --   init = utils.setup "mini.tabline",
  -- },
  {
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      -- window = { position = "top" },
      icons = {
        breadcrumb = '»',
        separator = '➜',
        group = '…',
      },
      spelling = { enabled = false, suggestions = 20 },
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
    'chentoast/marks.nvim',
    name = 'marks',
    event = 'LazyFile',
    config = utils.fn.setup('marks', {
      default_mappings = true,
      builtin_marks = { '.', '<', '>', '^' },
      cyclic = true,
      force_write_shada = false,
      refresh_interval = 250,
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
    }),
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
    event = 'InsertEnter',
    config = function()
      require('reactive').setup({
        load = { 'catppuccin-mocha-cursor', 'catppuccin-mocha-cursorline' },
      })
    end,
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
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
}
