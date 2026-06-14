local M = {}
local uf = require('my.utils.snip.funcs')
local un = require('my.utils.snip.nodes')
local us = require('my.utils.snip.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local f = ls.function_node

M.snippets = {
  us.sn({
    trig = 'ret',
    desc = 'return statement',
  }, {
    t('return'),
    i(1),
    t(';'),
  }),
  us.sn({
    trig = 'cont',
    desc = 'continue statement',
  }, t('continue')),
  us.sn({
    trig = 'brk',
    desc = 'break statement',
  }, t('break')),
  us.sn(
    {
      trig = 'fp',
      desc = 'fprintf()',
    },
    c(1, {
      un.fmtad('fprintf(<file>, "<str>\\n"<args>);', {
        file = r(1, 'file'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
      un.fmtad('fprintf(<file>, "<str>"<args>);', {
        file = r(1, 'file'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
    }),
    {
      stored = {
        file = i(nil, 'stderr'),
      },
    }
  ),
  us.sn(
    {
      trig = 'pr',
      desc = 'printf()',
    },
    c(1, {
      un.fmtad('printf("<str>\\n"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('printf("<str>"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fprintf(<file>, "<str>\\n"<args>);', {
        file = r(1, 'file'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
      un.fmtad('fprintf(<file>, "<str>"<args>);', {
        file = r(1, 'file'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
    }),
    {
      stored = {
        file = i(nil, 'stderr'),
      },
    }
  ),
  us.ssn(
    {
      trig = 'dbg',
      desc = 'Define DEBUG macro',
    },
    un.fmtad(
      [[
      #ifndef <dbg_flag>
      #define <dbg_flag> <default>
      #endif // ifndef <dbg_flag>
    ]],
      {
        dbg_flag = i(1, 'DEBUG'),
        default = i(2, '0'),
      }
    )
  ),
  us.ssn(
    {
      trig = 'nl',
      desc = 'Define log_msg macro',
    },
    un.fmtad(
      [[
        #define <log_msg>(fmt, ...)<spacing> \
        <idnt>printf("[%s:%d %s] " fmt, __FILE__, __LINE__, \
        <idnt>       __func__ __VA_OPT__(, ) __VA_ARGS__)
      ]],
      {
        log_msg = i(1, 'log_msg'),
        ---@param args string[][]
        spacing = f(function(args)
          local logger_name = args[1][1]
          return string.rep(
            ' ',
            vim.bo.shiftwidth
              + #'printf("[%s:%d %s] " fmt, __FILE__, __LINE__,'
              - #(string.format('#define %s(fmt, ...)', logger_name))
          )
        end, { 1 }),
        idnt = un.idnt(1),
      }
    )
  ),
  us.ssn(
    {
      trig = 'ndl',
      desc = 'Define dbg_log macro',
    },
    un.fmtad(
      [[
        #if <dbg_flag>
        #define <dbg_log>(...) <log_msg>(__VA_ARGS__)
        #else
        #define <dbg_log>(...) ((void)0)
        #endif // <dbg_flag>
      ]],
      {
        dbg_flag = i(1, 'DEBUG'),
        dbg_log = i(2, 'dbg_log'),
        log_msg = i(3, 'log_msg'),
      }
    )
  ),
  us.sn(
    {
      trig = 'll',
      desc = 'log_msg()',
    },
    c(1, {
      un.fmtad('<log_msg>("<str>\\n"<args>);', {
        log_msg = r(1, 'log_msg'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
      un.fmtad('<log_msg>("<str>"<args>);', {
        log_msg = r(1, 'log_msg'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
    }),
    {
      stored = {
        log_msg = i(nil, 'log_msg'),
      },
    }
  ),
  us.sn(
    {
      trig = 'dp',
      desc = 'dbg_printf()',
    },
    c(1, {
      un.fmtad('<dbg_printf>("<str>\\n"<args>);', {
        dbg_printf = r(1, 'dbg_printf'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
      un.fmtad('<dbg_printf>("<str>"<args>);', {
        dbg_printf = r(1, 'dbg_printf'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
    }),
    {
      stored = {
        dbg_printf = i(nil, 'dbg_printf'),
      },
    }
  ),
  us.sn(
    {
      trig = 'dl',
      desc = 'dbg_log()',
    },
    c(1, {
      un.fmtad('<dbg_log>("<str>\\n"<args>);', {
        dbg_log = r(1, 'dbg_log'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
      un.fmtad('<dbg_log>("<str>"<args>);', {
        dbg_log = r(1, 'dbg_log'),
        str = r(2, 'str'),
        args = r(3, 'args'),
      }),
    }),
    {
      stored = {
        dbg_log = i(nil, 'dbg_log'),
      },
    }
  ),
  us.sn(
    {
      trig = 'as',
      desc = 'assert()',
    },
    c(1, {
      un.fmtad('assert(<expr>);', {
        expr = r(1, 'expr'),
      }),
      un.fmtad('assert((<expr>) && "<msg>\\n");', {
        expr = r(1, 'expr'),
        msg = r(2, 'msg'),
      }),
    })
  ),
  us.sn(
    {
      trig = 'da',
      desc = 'dbg_assert()',
    },
    c(1, {
      un.fmtad('<dbg_assert>(<expr>);', {
        dbg_assert = r(1, 'dbg_assert'),
        expr = r(2, 'expr'),
      }),
      un.fmtad('<dbg_assert>((<expr>) && "<msg>\\n");', {
        dbg_assert = r(1, 'dbg_assert'),
        expr = r(2, 'expr'),
        msg = r(3, 'msg'),
      }),
      {
        stored = {
          dbg_assert = i(nil, 'dbg_assert'),
        },
      },
    })
  ),
  us.sn(
    {
      trig = 'ck',
      desc = 'Inspect through formatted string',
    },
    un.fmtad('"<expr_escaped>: <placeholder>\\n", <expr>', {
      expr = i(1),
      expr_escaped = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\"')
        return sn(nil, i(1, str))
      end, { 1 }),
      placeholder = c(3, {
        i(nil, '%d'),
        i(nil, '0x%x'),
        i(nil, '%lu'),
        i(nil, '%ld'),
        i(nil, '%s'),
        i(nil, '%p'),
        i(nil, '%lf'),
        i(nil, '%f'),
        i(nil, '%g'),
        i(nil, '%c'),
      }),
    })
  ),
  us.sn(
    {
      trig = 'pck',
      desc = 'Inspect through printf()',
    },
    un.fmtad('printf("<expr_escaped>: <placeholder>\\n", <expr>);', {
      expr = i(1),
      expr_escaped = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\"')
        return sn(nil, i(1, str))
      end, { 1 }),
      placeholder = c(3, {
        i(nil, '%d'),
        i(nil, '0x%x'),
        i(nil, '%lu'),
        i(nil, '%ld'),
        i(nil, '%s'),
        i(nil, '%p'),
        i(nil, '%lf'),
        i(nil, '%f'),
        i(nil, '%g'),
        i(nil, '%c'),
      }),
    })
  ),
  us.sn(
    {
      trig = 'dpck',
      desc = 'Inspect through dbg_printf()',
    },
    un.fmtad('<dbg_printf>("<expr_escaped>: <placeholder>\\n", <expr>);', {
      dbg_printf = i(1, 'dbg_printf'),
      expr = i(2),
      expr_escaped = d(3, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\"')
        return sn(nil, i(1, str))
      end, { 2 }),
      placeholder = c(4, {
        i(nil, '%d'),
        i(nil, '0x%x'),
        i(nil, '%lu'),
        i(nil, '%ld'),
        i(nil, '%s'),
        i(nil, '%p'),
        i(nil, '%lf'),
        i(nil, '%f'),
        i(nil, '%g'),
        i(nil, '%c'),
      }),
    })
  ),
  us.sn(
    {
      trig = 'dpl',
      desc = 'Print a line using dbg_printf()',
    },
    un.fmtad('<dbg_printf>("<line>\\n");', {
      dbg_printf = i(1, 'dbg_printf'),
      line = c(2, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
    })
  ),
  us.sn(
    {
      trig = 'pl',
      desc = 'Print a line',
    },
    un.fmtad('printf("<line>\\n");', {
      line = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
    })
  ),
  us.ssn({
    trig = 'inc',
    desc = '#include preproc',
  }, {
    t('#include '),
    c(1, {
      sn(nil, { t('<'), r(1, 'header'), t('>') }),
      sn(nil, { t('"'), r(1, 'header'), t('"') }),
    }),
  }),
  us.ssn({
    trig = 'def',
    desc = '#define preproc',
  }, t('#define ')),
  us.ssn(
    {
      trig = 'if',
      desc = '#if preproc',
    },
    un.fmtad(
      [[
        #if <cond>
        <body>
        #endif // <cond>
      ]],
      {
        cond = i(1),
        body = un.body(2, 0),
      }
    )
  ),
  us.mssn(
    {
      { trig = 'ife' },
      { trig = 'ifel' },
      { trig = 'ifelse' },
      common = { desc = '#if...#else preproc' },
    },
    un.fmtad(
      [[
        #if <cond>
        <body>
        #else
        <else_body>
        #endif // <cond>
      ]],
      {
        cond = i(1),
        body = un.body(2, 0),
        else_body = i(3),
      }
    )
  ),
  us.mssn(
    {
      { trig = 'ifei' },
      { trig = 'ifeif' },
      { trig = 'ifeli' },
      { trig = 'ifelif' },
      { trig = 'ifelsei' },
      { trig = 'ifelseif' },
      common = { desc = '#if...#elif preproc' },
    },
    un.fmtad(
      [[
        #if <cond>
        <body>
        #elif <cond_else>
        <body_else>
        #endif // <cond>
      ]],
      {
        cond = i(1),
        body = un.body(2, 0),
        cond_else = i(3),
        body_else = i(4),
      }
    )
  ),
  us.mssn(
    {
      { trig = 'el' },
      { trig = 'else' },
      common = { desc = '#else preproc' },
    },
    un.fmtad(
      [[
        #else
        <body>
      ]],
      { body = un.body(1, 0) }
    )
  ),
  us.mssn(
    {
      { trig = 'eli' },
      { trig = 'elif' },
      { trig = 'elsei' },
      { trig = 'elseif' },
      common = { desc = '#elif preproc' },
    },
    un.fmtad(
      [[
        #elif <cond_else>
        <body_else>
      ]],
      {
        cond_else = i(1),
        body_else = i(2),
      }
    )
  ),
  us.ssn(
    {
      trig = 'ifd',
      desc = '#ifdef preproc',
    },
    un.fmtad(
      [[
        #ifdef <var>
        <body>
        #endif // ifdef <var>
      ]],
      {
        var = i(1),
        body = un.body(2, 0),
      }
    )
  ),
  us.ssn(
    {
      trig = 'ifnd',
      desc = '#ifndef preproc',
    },
    un.fmtad(
      [[
        #ifndef <var>
        <body>
        #endif // ifndef <var>
      ]],
      {
        var = i(1),
        body = un.body(2, 0),
      }
    )
  ),
  us.mssn(
    {
      { trig = 'ifndd' },
      { trig = 'grd' },
      common = { desc = '#ifndef...define preproc' },
    },
    un.fmtad(
      [[
        #ifndef <var>
        #define <var>
        <body>
        #endif // ifndef <var>
      ]],
      {
        var = d(1, function()
          local bufname = vim.api.nvim_buf_get_name(0)
          local ext = vim.fn.fnamemodify(bufname, ':e')
          if ext == 'h' or ext == 'hpp' then
            local str = vim.fn
              .fnamemodify(bufname, ':t')
              :gsub('[^0-9a-zA-z_]+', '_')
              :upper()
            return sn(nil, i(1, str))
          end
          return sn(nil, i(1))
        end),
        body = un.body(2, 0),
      }
    )
  ),
  us.sn(
    {
      trig = 'if',
      desc = 'if statement',
      priority = 999,
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
      { trig = 'ifei' },
      { trig = 'ifeif' },
      { trig = 'ifeli' },
      { trig = 'ifelif' },
      { trig = 'ifelsei' },
      { trig = 'ifelseif' },
      common = { desc = 'if...else if statement' },
    },
    un.fmtad(
      [[
        if (<cond>) {
        <body>
        } else if (<cond_else>) {
        <body_else>
        }
      ]],
      {
        cond = i(1),
        body = un.body(2, 1),
        cond_else = i(3),
        body_else = i(4),
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
        else {
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
      {
        cond = i(1),
        body = un.body(2, 1),
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
    )
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fori' },
      common = { desc = 'for i loop' },
    },
    un.fmtad(
      [[
        for (<type> <i> = <init>; <cond>; <inc>) {
        <body>
        }
      ]],
      {
        type = i(1, 'int'),
        i = i(2, 'i'),
        init = i(3, '0'),
        cond = i(4),
        inc = i(5),
        body = un.body(6, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'f_' },
      { trig = 'f-' },
      { trig = 'for_' },
      { trig = 'for-' },
      common = { desc = 'for _ loop' },
    },
    un.fmtad(
      [[
        for (<type> <i> = <init>; <cond>; <inc>) {
        <body>
        }
      ]],
      {
        type = i(1, 'int'),
        i = i(2, '_'),
        init = i(3, '0'),
        cond = i(4),
        inc = i(5),
        body = un.body(6, 1),
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
      { trig = 'dwh' },
      { trig = 'dowh' },
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
        cond = i(1),
        body = un.body(2, 1),
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
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      common = { desc = 'Function definition/declaration' },
    },
    c(1, {
      un.fmtad(
        [[
          <type> <func>(<params>) {
          <body>
          }
        ]],
        {
          type = r(1, 'type'),
          func = r(2, 'func'),
          params = r(3, 'params'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad('<type> <func>(<params>);', {
        type = r(1, 'type'),
        func = r(2, 'func'),
        params = r(3, 'params'),
      }),
    }),
    {
      common_opts = {
        stored = {
          type = i(nil, 'void'),
          func = i(nil, 'fn_name'),
          params = i(nil),
        },
      },
    }
  ),
  us.mssn(
    {
      { trig = 'mn' },
      { trig = 'main' },
      common = { desc = 'main function' },
    },
    un.fmtad(
      [[
        int main(<args>) {
        <body>
        <idnt>return 0;
        }
      ]],
      {
        args = c(1, {
          i(nil, 'void'),
          i(nil, 'int argc, char **argv'),
        }),
        body = un.body(2, 1),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'st' },
      { trig = 'struct' },
      common = { desc = 'Struct definition/declaration' },
    },
    c(1, {
      un.fmtad(
        [[
          struct <name> {
          <body>
          };
        ]],
        {
          name = r(1, 'name'),
          body = un.body(2, 1),
        }
      ),
      un.fmtad('struct <name>;', {
        name = r(1, 'name'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(nil, 'struct_name'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'un' },
      { trig = 'union' },
      common = { desc = 'Union definition/declaration' },
    },
    c(1, {
      un.fmtad(
        [[
          union <name> {
          <body>
          };
        ]],
        {
          name = r(1, 'name'),
          body = un.body(2, 1),
        }
      ),
      un.fmtad('union <name>;', {
        name = r(1, 'name'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(1, 'union_name'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'en' },
      { trig = 'enu' },
      { trig = 'enum' },
      common = { desc = 'Enum definition/declaration' },
    },
    c(1, {
      un.fmtad(
        [[
          enum <name> {
          <body>
          };
        ]],
        {
          name = r(1, 'name'),
          body = un.body(2, 1),
        }
      ),
      un.fmtad('enum <name>;', {
        name = r(1, 'name'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(nil, 'enum_name'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'tp' },
      { trig = 'type' },
      { trig = 'typedef' },
      common = { desc = 'typedef statement' },
    },
    c(1, {
      sn(nil, {
        t('typedef '),
        i(1, 'type'),
        t(' '),
        r(2, 'alias'),
        t(';'),
      }),
      sn(nil, {
        t('typedef '),
        r(1, 'alias'),
        t(';'),
      }),
    }),
    {
      common_opts = {
        stored = {
          alias = i(nil, 'alias'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'tps' },
      { trig = 'tpst' },
      { trig = 'tpstruct' },
      { trig = 'typedefs' },
      { trig = 'typedefst' },
      { trig = 'typedefstruct' },
      common = { desc = 'typedef struct definition/declaration statement' },
    },
    c(1, {
      un.fmtad(
        [[
          typedef struct <name> {
          <body>
          } <alias>;
        ]],
        {
          name = r(1, 'name'),
          body = un.body(3, 1),
          alias = r(2, 'alias'),
        }
      ),
      un.fmtad('typedef struct <name> <alias>;', {
        name = r(1, 'name'),
        alias = r(2, 'alias'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(1, 'name'),
          alias = i(2, 'alias'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'tpu' },
      { trig = 'tpun' },
      { trig = 'tpunion' },
      { trig = 'typedefu' },
      { trig = 'typedefun' },
      { trig = 'typedefunion' },
      common = { desc = 'typedef union definition/declaration statement' },
    },
    c(1, {
      un.fmtad(
        [[
          typedef union <name> {
          <body>
          } <alias>;
        ]],
        {
          name = r(1, 'name'),
          body = un.body(3, 1),
          alias = r(2, 'alias'),
        }
      ),
      un.fmtad('typedef union <name> <alias>;', {
        name = r(1, 'name'),
        alias = r(2, 'alias'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(1, 'name'),
          alias = i(2, 'alias'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'tpe' },
      { trig = 'tpen' },
      { trig = 'tpenu' },
      { trig = 'tpenum' },
      { trig = 'typedefe' },
      { trig = 'typedefen' },
      { trig = 'typedefenu' },
      { trig = 'typedefenum' },
      common = { desc = 'typedef enum definition/declaration statement' },
    },
    c(1, {
      un.fmtad(
        [[
          typedef enum <name> {
          <body>
          } <alias>;
        ]],
        {
          name = r(1, 'name'),
          body = un.body(3, 1),
          alias = r(2, 'alias'),
        }
      ),
      un.fmtad('typedef enum <name> <alias>;', {
        name = r(1, 'name'),
        alias = r(2, 'alias'),
      }),
    }),
    {
      common_opts = {
        stored = {
          name = i(1, 'name'),
          alias = i(2, 'alias'),
        },
      },
    }
  ),
  us.sn(
    { trig = 'nf', desc = 'Disable clang-format' },
    un.fmtad(
      [[
        // clang-format off
        <body>
        // clang-format on
      ]],
      { body = un.body(1, 0) }
    )
  ),
}

return M
