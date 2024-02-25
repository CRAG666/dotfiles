return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "bash-language-server")
      table.insert(opts.ensure_installed, "shfmt")
      table.insert(opts.ensure_installed, "shellcheck")
    end,
  },
}
