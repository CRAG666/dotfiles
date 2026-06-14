local M = {}
local api = vim.api

local state = require('plugin.colorify.state')
state.ns = api.nvim_create_namespace('Colorify')

M.attach = require('plugin.colorify.attach')

M.run = function()
  api.nvim_create_autocmd({
    'TextChanged',
    'TextChangedI',
    'TextChangedP',
    'VimResized',
    'LspAttach',
    'WinScrolled',
    'BufEnter',
  }, {
    callback = function(args)
      if vim.bo[args.buf].bl then
        M.attach(args.buf, args.event)
      end
    end,
  })
end

return M
