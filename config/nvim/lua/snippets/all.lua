local M = {}
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local f = ls.function_node

M.snippets = {
  us.sN(
    {
      trig = 'date',
      desc = 'Current date and time',
    },
    f(function()
      return os.date()
    end)
  ),
}

return M
