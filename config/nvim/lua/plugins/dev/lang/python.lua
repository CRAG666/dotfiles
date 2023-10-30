return {
  "nvimtools/none-ls.nvim",
  ft = "python",
  opts = function(_, opts)
    local nls = require "null-ls"
    table.insert(opts.sources, nls.builtins.formatting.black)
    table.insert(opts.sources, nls.builtins.formatting.isort)
  end,
}
