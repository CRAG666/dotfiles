return {
  "nvimtools/none-ls.nvim",
  ft = { "bash", "sh" },
  opts = function(_, opts)
    local nls = require "null-ls"

    local sources = {
      nls.builtins.formatting.shellharden,
      nls.builtins.diagnostics.shellcheck,
      nls.builtins.code_actions.shellcheck,
    }

    for _, source in ipairs(sources) do
      table.insert(opts.sources, source)
    end
  end,
}
