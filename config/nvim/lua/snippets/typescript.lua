local M = {}
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local r = ls.restore_node

M.javascript = require('snippets.javascript').snippets

M.snippets = {
  us.msn(
    {
      { trig = 'con' },
      { trig = 'const' },
      common = {
        priority = 1001,
        desc = 'Constant variable declaration',
      },
    },
    c(1, {
      un.fmtad('const <name>: <type> = <value>', {
        name = r(1, 'name'),
        type = r(2, 'type'),
        value = r(3, 'value'),
      }),
      un.fmtad('const <name> = <value>', {
        name = r(1, 'name'),
        value = r(2, 'value'),
      }),
    }),
    {
      stored = {
        name = i(nil, 'variable'),
        type = i(nil, 'any'),
        value = i(nil, 'undefined'),
      },
    }
  ),
  us.msn(
    {
      { trig = 'cona' },
      { trig = 'consta' },
      common = {
        priority = 1001,
        desc = 'Constant array/object variable declaration',
      },
    },
    c(1, {
      un.fmtad('const <name>: <type>[] = [<value>]', {
        name = r(1, 'name'),
        type = i(2, 'string'),
        value = i(3),
      }),
      un.fmtad('const <name>: Record<<<key>, <val>>> = {<value>}', {
        name = r(1, 'name'),
        key = i(2, 'string'),
        val = i(3, 'any'),
        value = i(4),
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
      common = {
        priority = 1001,
        desc = 'Variable declaration',
      },
    },
    c(1, {
      un.fmtad('let <name>: <type> = <value>', {
        name = r(1, 'name'),
        type = r(2, 'type'),
        value = r(3, 'value'),
      }),
      un.fmtad('let <name> = <value>', {
        name = r(1, 'name'),
        value = r(2, 'value'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(nil, 'variable'),
          type = i(nil, 'any'),
          value = i(nil, 'undefined'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'va' },
      { trig = 'vara' },
      { trig = 'leta' },
      common = {
        priority = 1001,
        desc = 'Array/object variable declaration',
      },
    },
    c(1, {
      un.fmtad('let <name>: <type>[] = [<value>]', {
        name = r(1, 'name'),
        type = r(2, 'type'),
        value = r(3, 'value'),
      }),
      un.fmtad('let <name>: Record<<<key>, <val>>> = {<value>}', {
        name = r(1, 'name'),
        key = i(2, 'key'),
        val = i(3, 'any'),
        value = r(4, 'value'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(nil, 'variable'),
          type = i(nil, 'any'),
          value = i(nil, 'value'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      common = {
        priority = 1001,
        desc = 'Function definition',
      },
    },
    c(1, {
      un.fmtad(
        [[
          function <name>(<params>): <ret> {
          <body>
          }
        ]],
        {
          name = r(1, 'name'),
          params = r(2, 'params'),
          ret = r(3, 'ret'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad(
        [[
          const <name> = (<params>): <ret> =>> {
          <body>
          }
        ]],
        {
          name = r(1, 'name'),
          params = r(2, 'params'),
          ret = r(3, 'ret'),
          body = un.body(4, 1),
        }
      ),
    }),
    {
      common_opts = {
        stored = {
          name = i(nil, 'functionName'),
          params = i(nil),
          ret = i(nil, 'void'),
        },
      },
    }
  ),
  us.sn({
    trig = 'ret',
    desc = 'return statement',
  }, t('return ')),
  us.sn(
    {
      trig = 'ifa',
      desc = 'Interface definition',
    },
    un.fmtad(
      [[
        interface <name> {
        <body>
        }
      ]],
      {
        name = i(1, 'InterfaceName'),
        body = un.body(2, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'tp' },
      { trig = 'type' },
      common = { desc = 'Type definition' },
    },
    un.fmtad(
      [[
        type <name> = {
        <body>
        }
      ]],
      {
        name = i(1, 'TypeName'),
        body = un.body(2, 1),
      }
    )
  ),
}

return M
