local M = {}
local uf = require('utils.snip.funcs')
local un = require('utils.snip.nodes')
local us = require('utils.snip.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

M.snippets = {
  us.sn(
    { trig = 'pkg', desc = 'package statement' },
    { t('package '), i(1, 'main'), t(';') }
  ),
  us.msn({
    { trig = 'im' },
    { trig = 'imp' },
    common = { desc = 'import statement' },
  }, {
    t('import '),
    i(1, 'java.util.*'),
    t(';'),
  }),

  us.sn(
    { trig = 'ret', desc = 'return statement' },
    { t('return'), i(1), t(';') }
  ),

  us.sn(
    { trig = 'pr', desc = 'System.out print' },
    c(1, {
      un.fmtad('System.out.println(<expr>);', { expr = i(1) }),
      un.fmtad('System.out.printf("<str>\\n"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('System.out.printf("<str>"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
    })
  ),
  us.sn(
    { trig = 'pln', desc = 'System.out.println()' },
    un.fmtad('System.out.println(<expr>);', {
      expr = i(1),
    })
  ),
  us.sn(
    {
      trig = 'pck',
      desc = 'Check a value of a variable or expression',
    },
    un.fmtad(
      'System.out.printf("<expr_escaped>: <placeholder>\\n", <expr>);',
      {
        expr = r(1, 'expr'),
        expr_escaped = d(2, function(texts)
          local str = vim.fn.escape(texts[1][1], '\\"')
          return sn(nil, i(1, str))
        end, { 1 }),
        placeholder = c(3, {
          i(nil, '%s'),
          i(nil, '%d'),
          i(nil, '%#x'),
          i(nil, '%f'),
          i(nil, '%g'),
          i(nil, '%c'),
        }),
      }
    )
  ),
  us.sn(
    {
      trig = 'lck',
      desc = 'Check a value of a variable or expression in log',
    },
    un.fmtad('log.debug("<expr_escaped>: {}", <expr>);', {
      expr = r(1, 'expr'),
      expr_escaped = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\"')
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn(
    { trig = 'pf', desc = 'System.out.printf()' },
    c(1, {
      un.fmtad('System.out.printf("<str>\\n"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('System.out.printf("<str>"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
    })
  ),
  us.sn(
    { trig = 'pe', desc = 'System.err.println()' },
    un.fmtad('System.err.println(<expr>);', { expr = i(1) })
  ),

  us.sn(
    { trig = 'ck', desc = 'Inspect value with printf' },
    un.fmtad(
      'System.out.printf("<expr_escaped>: <placeholder>\\n", <expr>);',
      {
        expr = i(1),
        expr_escaped = d(2, function(texts)
          local str = vim.fn.escape(texts[1][1], '\\"')
          return sn(nil, i(1, str))
        end, { 1 }),
        placeholder = c(3, {
          i(nil, '%d'),
          i(nil, '0x%x'),
          i(nil, '%s'),
          i(nil, '%f'),
          i(nil, '%g'),
          i(nil, '%c'),
        }),
      }
    )
  ),
  us.sn(
    { trig = 'pl', desc = 'Print a line' },
    un.fmtad('System.out.println("<line>");', {
      line = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
    })
  ),

  us.sn(
    { trig = 'll', desc = 'Log a line' },
    un.fmtad('<logger>("<line>");', {
      line = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
      logger = c(2, {
        i(nil, 'log.debug'),
        i(nil, 'logger.fine'),
        i(nil, 'System.out.println'),
      }),
    })
  ),

  us.sn(
    { trig = 'lg', desc = 'SLF4J new logger' },
    un.fmtad(
      'private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(<cls>.class);',
      {
        cls = i(1, 'ClassName'),
      }
    )
  ),
  us.sn(
    { trig = 'll', desc = 'SLF4J log' },
    un.fmtad('log.<level>(<msg><args>);', {
      level = c(1, {
        i(nil, 'info'),
        i(nil, 'debug'),
        i(nil, 'warn'),
        i(nil, 'error'),
        i(nil, 'trace'),
      }),
      msg = c(2, {
        un.fmtad('"<m>"', { m = r(1, 'msg') }),
        un.fmtad('"<m>: {}"', { m = r(1, 'msg') }),
      }),
      args = i(3),
    }),
    {
      stored = {
        msg = i(nil, 'msg'),
      },
    }
  ),

  us.sn(
    { trig = 'jln', desc = 'JUL new logger' },
    un.fmtad(
      'private static final java.util.logging.Logger logger = java.util.logging.Logger.getLogger(<cls>.class.getName());',
      {
        cls = i(1, 'ClassName'),
      }
    )
  ),
  us.sn(
    { trig = 'jlg', desc = 'JUL log' },
    un.fmtad('logger.log(java.util.logging.Level.<level>, <msg><e>);', {
      level = c(1, {
        i(nil, 'INFO'),
        i(nil, 'WARNING'),
        i(nil, 'SEVERE'),
        i(nil, 'FINE'),
        i(nil, 'FINER'),
        i(nil, 'FINEST'),
        i(nil, 'CONFIG'),
      }),
      msg = c(2, {
        un.fmtad('"<m>"', { m = r(1, 'msg') }),
        un.fmtad(
          'String.format("<m>: %s", <arg>)',
          { m = r(1, 'msg'), arg = i(2, 'arg') }
        ),
      }),
      e = i(3),
    }),
    {
      stored = {
        msg = i(nil, 'msg'),
      },
    }
  ),

  us.sn(
    { trig = 'if', desc = 'if statement' },
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
        <body_else>
        }
      ]],
      {
        cond = i(1),
        body = un.body(2, 1),
        body_else = un.body(3, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'eli' },
      { trig = 'elif' },
      { trig = 'elsei' },
      { trig = 'elseif' },
      common = { desc = 'else if statement' },
    },
    un.fmtad(
      [[
        else if (<cond>) {
        <body>
        }
      ]],
      { cond = i(1), body = un.body(2, 1) }
    )
  ),

  us.sn(
    { trig = 'for', desc = 'for loop' },
    c(1, {
      un.fmtad(
        [[
          for (<type> <var> : <iterable>) {
          <body>
          }
        ]],
        {
          type = i(1, 'varType'),
          var = i(2, 'v'),
          iterable = i(3, 'iterable'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad(
        [[
          for (<init>; <cond>; <inc>) {
          <body>
          }
        ]],
        {
          init = i(1),
          cond = i(2),
          inc = i(3),
          body = un.body(4, 1),
        }
      ),
    })
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fori' },
      common = { desc = 'for i loop' },
    },
    un.fmtad(
      [[
        for (<init>; <cond>; <update>) {
        <body>
        }
      ]],
      {
        init = i(1),
        cond = i(2),
        update = i(3),
        body = un.body(4, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fr' },
      { trig = 'forr' },
      { trig = 'forange' },
      { trig = 'forrange' },
      common = { desc = 'for-each loop' },
    },
    un.fmtad(
      [[
        for (<type> <var> : <iterable>) {
        <body>
        }
      ]],
      {
        type = i(1, 'varType'),
        var = i(2, 'v'),
        iterable = i(3, 'iterable'),
        body = un.body(4, 1),
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
        while (<cond>) {
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
      { trig = 'dw' },
      { trig = 'dow' },
      { trig = 'dwhile' },
      { trig = 'dowhile' },
      common = { desc = 'do...while loop' },
    },
    un.fmtad(
      [[
        do {
        <body>
        } while (<cond>);
      ]],
      {
        body = un.body(1, 1),
        cond = i(2),
      }
    )
  ),
  us.msn(
    {
      { trig = 'sw' },
      { trig = 'swi' },
      { trig = 'switch' },
      desc = 'switch statement',
    },
    un.fmtad(
      [[
        switch (<expr>) {
        case <match1>:
        <body>
        <idnt>break;
        case <match2>:
        <idnt><i>
        <idnt>break;<e>
        default:
        <idnt><d>
        }
      ]],
      {
        idnt = un.idnt(1),
        expr = i(1, 'expr'),
        match1 = i(2, 'match1'),
        body = un.body(3, 1),
        match2 = i(4, 'match2'),
        i = i(5),
        e = i(6),
        d = i(7),
      }
    )
  ),
  us.msnr(
    {
      { trig = '^(%s*)ca' },
      { trig = '^(%s*)cas' },
      { trig = '^(%s*)case' },
      common = { desc = 'case statement' },
    },
    un.fmtad(
      [[
        <ddnt>case <match>:
        <body>
        <ddnt><idnt>break;
      ]],
      {
        ddnt = un.ddnt(1),
        idnt = un.idnt(1),
        match = i(1, 'match'),
        body = un.body(2, function(_, parent)
          return math.max(0, uf.get_indent_depth(parent.snippet.captures[1]))
        end),
      }
    )
  ),

  us.msn(
    {
      { trig = 'mn' },
      { trig = 'main' },
      common = { desc = 'main method' },
    },
    un.fmtad(
      [[
        public static void main(String[] args) {
        <body>
        }
      ]],
      { body = un.body(1, 1) }
    )
  ),
  us.msn(
    {
      { trig = 'cl' },
      { trig = 'cls' },
      { trig = 'class' },
      common = { desc = 'Class definition' },
    },
    un.fmtad(
      [[
        public class <name> {
        <body>
        }
      ]],
      { name = i(1, 'ClassName'), body = un.body(2, 1) }
    )
  ),
  us.msn(
    {
      { trig = 'ifc' },
      { trig = 'iface' },
      { trig = 'interface' },
      common = { desc = 'Interface definition' },
    },
    un.fmtad(
      [[
        public interface <name> {
        <body>
        }
      ]],
      { name = i(1, 'Interface'), body = un.body(2, 1) }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      { trig = 'me' },
      { trig = 'meth' },
      common = { desc = 'Method/function' },
    },
    c(1, {
      un.fmtad(
        [[
          <mods><ret> <name>(<params>) {
          <body>
          }
        ]],
        {
          mods = i(1, 'private '),
          ret = i(2, 'void'),
          name = i(3, 'methodName'),
          params = i(4),
          body = un.body(5, 1),
        }
      ),
      un.fmtad('<mods><ret> <name>(<params>);', {
        mods = i(1, 'private '),
        ret = i(2, 'void'),
        name = i(3, 'methodName'),
        params = i(4),
      }),
    })
  ),

  us.sn(
    { trig = 'var', desc = 'Variable declaration' },
    c(1, {
      un.fmtad('<type> <name> = <value>;', {
        type = r(1, 'type'),
        name = r(2, 'name'),
        value = i(3, 'value'),
      }),
      un.fmtad('<type> <name>;', {
        type = r(1, 'type'),
        name = r(2, 'name'),
      }),
    }),
    {
      stored = {
        type = i(nil, 'int'),
        name = i(nil, 'x'),
      },
    }
  ),
  us.msn(
    {
      { trig = 'con' },
      { trig = 'const' },
      common = { desc = 'Constant (final) declaration' },
    },
    c(1, {
      un.fmtad('final <type> <NAME> = <value>;', {
        type = r(1, 'type'),
        NAME = r(2, 'NAME'),
        value = i(3, 'value'),
      }),
      un.fmtad('static final <type> <NAME> = <value>;', {
        type = r(1, 'type'),
        NAME = r(2, 'NAME'),
        value = i(3, 'value'),
      }),
    }),
    {
      common_opts = {
        stored = {
          type = i(nil, 'int'),
          NAME = i(nil, 'CONST'),
        },
      },
    }
  ),

  us.msn(
    {
      { trig = 'en' },
      { trig = 'enu' },
      { trig = 'enum' },
      common = { desc = 'Enum definition' },
    },
    un.fmtad(
      [[
        public enum <name> {
        <idnt><value1>,
        <idnt><value2><i>
        }
      ]],
      {
        idnt = un.idnt(1),
        name = i(1, 'EnumName'),
        value1 = i(2, 'VALUE1'),
        value2 = i(3, 'VALUE2'),
        i = i(4),
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
        try {
        <body>
        } catch (<exc> <e>) {
        <idnt><exc_body>
        }
      ]],
      {
        body = un.body(1, 1),
        exc = i(2, 'Exception'),
        e = i(3, 'e'),
        idnt = un.idnt(1),
        exc_body = i(4),
      }
    )
  ),
}

return M
