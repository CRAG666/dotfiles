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
  us.msn({
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
      un.fmtad('fmt.Printf("<str>\\n"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Printf("<str>"<args>);', {
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
      un.fmtad('fmt.Printf("<str>\\n"<args>);', {
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Printf("<str>"<args>);', {
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
      un.fmtad('fmt.Fprintf(<w>, "<str>\\n"<args>);', {
        w = c(3, {
          i(nil, 'os.Stderr'),
          i(nil, 'os.Stdout'),
        }),
        str = r(1, 'str'),
        args = r(2, 'args'),
      }),
      un.fmtad('fmt.Fprintf(<w>, "<str>"<args>);', {
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
      un.fmtad('fmt.Fprintf(<w>, "<str>"<args>);', {
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
      trig = 'ck',
      desc = 'Check a value of a variable',
    },
    un.fmtad('"<expr_escaped>:", <expr>', {
      expr = i(1),
      expr_escaped = d(2, function(texts)
        return sn(nil, i(1, vim.fn.escape(texts[1][1], '\\"')))
      end, { 1 }),
    })
  ),
  us.sn(
    {
      trig = 'pck',
      desc = 'Check a value of a variable through fmt.Println()',
    },
    un.fmtad('fmt.Println("<expr_escaped>:", <expr>)', {
      expr = i(1),
      expr_escaped = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\"')
        return sn(nil, i(1, str))
      end, { 1 }),
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
      { trig = 'err' },
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
    un.fmtad(
      [[
        for <var> := <iter>; <cond>; <update> {
        <body>
        }
      ]],
      {
        var = i(1, 'i'),
        iter = i(2, 'iter'),
        cond = i(3, 'cond'),
        update = i(4, 'update'),
        body = un.body(5, 1),
      }
    )
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
  us.sn(
    {
      trig = 'sw',
      desc = 'switch statement',
    },
    un.fmtad(
      [[
        switch <expr> {
        <cases>
        }
      ]],
      {
        expr = i(1),
        cases = un.body(2, 0),
      }
    )
  ),
  us.sn(
    {
      trig = 'cs',
      desc = 'case statement',
    },
    un.fmtad(
      [[
        case <expr>:
        <body>
      ]],
      {
        expr = i(1, 'expr'),
        body = un.body(2, 1, false),
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
      { trig = 'def' },
      common = { desc = 'Function definition' },
    },
    c(1, {
      un.fmtad(
        [[
          func <name>(<args>) <ret> {
          <body>
          }
        ]],
        {
          name = r(1, 'name'),
          args = r(2, 'args'),
          ret = r(3, 'ret'),
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
          args = r(1, 'args'),
          ret = r(2, 'ret'),
          body = un.body(3, 1),
        }
      ),
      un.fmtad(
        [[
          func (<struct>) <name>(<args>) <ret> {
          <body>
          }
        ]],
        {
          name = r(1, 'name'),
          args = r(2, 'args'),
          ret = r(3, 'ret'),
          struct = r(4, 'struct'),
          body = un.body(5, 1),
        }
      ),
    }),
    {
      common_opts = {
        stored = {
          name = i(nil, 'name'),
          struct = i(nil, 'struct'),
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
}

return M
