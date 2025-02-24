local M = {}
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
      i(nil, '/usr/bin/env node'),
      i(nil, '/usr/bin/node'),
    }),
  }),
  us.sn({
    trig = 'ret',
    desc = 'Return statement',
  }, t('return ')),
  us.msn({
    { trig = 'p' },
    { trig = 'cl' },
    common = { desc = 'console.log()' },
  }, {
    t('console.log('),
    i(1),
    t(')'),
  }),
  us.sn(
    {
      trig = 'pck',
      desc = 'Inspect through console.log()',
    },
    un.fmtad([[console.log(<q><expr_escaped>:<q>, <expr>)]], {
      q = un.qt(),
      expr = i(1),
      expr_escaped = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '`')
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn(
    {
      trig = 'pl',
      desc = 'Print a line',
    },
    un.fmtad('console.log(<q><line><q>)', {
      q = un.qt(),
      line = c(1, {
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
      }),
    })
  ),
  us.msn(
    {
      { trig = 'con' },
      { trig = 'const' },
      common = { desc = 'Constant variable declaration' },
    },
    un.fmtad('const <name> = <value>', {
      name = i(1, 'variable'),
      value = i(2, 'undefined'),
    })
  ),
  us.msn(
    {
      { trig = 'con' },
      { trig = 'consta' },
      common = { desc = 'Constant array/object variable declaration' },
    },
    c(1, {
      un.fmtad('const <name> = [<value>]', {
        name = r(1, 'name'),
        value = i(2),
      }),
      un.fmtad('const <name> = {<value>}', {
        name = r(1, 'name'),
        value = i(2),
      }),
    }),
    {
      stored = {
        name = i(nil, 'variable'),
      },
    }
  ),
  us.msn(
    {
      { trig = 'v' },
      { trig = 'var' },
      { trig = 'let' },
      common = { desc = 'Variable declaration' },
    },
    un.fmtad('let <name> = <value>', {
      name = i(1, 'variable'),
      value = i(2, 'value'),
    })
  ),
  us.msn(
    {
      { trig = 'va' },
      { trig = 'vara' },
      { trig = 'leta' },
      common = { desc = 'Array/object variable declaration' },
    },
    un.fmtad('let <name> = [<value>]', {
      name = i(1, 'variable'),
      value = i(2, 'value'),
    })
  ),
  us.sn(
    {
      trig = 'if',
      desc = 'if statement',
    },
    un.fmtad(
      [[
        if (<cond>) {
        <body>
        }
      ]],
      {
        cond = i(1),
        body = un.body(2, 1),
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
        if (<cond>) {
        <body>
        } else {
        <idnt><else_body>
        }
      ]],
      {
        cond = i(1),
        body = un.body(2, 1),
        else_body = i(3),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      { trig = 'me' },
      { trig = 'meth' },
      common = { desc = 'Function definition' },
    },
    c(1, {
      un.fmtad(
        [[
          function <name>(<params>) {
          <body>
          }
        ]],
        {
          name = r(1, 'name'),
          params = r(2, 'params'),
          body = un.body(3, 1),
        }
      ),
      un.fmtad(
        [[
          const <name> = (<params>) =>> {
          <body>
          }
        ]],
        {
          name = r(1, 'name'),
          params = r(2, 'params'),
          body = un.body(3, 1),
        }
      ),
    }),
    {
      common_opts = {
        stored = {
          name = i(nil, 'functionName'),
          params = i(nil),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'cls' },
      { trig = 'class' },
      common = { desc = 'Class definition' },
    },
    un.fmtad(
      [[
        class <name> {
        <idnt>constructor(<params>) {
        <ctor_body>
        <idnt>}<i>
        }
      ]],
      {
        name = i(1, 'ClassName'),
        params = i(2),
        ctor_body = un.body(3, 2),
        idnt = un.idnt(1),
        i = i(4),
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
          for (let <idx> = 0; <idx> << <len>; <idx>++) {
          <body>
          }
        ]],
        {
          idx = r(1, 'i'),
          len = i(2, 'array.length'),
          body = un.body(3, 1),
        }
      ),
      un.fmtad(
        [[
          for (const <item> of <items>) {
          <body>
          }
        ]],
        {
          item = i(1, 'item'),
          items = i(2, 'items'),
          body = un.body(3, 1),
        }
      ),
    })
  ),
  us.msn(
    {
      { trig = 'tr' },
      { trig = 'try' },
      common = { desc = 'try-catch block' },
    },
    un.fmtad(
      [[
        try {
        <body>
        } catch (<err>) {
        <catch_body>
        }
      ]],
      {
        body = un.body(1, 1),
        err = i(2, 'error'),
        catch_body = un.body(3, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'cat' },
      { trig = 'catch' },
      common = { desc = 'catch block' },
    },
    un.fmtad(
      [[
        catch (<err>) {
        <body>
        }
      ]],
      {
        err = i(1, 'error'),
        body = un.body(2, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fin' },
      { trig = 'final' },
      { trig = 'finally' },
      common = { desc = 'finally block' },
    },
    un.fmtad(
      [[
        finally {
        <body>
        }
      ]],
      {
        body = un.body(1, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'im' },
      { trig = 'imp' },
      common = { desc = 'Import statement' },
    },
    c(1, {
      un.fmtad('import { <what> } from "<module>"', {
        what = r(1, 'what'),
        module = r(2, 'module'),
      }),
      un.fmtad('import <what> from "<module>"', {
        what = r(1, 'what'),
        module = r(2, 'module'),
      }),
    }),
    {
      common_opts = {
        stored = {
          what = i(nil, 'what'),
          module = i(nil, 'module'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'ex' },
      { trig = 'exp' },
      common = { desc = 'Export statement' },
    },
    c(1, {
      un.fmtad('export { <what> }', {
        what = r(1, 'what'),
      }),
      un.fmtad('export default <what>', {
        what = r(1, 'what'),
      }),
    }),
    {
      common_opts = {
        stored = {
          what = i(nil, 'what'),
        },
      },
    }
  ),
}

return M
