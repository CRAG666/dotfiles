---Automatically add 'async' to functions containing 'await'
---Source: https://gist.github.com/JoosepAlviste/43e03d931db2d273f3a6ad21134b3806

---Valid languages to enable this plugin
---@type table<string, boolean>
local fts = {
  python = true,
  javascript = true,
  typescript = true,
  javascriptreact = true,
  typescriptreact = true,
}

---When typing 'await' add 'async' to the function declaration if the function
---isn't async already.
local function add_async()
  if
    not vim.endswith(
      vim.api.nvim_get_current_line():sub(1, vim.fn.col('.') - 1),
      'await'
    )
  then
    return
  end

  local ts = require('utils.ts')
  local lang = ts.lang()
  if not lang or not fts[lang] then
    return
  end

  -- `ignore_injections = false` makes this snippet work in filetypes where JS
  -- is injected into other languages
  local func_node = ts.find_node(
    { 'function', 'method' },
    { ignore_injections = false }
  )
  if not func_node then
    return
  end

  if vim.startswith(vim.treesitter.get_node_text(func_node, 0), 'async') then
    return
  end

  local start_row, start_col = func_node:start()
  vim.api.nvim_buf_set_text(
    0,
    start_row,
    start_col,
    start_row,
    start_col,
    { 'async ' }
  )
end

---Plugin setup function
local function setup()
  if vim.g.loaded_addasync ~= nil then
    return
  end
  vim.g.loaded_addasync = true

  vim.api.nvim_create_autocmd('TextChangedI', {
    group = vim.api.nvim_create_augroup('my.addasync', {}),
    callback = add_async,
  })
end

return { setup = setup }
