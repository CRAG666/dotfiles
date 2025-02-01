local M = {}
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local f = ls.function_node

M.snippets = {
  us.sn(
    {
      trig = 'date',
      desc = 'Current date and time',
    },
    f(function()
      return vim.trim(vim.system({ 'date' }):wait().stdout)
    end)
  ),
}

return M
