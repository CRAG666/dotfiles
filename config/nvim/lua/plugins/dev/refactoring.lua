function setup()
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
  require("telescope").load_extension "refactoring"
end

return {
  {
    "ThePrimeagen/refactoring.nvim",
    keys = [[<leader>fr]],
    config = setup,
  },
}
