local function setup()
  local utils = require "utils"
  local saga = require "lspsaga"
  local colors = require("catppuccin.palettes").get_palette()
  saga.setup {
    lightbulb = {
      sign = false,
    },
    outline = {
      win_width = 40,
      keys = {
        jump = "<CR>",
        expand_collapse = "l",
        quit = "q",
      },
    },
    symbol_in_winbar = {
      separator = "  ",
      show_file = false,
    },
    ui = {
      -- currently only round theme
      theme = "round",
      title = true,
      -- border type can be single,double,rounded,solid,shadow.
      border = "solid",
      winblend = 0,
      expand = "",
      collapse = "",
      preview = " ",
      code_action = "💡",
      diagnostic = "🐞",
      incoming = " ",
      outgoing = " ",
      colors = {
        --float window normal background color
        normal_bg = colors.mantle,
        --title background color
        title_bg = colors.lavender,
        red = colors.red,
        magenta = colors.maroon,
        orange = colors.peach,
        yellow = colors.yellow,
        green = colors.green,
        cyan = colors.sky,
        blue = colors.blue,
        purple = colors.mauve,
        white = colors.text,
        black = colors.crust,
      },
    },
  }
  -- vim.cmd.redraw()

  -- navegate between errors
  utils.map("n", ";dk", function()
    require("lspsaga.diagnostic").goto_prev { severity = vim.diagnostic.severity.ERROR }
  end, { desc = "Prev Error" })
  utils.map("n", ";dj", function()
    require("lspsaga.diagnostic").goto_next { severity = vim.diagnostic.severity.ERROR }
  end, { desc = "Next Error" })
  -- vim.schedule(function()
  -- vim.wo.winbar = require("lspsaga.symbolwinbar"):get_winbar()
  -- vim.cmd ":e"
  -- end)
end

return {
  "glepnir/lspsaga.nvim",
  event = "LspAttach",
  keys = {
    { "<leader>lf", "<cmd>Lspsaga lsp_finder<CR>", desc = "Find the symbol definition implement reference" },
    { mode = { "n", "v" }, "<C-.>", "<cmd>Lspsaga code_action<CR>", desc = "Code actions" },
    { "gr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
    -- { "gr", "<cmd>Lspsaga rename ++project<CR>", desc = "Rename" },
    { "gp", "<cmd>Lspsaga peek_definition<CR>", desc = "Edit the definition file in this flaotwindow" },
    { "gd", "<cmd>Lspsaga goto_definition<CR>", desc = "Goto definition" },
    { ";dl", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Show line diagnostics" },
    { ";dc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", desc = "Show cursor diagnostic" },
    { ";db", "<cmd>Lspsaga show_buf_diagnostics<CR>", desc = "Show buf diagnostic" },
    { "<leader>o", "<cmd>Lspsaga outline<CR>", desc = "Toggle Outline" },
    { "gh", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover doc" },
    -- Callhierarchy
    { ";ci", "<cmd>Lspsaga incoming_calls<CR>", desc = "Incoming calls" },
    { ";co", "<cmd>Lspsaga outgoing_calls<CR>", desc = "Incoming calls" },
  },
  config = setup,
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    --Please make sure you install markdown and markdown_inline parser
    { "nvim-treesitter/nvim-treesitter" },
  },
}
