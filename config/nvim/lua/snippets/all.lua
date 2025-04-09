local M = {}
local us = require('utils.snippets.snips')
local conds = require('utils.snippets.conds')
local ls = require('luasnip')
local i = ls.insert_node
local c = ls.choice_node

M.snippets = {
  us.s(
    {
      trig = 'date',
      desc = 'Current date and time',
      condition = conds.in_tsnode({ 'comment', 'string', 'curly_group' }),
      show_condition = conds.in_tsnode({ 'comment', 'string', 'curly_group' }),
    },
    c(1, {
      i(nil, os.date()),
      i(nil, os.date('%m.%d.%Y')),
    })
  ),
}

return M
