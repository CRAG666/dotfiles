local M = {}
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
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
      { trig = 'function' },
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
  us.msn(
    {
      { trig = 'sw' },
      { trig = 'switch' },
      common = { desc = 'switch statement' },
    },
    un.fmtad(
      [[
        switch <expr>
        <idnt>case <pattern>
        <body>
        end
      ]],
      {
        expr = i(1, '$argv[1]'),
        pattern = i(2, '*'),
        body = un.body(3, 2),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'cs' },
      { trig = 'ca' },
      { trig = 'case' },
      common = { desc = 'switch statement' },
    },
    un.fmtad(
      [[
        switch <expr>
        <idnt>case <pattern>
        <body>
        end
      ]],
      {
        expr = i(1, '$argv[1]'),
        pattern = i(2, '*'),
        body = un.body(3, 2),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn({
    { trig = 'p' },
    { trig = 'e' },
    { trig = 'echo' },
    { trig = 'echo' },
    common = { desc = 'echo command' },
  }, {
    t('echo '),
    c(1, {
      i(nil, '"$argv[1]"'),
      i(nil, "'$argv[1]'"),
      i(nil, '$argv[1]'),
    }),
  }),
  us.msn(
    {
      { trig = 'pl' },
      { trig = 'el' },
      common = { desc = 'Print a line' },
    },
    un.fmtad('echo "<line>"', {
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
  us.msn(
    {
      { trig = 'pck' },
      { trig = 'eck' },
      { trig = 'pcheck' },
      { trig = 'echeck' },
      common = { desc = 'Debug check expression value' },
    },
    un.fmtad([[echo '<v_esc>:' <v>]], {
      v = i(1, '"$var"'),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\'):gsub([[']], [['"'"']])
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msn(
    {
      { trig = 'ck' },
      { trig = 'check' },
      common = {
        priority = 999,
        desc = 'Debug check expression value (cont.)',
      },
    },
    un.fmtad([['<v_esc>:' <v>]], {
      v = i(1, '"$var"'),
      v_esc = d(2, function(texts)
        local str = vim.fn.escape(texts[1][1], '\\'):gsub([[']], [['"'"']])
        return sn(nil, i(1, str))
      end, { 1 }),
    })
  ),
  us.msn({
    { trig = 'r' },
    { trig = 'read' },
    common = { desc = 'read input' },
  }, {
    t('read '),
    c(1, {
      i(nil, '-P "Prompt: " var'),
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
      { trig = 'arg' },
      { trig = 'argparse' },
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
}

return M
