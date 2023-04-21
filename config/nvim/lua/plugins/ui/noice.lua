return {
  {
    "folke/noice.nvim",
    event = "UIEnter",
    -- keys = ":",
    opts = {
      cmdline = { view = "cmdline" },
      popupmenu = {
        enabled = true,
        backend = "cmp",
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = false, -- a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
      throttle = 42,
      views = {
        split = {
          enter = true,
          size = "25%",
          win_options = { signcolumn = "no", number = false, relativenumber = false, list = false, wrap = false },
        },
        hover = { position = { row = 2, col = 2 } },
        mini = {
          timeout = 3000,
        },
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    -- enabled = false,
  },
}
