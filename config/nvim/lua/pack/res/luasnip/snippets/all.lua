local M = {}
local us = require('utils.snip.snips')
local conds = require('utils.snip.conds')
local ls = require('luasnip')
local i = ls.insert_node
local c = ls.choice_node

M.snippets = {
  us.ms(
    {
      { trig = 'now' },
      { trig = 'Now' },
      common = {
        desc = 'Current date and time',
        condition = conds.in_ft({ '', 'text' })
          + conds.in_ft('markdown') * conds.in_normalzone
          + conds.in_syngroup('Comment')
          + conds.in_tsnode(
            { 'source', 'comment', 'curly_group' },
            { ignore_injections = false }
          ),
      },
    },
    c(1, {
      i(nil, os.date()),
      i(nil, os.date('%Y-%m-%d')), -- ISO
      i(nil, os.date('%m.%d.%Y')),
    })
  ),
}

return M
