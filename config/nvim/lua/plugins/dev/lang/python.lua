return {
  {
    "nvimtools/none-ls.nvim",
    ft = "python",
    opts = function(_, opts)
      local nls = require "null-ls"
      table.insert(opts.sources, nls.builtins.formatting.black)
      table.insert(opts.sources, nls.builtins.formatting.isort)
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "black")
      table.insert(opts.ensure_installed, "isort")
      table.insert(opts.ensure_installed, "pyright")
    end,
  },
}
