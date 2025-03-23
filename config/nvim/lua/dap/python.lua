local M = {}
local dap_utils = require('utils.dap')

---@type dapcache_t
local cache = dap_utils.new_cache()

M.adapter = {
  type = 'executable',
  command = 'python',
  args = { '-m', 'debugpy.adapter' },
}

M.config = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    args = dap_utils.get_args(cache),
    pythonPath = function()
      ---@type string[]
      local venvs = vim.fs.find({ 'venv', 'env', '.venv', '.env' }, {
        path = vim.fn.expand('%:p:h'),
        limit = math.huge,
        upward = true,
      })
      for _, venv in ipairs(venvs) do
        local python_path = vim.fs.joinpath(venv, 'bin/python')
        if vim.fn.executable(python_path) == 1 then
          return python_path
        end
      end
      return vim.fn.exepath('python')
    end,
  },
}

return M
