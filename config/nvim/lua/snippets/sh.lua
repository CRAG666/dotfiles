local M = {}
local uf = require('utils.snippets.funcs')
local un = require('utils.snippets.nodes')
local us = require('utils.snippets.snips')
local ls = require('luasnip')
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node

---Check if current file is bash
---@return boolean
local function is_bash()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename:match('%.bash$') then
    return true
  end

  -- Check first line for bash shebang
  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ''
  return first_line:match('^#!.*bash') ~= nil
end

M.snippets = {
  us.mssn({
    { trig = 'sb' },
    { trig = '#!', snippetType = 'autosnippet' },
    desc = 'Shebang',
  }, {
    t('#!'),
    d(1, function()
      return sn(
        nil,
        c(1, is_bash() and {
          i(nil, '/usr/bin/env bash'),
          i(nil, '/usr/bin/env sh'),
          i(nil, '/bin/bash'),
          i(nil, '/bin/sh'),
        } or {
          i(nil, '/usr/bin/env sh'),
          i(nil, '/usr/bin/env bash'),
          i(nil, '/bin/sh'),
          i(nil, '/bin/bash'),
        })
      )
    end),
  }),
  us.sn(
    {
      trig = 'if',
      desc = 'if statement',
    },
    un.fmtad(
      [[
        if <cond>; then
        <body>
        fi
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1, ':'),
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
        if <cond>; then
        <body>
        else
        <idnt><else_body>
        fi
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1, ':'),
        else_body = i(3, ':'),
        idnt = un.idnt(1),
      }
    )
  ),
  us.msn(
    {
      { trig = 'elif' },
      { trig = 'eif' },
      common = { desc = 'elif statement' },
    },
    un.fmtad(
      [[
        elif <cond>; then
        <body>
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1, ':'),
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
        for <var> in <items>; do
        <body>
        done
      ]],
      {
        var = i(1, 'item'),
        items = i(2, '${items[@]}'),
        body = un.body(3, 1, ':'),
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
        while <cond>; do
        <body>
        done
      ]],
      {
        cond = i(1, 'false'),
        body = un.body(2, 1, ':'),
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
    un.fmtad(
      [[
        <name>() {
        <body>
        }
      ]],
      {
        name = i(1, 'func'),
        body = un.body(2, 1, ':'),
      }
    )
  ),
  us.msn(
    {
      { trig = 'ca' },
      { trig = 'cas' },
      { trig = 'case' },
      { trig = 'sw' },
      { trig = 'swi' },
      { trig = 'switch' },
      common = { desc = 'case statement' },
    },
    un.fmtad(
      [[
        case <expr> in
        <idnt><pattern>)
        <body>
        <idnt><idnt>;;<i>
        esac
      ]],
      {
        idnt = un.idnt(1),
        expr = i(1, '$1'),
        pattern = i(2, '*'),
        body = un.body(3, 2, ':'),
        i = i(4),
      }
    )
  ),
  us.snr(
    {
      trig = '^(%s*)pat',
      desc = 'case pattern',
    },
    un.fmtad(
      [[
        <ddnt><pattern>)
        <body>
        <ddnt><idnt>;;
      ]],
      {
        idnt = un.idnt(1),
        ddnt = un.ddnt(1),
        pattern = i(1, '*'),
        body = un.body(2, function(_, parent)
          return math.max(0, uf.get_indent_depth(parent.snippet.captures[1]))
        end, ':'),
      }
    )
  ),
  us.sn(
    {
      trig = 'sel',
      desc = 'select statement',
    },
    un.fmtad(
      [[
        select <var> in <items>; do
        <body>
        done
      ]],
      {
        var = i(1, 'item'),
        items = i(2, '${items[@]}'),
        body = un.body(3, 1, ':'),
      }
    )
  ),
  us.sn(
    {
      trig = 'unt',
      desc = 'until loop',
    },
    un.fmtad(
      [[
        until <cond>; do
        <body>
        done
      ]],
      {
        cond = i(1, 'true'),
        body = un.body(2, 1, ':'),
      }
    )
  ),
  us.msn({
    { trig = 'p' },
    { trig = 'e' },
    { trig = 'ech' },
    { trig = 'echo' },
  }, t('echo ')),
  us.msn(
    {
      { trig = 'pl' },
      { trig = 'el' },
      common = { desc = 'Print a line' },
    },
    un.fmtad("echo '<line>'", {
      line = c(1, {
        i(nil, '........................................'),
        i(nil, '----------------------------------------'),
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
      v = i(1, '"$var"'),
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
      i(nil, '-r var'),
      i(nil, "-p 'Prompt: ' var"),
      i(nil, '-n 1 var'),
    }),
  }),
  us.sn({
    trig = 'var',
    desc = 'variable declaration',
  }, {
    c(1, {
      un.fmtad('<name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
      un.fmtad('local <name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
      un.fmtad('readonly <name>=<value>', {
        name = i(1, 'var'),
        value = i(2, 'value'),
      }),
    }),
  }),
  us.msn(
    {
      { trig = 'go' },
      { trig = 'geto' },
      common = { desc = 'getopts option parsing' },
    },
    un.fmtad(
      [[
        while getopts "<opts>" opt; do
        <idnt>case $opt in
        <body>
        <idnt>esac
        done
      ]],
      {
        opts = i(1, 'abc:'),
        body = un.body(2, 2, ':'),
        idnt = un.idnt(1),
      }
    )
  ),
  us.sn(
    {
      trig = 'trap',
      desc = 'trap command',
    },
    un.fmtad('trap <cmd> <sig>', {
      cmd = i(1, 'cleanup'),
      sig = c(2, {
        i(nil, 'EXIT'),
        i(nil, 'SIGINT SIGTERM'),
        i(nil, 'ERR'),
      }),
    })
  ),
}

return M
