local M = {}
local us = require('utils.snippets.snips')
local conds = require('utils.snippets.conds')
local ls = require('luasnip')
local i = ls.insert_node
local c = ls.choice_node

M.snippets = {
  us.ms(
    {
      { trig = 'date' },
      { trig = 'Date' },
      common = {
        desc = 'Current date and time',
        condition = conds.in_ft({ '', 'text' })
          + conds.in_ft('markdown') * conds.in_normalzone
          + conds.in_syngroup('Comment')
          + conds.in_tsnode(
            { 'comment', 'curly_group' },
            { ignore_injections = false }
          ),
      },
    },
    c(1, {
      i(nil, os.date()),
      i(nil, os.date('%Y-%m-%d')), -- ISO
    })
  ),
}

return M
