local M = {}
local un = require('utils.snippets.nodes')
local uf = require('utils.snippets.funcs')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node
local d = ls.dynamic_node

M.snippets = {
  us.msn({
    { trig = 'p' },
    { trig = 'e' },
    { trig = 'ech' },
    { trig = 'echom' },
  }, t('echom ')),
  us.msn(
    {
      { trig = 'pl' },
      { trig = 'el' },
      common = { desc = 'Print a line' },
    },
    un.fmtad('echom <q><line><q>', {
      q = un.qt(),
      line = c(1, {
        -- stylua: ignore start
        i(nil, '----------------------------------------'),
        i(nil, '========================================'),
        i(nil, '........................................'),
        i(nil, '++++++++++++++++++++++++++++++++++++++++'),
        i(nil, '****************************************'),
        i(nil, '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'),
        i(nil, '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'),
        i(nil, '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'),
        i(nil, '########################################'),
        i(nil, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'),
        -- stylua: ignore end
      }),
    })
  ),
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'eck' },
      { trig = 'pcheck' },
      { trig = 'echeck' },
    },
    un.fmtad('echom <q><v_esc>: <q> <v>', {
      q = un.qt(),
      v = i(1),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msn(
    {
      common = { priority = 999 },
      { trig = 'ck' },
      { trig = 'check' },
    },
    un.fmtad('<q><v_esc>: <q> <v>', {
      q = un.qt(),
      v = i(1),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      { trig = 'function' },
    },
    un.fmtad(
      [[
        function! <name>(<args>) abort
        <body>
        endfunction
      ]],
      {
        name = i(1, 'FuncName'),
        args = i(2),
        body = un.body(3, 1),
      }
    )
  ),
  us.sn(
    { trig = 'aug' },
    un.fmtad(
      [[
        augroup <name>
        <idnt>au!
        <body>
        augroup END
      ]],
      {
        name = i(1, 'AugroupName'),
        body = un.body(2, 1),
        idnt = un.idnt(1),
      }
    )
  ),
}

return M
