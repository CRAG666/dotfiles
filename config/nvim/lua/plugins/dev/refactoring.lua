return {
  {
    "ThePrimeagen/refactoring.nvim",
    config = function()
      require("refactoring").setup {
        prompt_func_return_type = {
          go = true,
          cpp = true,
          c = true,
          java = true,
        },
        prompt_func_param_type = {
          go = true,
          cpp = true,
          c = true,
          java = true,
        },
      }
    end,
  },
}
