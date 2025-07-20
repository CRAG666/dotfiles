local M = {}
local u = require('utils')
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
  us.mssn({
    { trig = 'pkg' },
    { trig = 'pack' },
    common = { desc = 'package statement' },
  }, {
    t('package '),
    i(1, 'main'),
  }),
  us.sn({
    trig = 'ret',
    desc = 'return statement',
  }, t('return ')),
  us.sn(
    {
      trig = 'p',
      desc = 'print statement',
    },
    c(1, {
      un.fmtad('fmt.Printf("<str>\\n"<args>)', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Printf("<str>"<args>)', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Println(<expr>)', {
        expr = i(1),
      }),
    })
  ),
  us.sn(
    {
      trig = 'pf',
      desc = 'fmt.Printf()',
    },
    c(1, {
      un.fmtad('fmt.Printf("<str>\\n"<args>)', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Printf("<str>"<args>)', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
    })
  ),
  us.sn(
    {
      trig = 'pln',
      desc = 'fmt.Println()',
    },
    un.fmtad('fmt.Println(<expr>)', {
      expr = i(1),
    })
  ),
  us.sn(
    {
      trig = 'fp',
      desc = 'fprint statement',
    },
    c(1, {
      un.fmtad('fmt.Fprintf(<w>, "<str>\\n"<args>)', {
        w = c(3, {
          i(nil, 'os.Stderr'),
          i(nil, 'os.Stdout'),
        }),
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Fprintf(<w>, "<str>"<args>)', {
        w = c(3, {
          i(nil, 'os.Stderr'),
          i(nil, 'os.Stdout'),
        }),
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Fprintln(<w>, <expr>)', {
        w = c(2, {
          i(nil, 'os.Stderr'),
          i(nil, 'os.Stdout'),
        }),
        expr = i(1),
      }),
    })
  ),
  us.sn(
    {
      trig = 'fpf',
      desc = 'fmt.Fprintf()',
    },
    c(1, {
      un.fmtad('fmt.Fprintf(<w>, "<str>"<args>)', {
        w = c(3, {
          i(nil, 'os.Stderr'),
          i(nil, 'os.Stdout'),
        }),
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Fprintln(<w>, <expr>)', {
        w = c(2, {
          i(nil, 'os.Stderr'),
          i(nil, 'os.Stdout'),
        }),
        expr = i(1),
      }),
    })
  ),
  us.sn(
    {
      trig = 'fpln',
      desc = 'fmt.Fprintln()',
    },
    un.fmtad('fmt.Println(<w>, <expr>)', {
      w = c(2, {
        i(nil, 'os.Stderr'),
        i(nil, 'os.Stdout'),
      }),
      expr = i(1),
    })
  ),
  us.sn(
    {
      trig = 'l',
      desc = 'testing.T.Log()',
    },
    un.fmtad('t.Log("<str>"<args>)', {
      str = i(1),
      args = i(2),
    })
  ),
  us.sn(
    {
      trig = 'lf',
      desc = 'testing.T.Logf()',
    },
    un.fmtad('t.Logf("<str>"<args>)', {
      str = i(1),
      args = i(2),
    })
  ),
  us.sn(
    {
      trig = 'ck',
      desc = 'Check a value of a variable',
    },
    c(1, {
      un.fmtad('"<expr_escaped>:", <expr>', {
        expr = r(1, 'expr'),
        expr_escaped = d(2, function(texts)
          return sn(nil, i(1, vim.fn.escape(texts[1][1], '\\"')))
        end, { 1 }),
      }),
      un.fmtad(
        '"<expr_escaped>:", func(x any) string { b, _ := json.MarshalIndent(x, "", "\\t"); return string(b) }(<expr>)',
        {
          expr = r(1, 'expr'),
          expr_escaped = d(2, function(texts)
            return sn(nil, i(1, vim.fn.escape(texts[1][1], '\\"')))
          end, { 1 }),
        }
      ),
    })
  ),
  us.sn(
    {
      trig = 'pck',
      desc = 'Check a value of a variable through fmt.Println()',
    },
    c(1, {
      un.fmtad('fmt.Println("<expr_escaped>:", <expr>)', {
        expr = r(1, 'expr'),
        expr_escaped = d(2, function(texts)
          local str = vim.fn.escape(texts[1][1], '\\"')
          return sn(nil, i(1, str))
        end, { 1 }),
      }),
      un.fmtad(
        'fmt.Println("<expr_escaped>:", func(x any) string { b, _ := json.MarshalIndent(x, "", "\\t"); return string(b) }(<expr>))',
        {
          expr = r(1, 'expr'),
          expr_escaped = d(2, function(texts)
            local str = vim.fn.escape(texts[1][1], '\\"')
            return sn(nil, i(1, str))
          end, { 1 }),
        }
      ),
    })
  ),
  us.sn(
    {
      trig = 'lck',
      desc = 'Check a value of a variable through testing.T.Log()',
    },
    c(1, {
      un.fmtad('t.Log("<expr_escaped>:", <expr>)', {
        expr = r(1, 'expr'),
        expr_escaped = d(2, function(texts)
          local str = vim.fn.escape(texts[1][1], '\\"')
          return sn(nil, i(1, str))
        end, { 1 }),
      }),
      un.fmtad(
        't.Log("<expr_escaped>:", func(x any) string { b, _ := json.MarshalIndent(x, "", "\\t"); return string(b) }(<expr>))',
        {
          expr = r(1, 'expr'),
          expr_escaped = d(2, function(texts)
            local str = vim.fn.escape(texts[1][1], '\\"')
            return sn(nil, i(1, str))
          end, { 1 }),
        }
      ),
    })
  ),
  us.sn(
    {
      trig = 'pl',
      desc = 'Print a line',
    },
    un.fmtad('fmt.Println("<line>")', {
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
      trig = 'fpl',
      desc = 'Print a line to given file descriptor',
    },
    un.fmtad('fmt.Fprintln(<w>, "<line>")', {
      w = c(2, {
        i(nil, 'os.Stderr'),
        i(nil, 'os.Stdout'),
      }),
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
      trig = 'll',
      desc = 'Log a line',
    },
    un.fmtad('t.Log("<line>")', {
      line = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
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
    i(0, 'package'),
  }),
  us.sn(
    {
      trig = 'if',
      desc = 'if statement',
    },
    un.fmtad(
      [[
        if <cond> {
        <body>
        }
      ]],
      {
        cond = i(1, 'cond'),
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
        if <cond> {
        <body>
        } else {
        <body_else>
        }
      ]],
      {
        cond = i(1, 'cond'),
        body = un.body(2, 1),
        body_else = un.body(3, 1),
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
        if <cond> {
        <body>
        } else if <cond_else> {
        <body_else>
        }
      ]],
      {
        cond = i(1, 'cond'),
        body = un.body(2, 1),
        cond_else = i(3, 'cond_else'),
        body_else = un.body(4, 1),
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
        else if <cond> {
        <body>
        }
      ]],
      {
        cond = i(1, 'cond'),
        body = un.body(2, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'ifer' },
      { trig = 'iferr' },
      common = { desc = 'Catch error' },
    },
    d(1, function(_, parent)
      -- Use default implementation if `iferr` is not available
      if vim.fn.executable('iferr') == -1 then
        return sn(nil, {
          t({ 'if err != nil {', '' }),
          un.body(1, 1),
          t({ '', '}' }),
        })
      end

      ---Selected text before expanding the snippet
      ---@type string[]
      local selected = parent.snippet.env.LS_SELECT_DEDENT

      -- Use `iferr` to generate the corresponding error check
      -- for functions with different return values
      -- See https://github.com/koron/iferr
      local o = vim
        .system(
          { 'iferr', '-pos', vim.fn.wordcount().cursor_bytes },
          { stdin = vim.api.nvim_buf_get_lines(0, 0, -1, false) }
        )
        :wait()
      if o.code ~= 0 then
        vim.notify(
          '[LuaSnip] `iferr` failed: ' .. o.stderr,
          vim.log.levels.WARN
        )
        return sn(nil, i(nil))
      end

      local lines =
        vim.split(o.stdout, '\n', { plain = true, trimempty = true })
      local first_line = table.remove(lines, 1) -- 'if err != nil {'
      local last_line = table.remove(lines, #lines) -- '}'
      local iferr_body = i(
        1,
        vim.tbl_map(function(line)
          return line:gsub('^\t', '')
        end, lines)
      )

      return vim.tbl_isempty(selected)
          and sn(1, {
            t({ first_line, '' }),
            un.idnt(1),
            iferr_body,
            t({ '', last_line }),
          })
        or sn(1, {
          t({ first_line, '' }),
          un.idnt(1),
          c(1, {
            un.body(1, 1),
            iferr_body,
          }),
          t({ '', last_line }),
        })
    end)
  ),
  us.msn(
    {
      { trig = 'en' },
      { trig = 'ne' },
      { trig = 'errn' },
      { trig = 'nerr' },
      common = { desc = 'New error' },
    },
    c(1, {
      un.fmtad('errors.New("<msg>")', {
        msg = r(1, 'msg'),
      }),
      un.fmtad('fmt.Errorf("<msg>"<args>)', {
        msg = r(1, 'msg'),
        args = i(2),
      }),
    })
  ),
  us.sn(
    {
      trig = 'for',
      desc = 'for loop',
    },
    c(1, {
      un.fmtad(
        [[
          for <idx> := range <length> {
            <body>
          }
        ]],
        {
          idx = r(1, 'idx'),
          length = i(2, 'length'),
          body = un.body(3, 1),
        }
      ),
      un.fmtad(
        [[
          for <idx> := <iter>; <cond>; <update> {
          <body>
          }
        ]],
        {
          idx = r(1, 'idx'),
          iter = r(2, 'iter'),
          cond = r(3, 'cond'),
          update = i(4, 'update'),
          body = un.body(5, 1),
        }
      ),
      un.fmtad(
        [[
          for <idx>, <var> := range <iter> {
          <body>
          }
        ]],
        {
          idx = r(1, 'idx'),
          var = i(2, 'var'),
          iter = r(3, 'iter'),
          body = un.body(4, 1),
        }
      ),
      un.fmtad(
        [[
          for <cond> {
          <body>
          }
        ]],
        {
          cond = r(1, 'cond'),
          body = un.body(2, 1),
        }
      ),
    }),
    {
      stored = {
        idx = i(nil, 'i'),
        iter = i(nil, 'iter'),
        cond = i(nil, 'cond'),
      },
    }
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fori' },
      common = { desc = 'for i := ... loop' },
    },
    c(1, {
      un.fmtad(
        [[
          for <idx> := range <length> {
            <body>
          }
        ]],
        {
          idx = r(1, 'idx'),
          length = i(2, 'length'),
          body = un.body(3, 1),
        }
      ),
      un.fmtad(
        [[
          for <idx> := <iter>; <cond>; <update> {
            <body>
          }
        ]],
        {
          idx = r(1, 'idx'),
          iter = i(2, 'iter'),
          cond = i(3, 'cond'),
          update = i(4, 'update'),
          body = un.body(5, 1),
        }
      ),
    }),
    {
      stored = {
        idx = i(nil, 'i'),
      },
    }
  ),
  us.msn(
    {
      { trig = 'fi' },
      { trig = 'fr' },
      { trig = 'forr' },
      { trig = 'fori' },
      { trig = 'forit' },
      { trig = 'foriter' },
      { trig = 'forange' },
      { trig = 'forrange' },
      common = { desc = 'for key, val := range ... loop' },
    },
    un.fmtad(
      [[
        for <idx>, <var> := range <iter> {
        <body>
        }
      ]],
      {
        idx = i(1, '_'),
        var = i(2, 'var'),
        iter = i(3, 'iter'),
        body = un.body(4, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'wh' },
      { trig = 'while' },
      common = { desc = 'for cond loop' },
    },
    un.fmtad(
      [[
        for <cond> {
        <body>
        }
      ]],
      {
        cond = i(1, 'true'),
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
        switch <expr> {
        case <match1>:
        <body>
        case <match2>:
        <idnt><i>
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
        d = i(6),
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
  us.sn(
    {
      trig = 'df',
      desc = 'default statement',
    },
    un.fmtad(
      [[
        default:
        <body>
      ]],
      {
        body = un.body(1, 1, false),
      }
    )
  ),
  us.msn({
    { trig = 'br' },
    { trig = 'brk' },
    common = { desc = 'break statement' },
  }, t('break')),
  us.msn({
    { trig = 'ct' },
    { trig = 'cont' },
    common = { desc = 'continue statement' },
  }, t('continue')),
  us.msn(
    {
      { trig = 'ifn' },
      { trig = 'ifun' },
      { trig = 'ifunc' },
      common = { desc = 'Immediate function evaluation' },
    },
    un.fmtad(
      [[
        (func(<args>) <ret> {
        <body>
        })(<vals>)
      ]],
      {
        vals = i(1),
        args = i(2),
        ret = i(3),
        body = un.body(4, 1),
      }
    )
  ),
  us.sn(
    {
      trig = 'gof',
      desc = 'go func()',
    },
    c(1, {
      un.fmtad(
        [[
          go func(<args>) {
          <body>
          }(<vals>)
        ]],
        {
          vals = r(1, 'vals'),
          args = r(2, 'args'),
          body = un.body(3, 1),
        }
      ),
      un.fmtad(
        [[
          go func(<args>) { <body> }(<vals>)
        ]],
        {
          vals = r(1, 'vals'),
          args = r(2, 'args'),
          body = un.body(1, 0),
        }
      ),
    }),
    {
      stored = {
        vals = i(),
        args = i(),
      },
    }
  ),
  us.sn(
    {
      trig = 'sel',
      desc = 'select statement',
    },
    un.fmtad(
      [[
        select {
        <cases>
        }
      ]],
      {
        cases = un.body(1, 0),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'fun' },
      { trig = 'func' },
      common = { desc = 'Function definition' },
    },
    d(1, function()
      if
        u.ts.find_node({
          'expression_list', --- []func(T) U{ func() { ... }, ... }
          'argument_list', -- foo(func() { ... }, ...)
          'assignment', -- val = function() ... end
          'short_var_declaration', -- val := func() { ... }
          'return_statement', -- return func() { ... }
          'binary_expression', -- <expression> and func() { ... }
          'parenthesized_expression', -- (func() { ... })()
        }, { ignore_injections = false })
      then
        -- Unnamed function
        return sn(
          nil,
          un.fmtad(
            [[
              func(<args>) <ret> {
              <body>
              }
            ]],
            {
              args = i(1),
              ret = i(2),
              body = un.body(3, 1),
            }
          )
        )
      end

      -- Nested functions must be anonymous
      if
        u.ts.find_node('function_declaration', { ignore_injections = false })
      then
        return sn(
          nil,
          c(1, {
            un.fmtad(
              [[
                <name> := func(<args>) <ret> {
                <body>
                }
              ]],
              {
                name = r(1, 'name', i(nil, 'funcName')),
                args = r(2, 'args', i()),
                ret = r(3, 'ret', i()),
                body = un.body(4, 1),
              }
            ),
            -- Anonymous functions must be declared beforehand to support
            -- recursion
            un.fmtad(
              [[
                var <name> = func(<args>) <ret>
                <name> = func(<args>) <ret> {
                <body>
                }
              ]],
              {
                name = r(1, 'name', i(nil, 'funcName')),
                args = r(2, 'args', i()),
                ret = r(3, 'ret', i()),
                body = un.body(4, 1),
              }
            ),
          })
        )
      end

      -- Named function
      return sn(
        nil,
        c(1, {
          un.fmtad(
            [[
              func <name>(<args>) <ret> {
              <body>
              }
            ]],
            {
              name = r(1, 'name', i(nil, 'funcName')),
              args = r(2, 'args', i()),
              ret = r(3, 'ret', i()),
              body = un.body(4, 1),
            }
          ),
          un.fmtad(
            [[
              func (<args>) <ret> {
              <body>
              }
            ]],
            {
              args = r(1, 'args', i()),
              ret = r(2, 'ret', i()),
              body = un.body(3, 1),
            }
          ),
        })
      )
    end),
    {
      common_opts = {
        stored = {
          name = i(nil, 'name'),
          struct = i(nil, 'struct'),
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
        func main(<args>) <ret> {
        <body>
        }
      ]],
      {
        args = r(1, 'args'),
        ret = r(2, 'ret'),
        body = un.body(3, 1),
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
        func (<struct>) <name>(<args>) <ret> {
        <body>
        }
      ]],
      {
        name = i(1, 'name'),
        args = i(2),
        ret = i(3),
        struct = i(4, 'struct'),
        body = un.body(5, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'st' },
      { trig = 'struct' },
      { trig = 'cls' },
      { trig = 'class' },
      common = { desc = 'Struct definition' },
    },
    un.fmtad(
      [[
        type <name> struct {
        <body>
        }
      ]],
      {
        name = i(1, 'name'),
        body = un.body(2, 1),
      }
    )
  ),
  us.sn(
    {
      trig = 'ifa',
      desc = 'Interface definition',
    },
    un.fmtad(
      [[
        type <name> interface {
        <body>
        }
      ]],
      {
        name = i(1, 'Interface'),
        body = un.body(2, 1),
      }
    )
  ),
  us.sn(
    {
      trig = 'var',
      desc = 'Variable declaration',
    },
    c(1, {
      un.fmtad(
        [[
          var <name> <type> = <value>
        ]],
        {
          name = r(1, 'name'),
          type = r(2, 'type'),
          value = i(3, 'value'),
        }
      ),
      un.fmtad(
        [[
          var <name> <type>
        ]],
        {
          name = r(1, 'name'),
          type = r(2, 'type'),
        }
      ),
    }),
    {
      stored = {
        name = i(nil, 'name'),
        type = i(nil, 'type'),
      },
    }
  ),
  us.msn(
    {
      { trig = 'con' },
      { trig = 'const' },
      common = { desc = 'Constant declaration' },
    },
    c(1, {
      un.fmtad(
        [[
          const <name> <type> = <value>
        ]],
        {
          name = r(1, 'name'),
          type = r(2, 'type'),
          value = i(3, 'value'),
        }
      ),
      un.fmtad(
        [[
          const <name> <type>
        ]],
        {
          name = r(1, 'name'),
          type = r(2, 'type'),
        }
      ),
    }),
    {
      common_opts = {
        stored = {
          name = i(nil, 'name'),
          type = i(nil, 'type'),
        },
      },
    }
  ),
  us.msn(
    {
      { trig = 'en' },
      { trig = 'enu' },
      { trig = 'enum' },
      { trig = 'iota' },
      common = { desc = 'Enum with iota (const block)' },
    },
    c(1, {
      un.fmtad(
        [[
          type <typeName> <baseType>

          const (
          <idnt><value1> <typeName> = iota
          <idnt><value2><i>
          )
        ]],
        {
          idnt = un.idnt(1),
          typeName = i(1, 'typeName'),
          baseType = i(2, 'baseType'),
          value1 = r(3, 'value1'),
          value2 = r(4, 'value2'),
          i = i(5),
        }
      ),
      un.fmtad(
        [[
          const (
          <idnt><value1> = iota
          <idnt><value2><i>
          )
        ]],
        {
          idnt = un.idnt(1),
          value1 = r(1, 'value1'),
          value2 = r(2, 'value2'),
          i = i(3),
        }
      ),
    }),
    {
      common_opts = {
        stored = {
          value1 = i(nil, 'Value1'),
          value2 = i(nil, 'Value2'),
        },
      },
    }
  ),
}

return M
