return {
  "jose-elias-alvarez/null-ls.nvim",
  ft = "python",
  opts = function(_, opts)
    local nls = require "null-ls"

    local sources = {
      -- nls.builtins.formatting.ruff,
      nls.builtins.formatting.black,
      nls.builtins.formatting.isort,
      nls.builtins.diagnostics.ruff.with { extra_args = { "--max-line-length=180" } },
    }

    for _, source in ipairs(sources) do
      table.insert(opts.sources, source)
    end
  end,
}
