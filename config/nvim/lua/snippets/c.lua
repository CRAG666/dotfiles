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
  us.sn({
    trig = '/',
    priority = 999,
    desc = 'Block comment',
  }, {
    t('/* '),
    i(1),
    t(' */'),
  }),
  us.sN({
    trig = '//',
    desc = 'Multi-line block comment',
  }, {
    t({ '/*', '' }),
    t(' * '),
    i(1),
    t({ '', ' */' }),
  }),
  us.sn({
    trig = 'ret',
    desc = 'return statement',
  }, {
    t('return '),
    i(1),
    t(';'),
  }),
  us.sn(
    {
      trig = 'p',
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
    })
  ),
  us.sn(
    {
      trig = 'dp',
      desc = 'dbg_printf()',
    },
    c(1, {
      un.fmtad('dbg_printf("<str>\\n"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('dbg_printf("<str>"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
    })
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
      un.fmtad('dbg_assert(<expr>);', {
        expr = r(1, 'expr'),
      }),
      un.fmtad('dbg_assert((<expr>) && "<msg>\\n");', {
        expr = r(1, 'expr'),
        msg = r(2, 'msg'),
      }),
    })
  ),
  us.msn(
    {
      { trig = 'ck' },
      { trig = 'check' },
      common = { desc = 'Inspect through formatted string' },
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
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'pcheck' },
      common = { desc = 'Inspect through printf()' },
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
  us.msn(
    {
      { trig = 'dpck' },
      { trig = 'dpcheck' },
      common = { desc = 'Inspect through dbg_printf()' },
    },
    un.fmtad('dbg_printf("<expr_escaped>: <placeholder>\\n", <expr>);', {
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
      trig = 'dpl',
      desc = 'Print a line using dbg_printf()',
    },
    un.fmtad('dbg_printf("<line>\\n");', {
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
  us.sn(
    {
      trig = 'pl',
      desc = 'Print a line',
    },
    un.fmtad('printf("<line>\\n");', {
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
  us.ssn(
    {
      trig = 'ifndd',
      desc = '#ifndef...define preproc',
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
      { trig = 'switch' },
      common = { desc = 'switch statement' },
    },
    un.fmtad(
      [[
        switch (<var>) {
        <idnt>case <val>:
        <body>
        }
      ]],
      {
        var = i(1),
        val = i(2),
        idnt = un.idnt(1),
        body = un.body(3, 2),
      }
    )
  ),
  us.msn(
    {
      { trig = 'cs' },
      { trig = 'ca' },
      { trig = 'case' },
      common = { desc = 'case statement' },
    },
    un.fmtad(
      [[
        case <val>:
        <body>
      ]],
      {
        val = i(1),
        body = un.body(2, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      { trig = 'function' },
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
          params = i(3, 'int'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad('<type> <func>(<params>);', {
        type = r(1, 'type'),
        func = r(2, 'func'),
        params = i(3, 'int'),
      }),
    }),
    {
      common_opts = {
        stored = {
          type = i(1, 'int'),
          func = i(2, 'fn_name'),
        },
      },
    }
  ),
  us.msn(
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
}

return M
