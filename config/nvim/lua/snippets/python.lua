local M = {}
local uf = require('utils.snippets.funcs')
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

M.snippets = {
  us.sn({
    trig = 'ret',
    desc = 'return statement',
  }, t('return ')),
  us.sn(
    {
      trig = 'p',
      desc = 'print()',
    },
    un.fmtad('print(<expr>)', {
      expr = i(1),
    })
  ),
  us.msn(
    {
      { trig = 'ck' },
      { trig = 'check' },
      common = { desc = 'Inspect through f-string' },
    },
    un.fmtad('f<q><expr_escaped>: {<expr>}<q>', {
      q = un.qt(),
      expr = i(1),
      expr_escaped = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'pcheck' },
      common = { desc = 'Inspect through print()' },
    },
    un.fmtad('print(f<q><expr_escaped>: {<expr>}<q><e>)', {
      q = un.qt(),
      expr = i(1),
      expr_escaped = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
      e = i(3),
    })
  ),
  us.sn(
    {
      trig = 'pl',
      desc = 'Print a line',
    },
    un.fmtad('print(<q><line><q>)', {
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
  us.msn({
    { trig = 'im' },
    { trig = 'imp' },
    common = {
      desc = 'import statement',
    },
  }, {
    t('import '),
    i(0, 'module'),
  }),
  us.msn({
    { trig = 'fim' },
    { trig = 'imf' },
    { trig = 'fimp' },
    { trig = 'impf' },
    common = {
      desc = 'from ... import statement',
    },
  }, {
    t('from '),
    i(1, 'module'),
    t(' import '),
    i(0, 'name'),
  }),
  us.sn('inp', t('import numpy as np')),
  us.sn('ipd', t('import pandas as pd')),
  us.sn('iplt', t('import matplotlib.pyplot as plt')),
  us.sn('itf', t('import tensorflow as tf')),
  us.sn('itor', t('import torch')),
  us.sn('itn', t('import torch.nn as nn')),
  us.sn('itnf', t('import torch.nn.functional as F')),
  us.sn('ito', t('import torch.optim as optim')),
  us.sn('itv', t('import torchvision')),
  us.sn('itt', t('import torchvision.transforms as transforms')),
  us.sn('itd', t('import torchvision.datasets as datasets')),
  us.sn('itu', t('import torchvision.utils as utils')),
  us.sn('itud', t('import torch.utils.data as data')),
  us.sn('itm', t('import torchvision.models as models')),
  us.sn(
    {
      trig = 'if',
      desc = 'if statement',
    },
    un.fmtad(
      [[
        if <cond>:
        <body>
      ]],
      {
        cond = i(1),
        body = un.body(2, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'ife' },
      { trig = 'ifel' },
      { trig = 'ifelse' },
      common = { desc = 'if...else statement' },
    },
    un.fmtad(
      [[
        if <cond>:
        <body>
        else:
        <idnt>
      ]],
      {
        cond = i(1),
        body = un.body(2, 1),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'ifei' },
      { trig = 'ifeif' },
      { trig = 'ifeli' },
      { trig = 'ifelif' },
      { trig = 'ifelsei' },
      { trig = 'ifelseif' },
      common = { desc = 'if...elif statement' },
    },
    un.fmtad(
      [[
        if <cond>:
        <body>
        elif:
        <idnt>
      ]],
      {
        cond = i(1),
        body = un.body(2, 1),
        idnt = un.idnt(1),
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
        else:
        <body>
      ]],
      {
        body = un.body(1, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'eli' },
      { trig = 'elif' },
      { trig = 'elsei' },
      { trig = 'elseif' },
      common = { desc = 'elif statement' },
    },
    un.fmtad(
      [[
        elif <cond>:
        <body>
      ]],
      {
        cond = i(1),
        body = un.body(2, 1, false),
      }
    )
  ),
  us.sn(
    {
      trig = 'for',
      desc = 'for loop',
    },
    un.fmtad(
      [[
        for <var> in <iter>:
        <body>
      ]],
      {
        var = i(1),
        iter = i(2),
        body = un.body(3, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fr' },
      { trig = 'forr' },
      { trig = 'frange' },
      { trig = 'forange' },
      { trig = 'forrange' },
      common = { desc = 'for ... in range(...) loop' },
    },
    un.fmtad(
      [[
        for <var> in range(<range>):
        <body>
      ]],
      {
        var = i(1),
        range = i(2),
        body = un.body(3, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fit' },
      { trig = 'fori' },
      { trig = 'forit' },
      { trig = 'fiter' },
      { trig = 'forit' },
      { trig = 'foriter' },
      common = { desc = 'for ... in iter(...) loop' },
    },
    un.fmtad(
      [[
        for <idx>, <elem> in iter(<iterable>):
        <body>
      ]],
      {
        idx = i(1, 'idx'),
        elem = i(2, 'elem'),
        iterable = i(3),
        body = un.body(4, 1, false),
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
        while <cond>:
        <body>
      ]],
      {
        cond = i(1),
        body = un.body(2, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      { trig = 'function' },
      { trig = 'def' },
      common = { desc = 'Function definition' },
    },
    un.fmtad(
      [[
        def <name>(<args>)<ret>:
        <body>
      ]],
      {
        name = r(1, 'fn_name'),
        args = r(2, 'args'),
        ret = i(3),
        body = un.body(4, 1, false),
      }
    ),
    {
      common_opts = {
        stored = {
          fn_name = i(nil, 'function_name'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'me' },
      { trig = 'method' },
      common = { desc = 'Method definition' },
    },
    un.fmtad(
      [[
        def <name>(self<args>):
        <body>
      ]],
      {
        name = i(1, 'method_name'),
        args = i(2),
        body = un.body(3, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'cls' },
      { trig = 'class' },
      { trig = 'tp' },
      { trig = 'type' },
      common = { desc = 'Class definition' },
    },
    un.fmtad(
      [[
        class <name>:
        <idnt>def __init__(self<args>):
        <body>
      ]],
      {
        name = i(1, 'class_name'),
        args = i(2),
        idnt = un.idnt(1),
        body = un.body(3, 2, false),
      }
    )
  ),
  us.sn(
    {
      trig = 'with',
      desc = 'with statement',
    },
    un.fmtad(
      [[
        with <expr> as <var>:
        <body>
      ]],
      {
        expr = i(1),
        var = i(2),
        body = un.body(3, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'tr' },
      { trig = 'try' },
      common = { desc = 'try statement' },
    },
    un.fmtad(
      [[
        try:
        <body>
      ]],
      {
        body = un.body(1, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'te' },
      { trig = 'tex' },
      { trig = 'tre' },
      { trig = 'trex' },
      { trig = 'trye' },
      { trig = 'tryex' },
      common = { desc = 'try...except statement' },
    },
    un.fmtad(
      [[
        try:
        <body>
        except<exc>:
        <idnt>
      ]],
      {
        body = un.body(1, 1),
        exc = i(2),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'tef' },
      { trig = 'texf' },
      { trig = 'tref' },
      { trig = 'trexf' },
      { trig = 'tryef' },
      { trig = 'tryexf' },
      common = { desc = 'try...except...finally statement' },
    },
    un.fmtad(
      [[
        try:
        <body>
        except<exc>:
        <idnt><exc_body>
        finally:
        <idnt>
      ]],
      {
        body = un.body(1, 1),
        exc = i(2),
        exc_body = i(3),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'exc' },
      common = { desc = 'except statement' },
    },
    un.fmtad(
      [[
        except<exc>:
        <body>
      ]],
      {
        exc = i(1),
        body = un.body(2, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fin' },
      { trig = 'final' },
      { trig = 'finally' },
      common = { desc = 'finally statement' },
    },
    un.fmtad(
      [[
        finally:
        <body>
      ]],
      {
        body = un.body(1, 1, false),
      }
    )
  ),
  us.msn(
    {
      { trig = 'ifm' },
      { trig = 'ifnm' },
      { trig = 'ifmain' },
      { trig = 'ifnmain' },
      common = { desc = 'if __name__ == "__main__"' },
    },
    un.fmtad(
      [[
        if __name__ == <q>__main__<q>:
        <body>
      ]],
      {
        q = un.qt(),
        body = un.body(1, 1, false),
      }
    )
  ),
}

return M
