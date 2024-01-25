return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "bibtex", "latex" })
      end
      if type(opts.highlight.disable) == "table" then
        vim.list_extend(opts.highlight.disable, { "latex" })
      else
        opts.highlight.disable = { "latex" }
      end
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    ft = "tex",
    opts = function(_, opts)
      local nls = require "null-ls"
      table.insert(opts.sources, nls.builtins.diagnostics.vale)
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- table.insert(opts.ensure_installed, "bibtex-tidy")
      table.insert(opts.ensure_installed, "latexindent")
      -- table.insert(opts.ensure_installed, "ltex-ls")
      table.insert(opts.ensure_installed, "texlab")
      table.insert(opts.ensure_installed, "vale")
    end,
  },
}
