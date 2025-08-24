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
    { trig = 'pr' },
    { trig = 'ec' },
    { trig = 'em' },
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
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
    })
  ),
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'eck' },
    },
    un.fmtad('echom <q><v_esc>:<q> <v>', {
      q = un.qt(),
      v = i(1),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn(
    {
      trig = 'ck',
      priority = 999,
    },
    un.fmtad('<q><v_esc>:<q> <v>', {
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
  us.sn(
    {
      trig = 'if',
      desc = 'if statement',
    },
    un.fmtad(
      [[
        if <cond>
        <body>
        endif
      ]],
      {
        cond = i(1, 'v:true'),
        body = un.body(2, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'el' },
      { trig = 'else' },
      common = { desc = 'else statement' },
    },
    un.fmtad(
      [[
        else
        <body>
      ]],
      {
        body = un.body(1, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'eli' },
      { trig = 'elif' },
      { trig = 'elsei' },
      { trig = 'elseif' },
      common = { desc = 'elseif statement' },
    },
    un.fmtad(
      [[
        elseif <cond>
        <body>
      ]],
      {
        cond = i(1, 'v:true'),
        body = un.body(2, 1),
      }
    )
  ),
  us.sn(
    {
      trig = 'for',
      desc = 'for loop (list)',
    },
    un.fmtad(
      [[
        for <var> in <list>
        <body>
        endfor
      ]],
      {
        var = i(1, 'var'),
        list = i(2, 'list'),
        body = un.body(3, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'wh' },
      { trig = 'while' },
      common = { desc = 'while loop' },
    },
    un.fmtad(
      [[
        while <cond>
        <body>
        endwhile
      ]],
      {
        cond = i(1, 'v:true'),
        body = un.body(2, 1),
      }
    )
  ),
}

return M
