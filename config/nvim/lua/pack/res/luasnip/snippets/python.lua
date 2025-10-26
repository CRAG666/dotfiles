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
  }, t('return')),
  us.sn(
    {
      trig = 'pr',
      desc = 'print()',
    },
    un.fmtad('print(<expr>)', {
      expr = i(1),
    })
  ),
  us.sn(
    {
      trig = 'op',
      desc = 'open()',
    },
    un.fmtad('<fd> = open(<q><file><q>, encoding=<q><encoding><q><kwargs>)', {
      fd = i(1, 'fd'),
      q = un.qt('"'),
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
        q = un.qt('"'),
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
      q = un.qt('"'),
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
      q = un.qt('"'),
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
      q = un.qt('"'),
      line = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
    })
  ),
  us.sn(
    {
      trig = 'lconf',
      desc = 'Config logging',
    },
    un.fmtad('logging.basicConfig(<out>, level=<level>)', {
      out = c(1, {
        un.fmtad('stream=<fd>', {
          fd = i(1, 'sys.stderr'),
        }),
        un.fmtad('filename=<q><fname><q>, filemode=<q><fmode><q>', {
          q = un.qt('"'),
          fname = d(1, function()
            return sn(nil, {
              i(
                1,
                string.format(
                  '%s.log',
                  vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t:r')
                )
              ),
            })
          end),
          fmode = i(2, 'a'),
        }),
      }),
      level = c(2, {
        i(nil, 'logging.DEBUG'),
        i(nil, 'logging.INFO'),
        i(nil, 'logging.WARNING'),
        i(nil, 'logging.ERROR'),
        i(nil, 'logging.CRITICAL'),
        i(nil, 'logging.NOTSET'),
      }),
    })
  ),
  us.sn(
    {
      trig = 'lg',
      desc = 'Create a new logger',
    },
    un.fmtad('logger = logging.getLogger(<name><e>)', {
      name = i(1, '__name__'),
      e = i(2),
    })
  ),
  us.sn(
    {
      trig = 'll',
      desc = 'Logger log',
    },
    c(1, {
      un.fmtad('logger.<level>(<msg><e>)', {
        level = c(1, {
          i(nil, 'info'),
          i(nil, 'warning'),
          i(nil, 'error'),
          i(nil, 'critical'),
          i(nil, 'debug'),
        }),
        msg = c(2, {
          un.fmtad('<q><m><q>', {
            q = un.qt('"'),
            m = r(1, 'msg'),
          }),
          un.fmtad('f<q><m><q>', {
            q = un.qt('"'),
            m = r(1, 'msg'),
          }),
        }),
        e = i(3),
      }),
      un.fmtad('logger.log(<level>, <msg><e>)', {
        level = c(1, {
          i(2, 'logging.INFO'),
          i(2, 'logging.WARNING'),
          i(2, 'logging.ERROR'),
          i(2, 'logging.CRITICAL'),
          i(2, 'logging.DEBUG'),
          i(2, 'logging.NOTSET'),
        }),
        msg = c(2, {
          un.fmtad('<q><m><q>', {
            q = un.qt('"'),
            m = r(1, 'msg'),
          }),
          un.fmtad('f<q><m><q>', {
            q = un.qt('"'),
            m = r(1, 'msg'),
          }),
        }),
        e = i(3),
      }),
    }),
    {
      stored = {
        msg = i(nil, 'msg'),
      },
    }
  ),
  us.sn(
    {
      trig = 'li',
      desc = 'logger.info()',
    },
    un.fmtad('logger.info(<msg><e>)', {
      msg = c(1, {
        un.fmtad('<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
        un.fmtad('f<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
      }),
      e = i(2),
    }),
    {
      stored = {
        msg = i(nil, 'msg'),
      },
    }
  ),
  us.sn(
    {
      trig = 'lw',
      desc = 'logger.warning()',
    },
    un.fmtad('logger.warning(<msg><e>)', {
      msg = c(1, {
        un.fmtad('<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
        un.fmtad('f<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
      }),
      e = i(2),
    }),
    {
      stored = {
        msg = i(nil, 'msg'),
      },
    }
  ),
  us.sn(
    {
      trig = 'le',
      desc = 'logger.error()',
    },
    un.fmtad('logger.error(<msg><e>)', {
      msg = c(1, {
        un.fmtad('<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
        un.fmtad('f<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
      }),
      e = i(2),
    }),
    {
      stored = {
        msg = i(nil, 'msg'),
      },
    }
  ),
  us.sn(
    {
      trig = 'lc',
      desc = 'logger.critical()',
    },
    un.fmtad('logger.critical(<msg><e>)', {
      msg = c(1, {
        un.fmtad('<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
        un.fmtad('f<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
      }),
      e = i(2),
    }),
    {
      stored = {
        msg = i(nil, 'msg'),
      },
    }
  ),
  us.sn(
    {
      trig = 'ld',
      desc = 'logger.debug()',
    },
    un.fmtad('logger.debug(<msg><e>)', {
      msg = c(1, {
        un.fmtad('<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
        un.fmtad('f<q><m><q>', {
          q = un.qt('"'),
          m = r(1, 'msg'),
        }),
      }),
      e = i(2),
    }),
    {
      stored = {
        msg = i(nil, 'msg'),
      },
    }
  ),
  us.sn(
    {
      trig = 'll',
      desc = 'Log a line',
    },
    un.fmtad('logger.debug(<q><line><q><e>)', {
      q = un.qt('"'),
      line = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
      e = i(2),
    })
  ),
  us.sn(
    {
      trig = 'lck',
      desc = 'Check a value of a variable through logger.debug()',
    },
    un.fmtad('logger.debug(f<q><expr_escaped>: {<expr>}<q><e>)', {
      q = un.qt('"'),
      expr = i(1),
      expr_escaped = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\' .. uf.get_quotation_type())
        return sn(nil, i(1, str))
      end, { 1 }),
      e = i(3),
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
      { trig = 'fr' },
      { trig = 'forr' },
      { trig = 'forange' },
      { trig = 'forrange' },
      common = { desc = 'for ... in ... loop' },
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
      common_opts = {
        stored = {
          var = i(nil, 'var'),
          iterable = i(nil, 'iterable'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fori' },
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
        name = i(1, 'ClassName'),
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
      { trig = 'en' },
      { trig = 'enu' },
      { trig = 'enum' },
      common = { desc = 'Enum classes' },
    },
    c(1, {
      un.fmtad(
        [[
          class <class_name>(Enum):
              <value1> = 1
              <value2> = 2
        ]],
        {
          class_name = r(1, 'class_name'),
          value1 = r(2, 'value1'),
          value2 = r(3, 'value2'),
        }
      ),
      un.fmtad(
        '<class_name> = Enum(<q><class_name><q>, [(<q><value1><q>, 1), (<q><value2><q>, 2)<i>])',
        {
          class_name = r(1, 'class_name'),
          value1 = r(2, 'value1'),
          value2 = r(3, 'value2'),
          i = i(4),
          q = un.qt('"'),
        }
      ),
    }),
    {
      common_opts = {
        stored = {
          class_name = i(nil, 'EnumClassName'),
          value1 = i(nil, 'ENUM_VALUE_1'),
          value2 = i(nil, 'ENUM_VALUE_2'),
        },
      },
    }
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
        except <exc><i>:
        <idnt><exc_body>
      ]],
      {
        body = un.body(1, 1, 'pass'),
        exc = c(2, {
          sn(nil, r(1, 'exc_name', i(nil, 'Exception'))),
          un.fmtad('<exc_name> as <e>', {
            exc_name = r(1, 'exc_name', i(nil, 'Exception')),
            e = i(2, 'e'),
          }),
        }),
        i = i(3),
        idnt = un.idnt(1),
        exc_body = i(4, 'pass'),
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
        except <exc><i>:
        <idnt><exc_body>
      ]],
      {
        exc = c(1, {
          sn(nil, r(1, 'exc_name', i(nil, 'Exception'))),
          un.fmtad('<exc_name> as <e>', {
            exc_name = r(1, 'exc_name', i(nil, 'Exception')),
            e = i(2, 'e'),
          }),
        }),
        i = i(2),
        idnt = un.idnt(1),
        exc_body = i(3, 'pass'),
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
        q = un.qt('"'),
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
        q = un.qt('"'),
        body = un.body(1, 0),
      }
    )
  ),
}

return M
