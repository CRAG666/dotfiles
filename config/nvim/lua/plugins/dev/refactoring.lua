vim.pack.add({ { src = 'https://github.com/ThePrimeagen/refactoring.nvim' } })

require('refactoring').setup({
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
})