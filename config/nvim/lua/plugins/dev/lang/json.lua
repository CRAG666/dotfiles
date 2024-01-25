return {

  -- add json to treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "json", "json5", "jsonc" })
      end
    end,
  },

  -- yaml schema support
  {
    "b0o/SchemaStore.nvim",
    ft = "json",
    version = false, -- last release is way too old
  },
}
