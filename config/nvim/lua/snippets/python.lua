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
  us.msns({
    { trig = 'sb' },
    { trig = '#!', snippetType = 'autosnippet' },
    desc = 'Shebang',
  }, {
    t('#!'),
    c(1, {
      i(nil, '/usr/bin/env python3'),
      i(nil, '/usr/bin/python3'),
    }),
  }),
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
  us.sn(
    {
      trig = 'o',
      desc = 'open()',
    },
    un.fmtad('<fd> = open(<q><file><q>, encoding=<q><encoding><q><kwargs>)', {
      fd = i(1, 'fd'),
      q = un.qt(),
      file = i(2, 'file'),
      encoding = i(3, 'utf-8'),
      kwargs = i(4),
    })
  ),
  us.msn(
    {
      { trig = 'wo' },
      { trig = 'wio' },
      { trig = 'witho' },
      common = { desc = 'with open() ...' },
    },
    un.fmtad(
      [[
        with open(<q><file><q>, encoding=<q><encoding><q><kwargs>) as <fd>:
        <body>
      ]],
      {
        q = un.qt(),
        file = i(1, 'file'),
        encoding = i(2, 'utf-8'),
        kwargs = i(3),
        fd = i(4, 'fd'),
        body = un.body(5, 1, 'pass'),
      }
    )
  ),
  us.sn(
    {
      trig = 'ck',
      desc = 'Inspect through f-string',
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
  us.sn(
    {
      trig = 'pck',
      desc = 'Inspect through print()',
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
        i(nil, '........................................'),
        i(nil, '----------------------------------------'),
        i(nil, '========================================'),
        i(nil, '########################################'),
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
      desc = 'from ... import ... statement',
    },
  }, {
    t('from '),
    i(1, 'module'),
    t(' import '),
    i(0, 'name'),
  }),
  us.msn({
    { trig = 'ima' },
    { trig = 'impa' },
    common = {
      desc = 'import ... as ... statement',
    },
  }, {
    t('import '),
    i(1, 'module'),
    t(' as '),
    i(0, 'alias'),
  }),
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
        body = un.body(2, 1, 'pass'),
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
        <body2>
      ]],
      {
        cond = i(1),
        body = un.body(2, 1, 'pass'),
        body2 = un.body(3, 1, 'pass'),
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
        <body2>
      ]],
      {
        cond = i(1),
        body = un.body(2, 1, 'pass'),
        body2 = un.body(3, 1, 'pass'),
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
        body = un.body(1, 1, 'pass'),
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
        body = un.body(2, 1, 'pass'),
      }
    )
  ),
  us.sn(
    {
      trig = 'for',
      desc = 'for loop',
    },
    c(1, {
      un.fmtad(
        [[
          for <var> in <iterable>:
            <body>
        ]],
        {
          var = r(1, 'var'),
          iterable = r(2, 'iterable'),
          body = un.body(3, 1, 'pass'),
        }
      ),
      un.fmtad(
        [[
          for <var> in range(<range>):
          <body>
        ]],
        {
          var = r(1, 'var'),
          range = i(2),
          body = un.body(3, 1, 'pass'),
        }
      ),
      un.fmtad(
        [[
          for <idx>, <var> in iter(<iterable>):
          <body>
        ]],
        {
          idx = i(1, 'i'),
          var = r(2, 'var'),
          iterable = r(3, 'iterable'),
          body = un.body(4, 1, 'pass'),
        }
      ),
    }),
    {
      stored = {
        var = i(nil, 'var'),
        iterable = i(nil, 'iterable'),
      },
    }
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fr' },
      { trig = 'forr' },
      { trig = 'fori' },
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
        var = i(1, 'i'),
        range = i(2),
        body = un.body(3, 1, 'pass'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fit' },
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
        iterable = i(3, 'iterable'),
        body = un.body(4, 1, 'pass'),
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
        body = un.body(2, 1, 'pass'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      { trig = 'def' },
      common = { desc = 'Function definition' },
    },
    un.fmtad(
      [[
        def <name>(<args>)<ret>:
        <body>
      ]],
      {
        name = i(1, 'func'),
        args = i(2),
        ret = i(3),
        body = un.body(4, 1, 'pass'),
      }
    )
  ),
  us.mssn(
    {
      { trig = 'mn' },
      { trig = 'main' },
      common = { desc = 'main function' },
    },
    un.fmtad(
      [[
        def main(<args>)<ret>:
        <body>
      ]],
      {
        args = i(1),
        ret = i(2),
        body = un.body(3, 1, 'pass'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'me' },
      { trig = 'meth' },
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
        body = un.body(3, 1, 'pass'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'cls' },
      { trig = 'class' },
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
        body = un.body(3, 2, 'pass'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'wi' },
      { trig = 'with' },
      common = { desc = 'with statement' },
    },
    c(1, {
      un.fmtad(
        [[
          with <expr>:
          <body>
        ]],
        {
          expr = r(1, 'expr'),
          body = un.body(2, 1, 'pass'),
        }
      ),
      un.fmtad(
        [[
          with <expr> as <var>:
          <body>
        ]],
        {
          expr = r(1, 'expr'),
          var = i(2),
          body = un.body(3, 1, 'pass'),
        }
      ),
    }),
    {
      stored = {
        expr = i(1),
      },
    }
  ),
  us.msn(
    {
      { trig = 'wa' },
      { trig = 'witha' },
      common = { desc = 'with...as... statement' },
    },
    un.fmtad(
      [[
        with <expr> as <var>:
        <body>
      ]],
      {
        expr = i(1),
        var = i(2),
        body = un.body(3, 1, 'pass'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'ma' },
      { trig = 'mat' },
      { trig = 'match' },
      { trig = 'sw' },
      { trig = 'swi' },
      { trig = 'switch' },
      common = { desc = 'match-case statement' },
    },
    un.fmtad(
      [[
        match <subject>:
        <idnt>case <match1>:
        <body>
        <idnt>case <match2>:
        <idnt><idnt><i>
        <idnt>case _:
        <idnt><idnt> <d>
      ]],
      {
        idnt = un.idnt(1),
        subject = i(1, 'subject'),
        match1 = i(2, 'match1'),
        body = un.body(3, 2, 'pass'),
        match2 = i(4, 'match2'),
        i = i(5, 'pass'),
        d = i(6, 'pass'),
      }
    )
  ),
  us.msnr(
    {
      { trig = '^(%s*)ca' },
      { trig = '^(%s*)cas' },
      { trig = '^(%s*)case' },
      common = { desc = 'match-case statement' },
    },
    un.fmtad(
      [[
        <ddnt>case <match>:
        <body>
      ]],
      {
        ddnt = un.ddnt(1),
        match = i(1, 'match'),
        body = un.body(2, function(_, parent)
          return math.max(0, uf.get_indent_depth(parent.snippet.captures[1]))
        end),
      }
    )
  ),
  us.msn(
    {
      { trig = 'tr' },
      { trig = 'try' },
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
  us.sn(
    {
      trig = 'exc',
      desc = 'except statement',
    },
    un.fmtad(
      [[
        except<exc>:
        <body>
      ]],
      {
        exc = i(1),
        body = un.body(2, 1, 'pass'),
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
        body = un.body(1, 1, 'pass'),
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
        body = un.body(1, 1, 'pass'),
      }
    )
  ),
  us.sn(
    { trig = 'nf', desc = 'Disable black formatting' },
    un.fmtad(
      [[
        # fmt: off
        <body>
        # fmt: on
      ]],
      { body = un.body(1, 0) }
    )
  ),
  us.msn(
    {
      { trig = 'ds' },
      { trig = 'docs' },
      common = { desc = 'Docstring' },
    },
    un.fmtad(
      [[
        <q><q><q>
        <body>
        <q><q><q>
      ]],
      {
        q = un.qt(),
        body = un.body(1, 0),
      }
    )
  ),
}

return M
