return {
  {
    "nvimtools/none-ls.nvim",
    ft = { "bash", "sh" },
    opts = function(_, opts)
      local nls = require "null-ls"

      local sources = {
        nls.builtins.formatting.beautysh,
        nls.builtins.diagnostics.shellcheck,
        nls.builtins.code_actions.shellcheck,
      }

      for _, source in ipairs(sources) do
        table.insert(opts.sources, source)
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "bash-language-server")
      table.insert(opts.ensure_installed, "beautysh")
      table.insert(opts.ensure_installed, "shellcheck")
    end,
  },
}
