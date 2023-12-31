local setup = require("utils").setup
return {
  -- {
  --   "williamboman/mason.nvim",
  --   config = true,
  -- },
  {

    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "lua-language-server"
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  { "folke/neodev.nvim", ft = "lua" },
  { "b0o/SchemaStore.nvim", ft = "json" },
  { "Decodetalkers/csharpls-extended-lsp.nvim", ft = "cs" },
  { "Hoffs/omnisharp-extended-lsp.nvim", ft = "cs" },
  {
    "VidocqH/lsp-lens.nvim",
    event = "LspAttach",
    config = setup "lsp-lens",
  },
  {
    "nvimtools/none-ls.nvim",
    event = "BufReadPost",
    opts = function()
      local nls = require "null-ls"
      return {
        -- root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        sources = {
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.shfmt,
          nls.builtins.code_actions.refactoring,
        },
      }
    end,
  },
}
