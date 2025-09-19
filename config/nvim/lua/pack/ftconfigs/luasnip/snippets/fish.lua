local M = {}
local u = require('utils')
local uf = require('utils.snip.funcs')
local un = require('utils.snip.nodes')
local us = require('utils.snip.snips')
local conds = require('utils.snip.conds')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node

M.snippets = {
  us.msns({
    { trig = 'sb' },
    { trig = '#!', snippetType = 'autosnippet' },
    desc = 'Shebang',
  }, {
    t('#!'),
    c(1, {
      i(nil, '/usr/bin/env fish'),
      i(nil, '/usr/bin/fish'),
    }),
  }),
  us.sans({
    trig = '#!',
    desc = 'Shebang',
  }, {
    t('#!'),
    c(1, {
      i(nil, '/usr/bin/env fish'),
      i(nil, '/usr/bin/fish'),
    }),
  }),
  us.sn(
    {
      trig = 'if',
      desc = 'if statement',
    },
    un.fmtad(
      [[
        if <cond>
        <body>
        end
      ]],
      {
        cond = i(1, 'true'),
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
        if <cond>
        <body>
        else
        <idnt><else_body>
        end
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1),
        else_body = i(3),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'elif' },
      { trig = 'eif' },
      common = { desc = 'else if statement' },
    },
    un.fmtad(
      [[
        else if <cond>
        <body>
      ]],
      {
        cond = i(1, 'true'),
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
        for <var> in <items>
        <body>
        end
      ]],
      {
        var = i(1, 'item'),
        items = i(2, '$items'),
        body = un.body(3, 1),
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
        while <cond>
        <body>
        end
      ]],
      {
        cond = i(1, 'false'),
        body = un.body(2, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'fn' },
      { trig = 'func' },
      common = { desc = 'Function definition' },
    },
    un.fmtad(
      [[
        function <name>
        <body>
        end
      ]],
      {
        name = i(1, 'func'),
        body = un.body(2, 1),
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
        function main
        <body>
        end
      ]],
      {
        body = un.body(1, 1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'sw' },
      { trig = 'swi' },
      { trig = 'switch' },
      common = { desc = 'switch statement' },
    },
    un.fmtad(
      [[
        switch <expr>
        <idnt>case <match1>
        <body>
        <idnt>case <match2>
        <idnt><idnt><i>
        end
      ]],
      {
        idnt = un.idnt(1),
        expr = i(1, '$argv[1]'),
        match1 = i(2, "'*'"),
        body = un.body(3, 2),
        match2 = i(4, "'*'"),
        i = i(5),
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
        <ddnt>case <match>
        <body>
      ]],
      {
        ddnt = un.ddnt(1),
        match = i(1, "'*'"),
        body = un.body(2, function(_, parent)
          return math.max(0, uf.get_indent_depth(parent.snippet.captures[1]))
        end),
      }
    )
  ),
  us.sn({ trig = 'eo', desc = 'echo command' }, t('echo ')),
  us.sn({ trig = 'pr', desc = 'printf command' }, t('printf ')),
  us.msn(
    {
      { trig = 'pl' },
      { trig = 'el' },
      common = { desc = 'Print a line' },
    },
    un.fmtad("echo '<line>'", {
      line = c(1, {
        i(nil, '----------------------------------------'),
        i(nil, '........................................'),
        i(nil, '========================================'),
        i(nil, '########################################'),
      }),
    })
  ),
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'eck' },
      common = { desc = 'Debug check expression value' },
    },
    un.fmtad([[echo '<v_esc>:' <v>]], {
      v = i(1, '$var'),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\'):gsub([[']], [['"'"']])
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn(
    {
      trig = 'ck',
      priority = 999,
      desc = 'Debug check expression value (cont.)',
    },
    un.fmtad([['<v_esc>:' <v>]], {
      v = i(1, '$var'),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\'):gsub([[']], [['"'"']])
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.sn({
    trig = 'read',
    desc = 'read input',
  }, {
    t('read '),
    c(1, {
      i(nil, "-P 'Prompt: ' var"),
      i(nil, '-n 1 var'),
      i(nil, 'var'),
    }),
  }),
  us.sn({
    trig = 'var',
    desc = 'variable declaration',
  }, {
    c(1, {
      un.fmtad('set <name> <value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
      un.fmtad('set -l <name> <value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
      un.fmtad('set -g <name> <value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
    }),
  }),
  us.msn(
    {
      { trig = 'ap' },
      { trig = 'argp' },
      common = { desc = 'argparse option parsing' },
    },
    un.fmtad(
      [[
        argparse <opts> -- $argv
        or exit
        <body>
      ]],
      {
        opts = i(1, "'h/help' 'n/name=' 'v/verbose'"),
        body = un.body(2, 0),
      }
    )
  ),
  us.sn(
    {
      trig = 'begin',
      desc = 'begin block',
    },
    un.fmtad(
      [[
        begin
        <body>
        end
      ]],
      {
        body = un.body(1, 1),
      }
    )
  ),
  us.sn(
    {
      trig = 'cd',
      desc = 'cd with exit or return',
    },
    d(1, function()
      if u.ts.find_node({ 'function_definition' }) then
        return sn(
          nil,
          un.fmtad('cd <dir>; or return', {
            dir = i(1, 'dir'),
          })
        )
      end
      return sn(
        nil,
        un.fmtad('cd <dir; or exit', {
          dir = i(1, 'dir'),
        })
      )
    end)
  ),
  us.msn(
    {
      { trig = 'si' },
      { trig = 'sil' },
      common = { desc = 'Run command silently' },
    },
    c(1, {
      t('&>/dev/null'), -- suppress stdout and error
      t('2>/dev/null'), -- suppress error only
      t('>/dev/null'), -- suppress stdout only
    })
  ),
  us.msn({
    { trig = 'ne' },
    { trig = 'noe' },
    { trig = 'noerr' },
    common = { desc = 'Suppress error' },
  }, t('2>/dev/null')),
  us.sn(
    {
      trig = 'err',
      desc = 'Print to stderr',
    },
    d(1, function()
      if not conds.at_line_start() then
        return sn(nil, t('>&2'))
      end
      return sn(
        nil,
        un.fmtad('echo "<msg>" >>&2', {
          msg = i(1, 'msg'),
        })
      )
    end)
  ),
  us.sn(
    {
      trig = 'trap',
      desc = 'trap command',
    },
    un.fmtad('trap <cmd> <sig>', {
      cmd = c(1, {
        i(nil, 'cleanup'),
        i(nil, [['kill (jobs -p) 2>/dev/null; wait']]),
      }),
      sig = c(2, {
        i(nil, 'EXIT INT TERM HUP'), -- common signals that terminates a program by default, useful for most scripts
        i(nil, 'EXIT INT TERM'), -- handle `HUP` in another trap, used in a daemon script
        i(nil, 'EXIT'),
        i(nil, 'INT'),
        i(nil, 'TERM'),
        i(nil, 'HUP'), -- disconnected from terminal, useful for interactive scripts that needs a terminal
      }),
    })
  ),
  us.msn({
    { trig = 'hr' },
    { trig = 'here' },
    common = { desc = 'Get script dir' },
  }, t('(status dirname)/')),
}

return M
